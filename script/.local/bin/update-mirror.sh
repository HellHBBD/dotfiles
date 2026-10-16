#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf '%s\n' \
        'Usage: update-mirror.sh [--dry-run] [--timeout SECONDS]' \
        'Rate the 10 latest HTTPS mirrors synced within 12 hours, sequentially.' \
        'Install up to 5 mirrors with successful speed tests; leave the current list on validation failure.' \
        'Only installation requires sudo. No backup or lock file is created.' \
        'Default generation timeout: 120 seconds. --dry-run prints the candidate without installing it.'
}

fail() {
    printf 'update-mirror.sh: %s\n' "$*" >&2
    exit 2
}

time_limit=120
dry_run=0
while (($#)); do
    case "$1" in
    --dry-run)
        dry_run=1
        shift
        ;;
    --timeout)
        [[ "${2-}" =~ ^[1-9][0-9]*$ ]] || fail "$1 requires a positive integer"
        time_limit="$2"
        shift 2
        ;;
    --help | -h)
        usage
        exit 0
        ;;
    *) fail "unknown argument: $1" ;;
    esac
done

((EUID != 0)) || fail 'run as a regular user; elevation is requested only for installation'
for dependency in guard-run timeout /usr/bin/python3 mktemp; do
    command -v "$dependency" >/dev/null 2>&1 || fail "missing dependency: $dependency"
done
if ((dry_run == 0)); then
    command -v sudo >/dev/null 2>&1 || fail 'missing dependency: sudo'
fi

candidate=$(mktemp "${TMPDIR:-/tmp}/update-mirror.XXXXXXXX")
trap 'rm -f -- "$candidate"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

# Reflector's CLI keeps zero-rate mirrors after failed tests. Use its installed
# Python API to exclude failures before formatting the list, without root.
guard-run --jobs 1 --cpu-quota 100% --memory-high 256M --memory-max 512M -- \
    timeout --signal=TERM --kill-after=10s "${time_limit}s" \
    /usr/bin/python3 -I - "$candidate" <<'PY'
import logging
import math
from pathlib import Path
import sys
from urllib.parse import urlsplit

try:
    import Reflector
except ImportError:
    sys.exit("update-mirror.sh: install reflector for this system Python first")

logging.basicConfig(level=logging.WARNING)
arguments = ["--age", "12", "--latest", "10", "--protocol", "https",
             "--connection-timeout", "5", "--download-timeout", "5"]

try:
    options = Reflector.parse_args(arguments)
    status, candidates = Reflector.process_options(options)
    candidates = list(candidates)
    if not candidates:
        sys.exit("update-mirror.sh: no matching mirrors; current mirrorlist preserved")
    rates = Reflector.rate(candidates, n_threads=0, connection_timeout=5, download_timeout=5)
    usable = []
    seen = set()
    for mirror in sorted(candidates, key=lambda item: rates.get(item["url"], 0), reverse=True):
        url = mirror["url"]
        rate = rates.get(url, 0)
        parsed = urlsplit(url)
        if not math.isfinite(rate) or rate <= 0 or url in seen:
            continue
        if (parsed.scheme != "https" or not parsed.hostname or parsed.username is not None
                or parsed.password is not None or parsed.query or parsed.fragment
                or "$" in url or not url.endswith("/")
                or any(character.isspace() or ord(character) < 32 or ord(character) == 127 for character in url)):
            continue
        usable.append(mirror)
        seen.add(url)
    usable = usable[:5]
    if not usable:
        sys.exit("update-mirror.sh: no mirrors passed speed tests; current mirrorlist preserved")
    output = status.get_mirrorlist(usable, cmd=arguments)
    if not output:
        sys.exit("update-mirror.sh: empty candidate; current mirrorlist preserved")
    output = "# update-mirror.sh: only successful HTTPS speed tests, fastest first.\n" + output
    Path(sys.argv[1]).write_text(output, encoding="utf-8")
    print(f"Validated {len(usable)} of {len(candidates)} candidate mirrors.", file=sys.stderr)
except KeyboardInterrupt:
    sys.exit(130)
except (OSError, ValueError, KeyError, TypeError, AttributeError, Reflector.MirrorStatusError) as error:
    sys.exit(f"update-mirror.sh: generation failed; current mirrorlist preserved: {error}")
PY

if ((dry_run)); then
    cat -- "$candidate"
    exit 0
fi

# The user runs this script manually. The privileged phase uses only the
# standard library and revalidates a bounded snapshot before touching /etc.
# The staging file is on the destination filesystem for an atomic replacement.
sudo /usr/bin/python3 -I - "$candidate" <<'PY'
import os
from pathlib import Path
import re
import signal
import stat
import sys
import tempfile
from urllib.parse import urlsplit

target = Path("/etc/pacman.d/mirrorlist")
staging = None


def terminate(signum, _frame):
    sys.exit(128 + signum)


signal.signal(signal.SIGTERM, terminate)
signal.signal(signal.SIGHUP, terminate)
try:
    descriptor = os.open(sys.argv[1], os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    with os.fdopen(descriptor, "rb") as source:
        if not stat.S_ISREG(os.fstat(source.fileno()).st_mode):
            raise ValueError("candidate must be a regular file")
        data = source.read(262145)
    if not data or len(data) > 262144:
        raise ValueError("candidate is empty or too large")
    servers = set()
    for line in data.decode("utf-8").splitlines():
        if any(ord(character) < 32 or ord(character) == 127 for character in line):
            raise ValueError("candidate contains control characters")
        if not line or line.startswith("#"):
            continue
        if not re.fullmatch(r"Server = https://[^\s]+/\$repo/os/\$arch", line):
            raise ValueError("unexpected mirrorlist directive")
        url = line.removeprefix("Server = ")
        parsed = urlsplit(url)
        if (not parsed.hostname or parsed.username is not None or parsed.password is not None
                or "$" in parsed.netloc or parsed.query or parsed.fragment or url in servers):
            raise ValueError("invalid or duplicate mirror URL")
        servers.add(url)
    if not 1 <= len(servers) <= 5:
        raise ValueError("expected 1 to 5 validated HTTPS mirrors")

    try:
        existing = target.lstat()
    except FileNotFoundError:
        existing = None
    if existing is not None and not stat.S_ISREG(existing.st_mode):
        raise ValueError("destination must be a regular file, not a symlink")
    descriptor, staging = tempfile.mkstemp(prefix=".mirrorlist-", dir=target.parent)
    with os.fdopen(descriptor, "wb") as destination:
        destination.write(data)
        destination.flush()
        if existing is not None:
            os.fchown(destination.fileno(), existing.st_uid, existing.st_gid)
        os.fchmod(destination.fileno(), stat.S_IMODE(existing.st_mode) if existing else 0o644)
        os.fsync(destination.fileno())
    os.replace(staging, target)
    staging = None
    print(f"Updated {target} with {len(servers)} HTTPS mirrors.")
except KeyboardInterrupt:
    sys.exit(130)
except (OSError, UnicodeError, ValueError) as error:
    sys.exit(f"update-mirror.sh: installation failed: {error}")
finally:
    if staging is not None:
        Path(staging).unlink(missing_ok=True)
PY
