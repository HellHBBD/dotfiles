"""Launch reviewed, pinned native MCP servers with a minimal environment.

This is a startup/integrity boundary, not an OS sandbox. Runtime acquisition
and dependency review happen separately; startup never installs or updates.
"""

import hashlib
import os
import stat
import sys
from pathlib import Path

HOME = Path("/home/hellhbbd")
MANAGER = HOME / ".local/share/opencode-extension-manager"
SERVERS = {
    "zhtw": (
        "vendor-sysprog21-zhtw-mcp/0485df42b26e08e7e9d00da0a5c773ca99bedbd7",
        "0ce03437bf54bfcce37b80b59e6a632b9700f6a1d025952d57c72cf5520be0dd",
    ),
    "hackmd": (
        "vendor-sysprog21-hackmd-mcp/2951aab8ba18c565905511450ee19afbd5048041",
        "02b04cd7ef50f74f1039bc85e9e925019e72c3e13a6556004f7827a2d7a481c7",
    ),
    "moodle": (
        "vendor-g36maid-moodle-mcp/0.1.4-47c0bc219a875e3cf5cd81506540a66197b27c65",
        "faaeaa3be53bfc2d2743a55c0c0069f8a768e987e436a2822b32ba7e07eaa469",
    ),
}


def private_directory(path):
    path.mkdir(parents=True, mode=0o700, exist_ok=True)
    metadata = path.lstat()
    if (
        not stat.S_ISDIR(metadata.st_mode)
        or metadata.st_uid != os.getuid()
        or metadata.st_mode & 0o077
    ):
        raise ValueError("MCP state must be a private, user-owned directory")


def token(variable):
    value = os.environ.get(variable, "").strip()
    if not value or any(
        ord(character) < 32 or ord(character) == 127 for character in value
    ):
        raise ValueError(f"{variable} must contain one nonempty credential")
    return value


def launch(name):
    relative, expected = SERVERS[name]
    runtime = MANAGER / "runtime" / relative
    binary = runtime / f"{name}-mcp"
    descriptor = os.open(binary, os.O_RDONLY | os.O_NOFOLLOW)
    try:
        metadata = os.fstat(descriptor)
        if (
            not stat.S_ISREG(metadata.st_mode)
            or metadata.st_uid != os.getuid()
            or metadata.st_mode & 0o022
            or not metadata.st_mode & stat.S_IXUSR
            or metadata.st_size > 64 * 1024 * 1024
        ):
            raise ValueError("unsafe MCP executable metadata")
        with os.fdopen(os.dup(descriptor), "rb") as source:
            actual = hashlib.file_digest(source, "sha256").hexdigest()
        if actual != expected:
            raise ValueError(
                "MCP executable changed; review the update before activation"
            )

        state = MANAGER / "state" / f"knowledge-{name}"
        private_directory(state)
        private_directory(state / "home")
        private_directory(state / "tmp")
        os.umask(0o077)
        environment = {
            "HOME": str(state / "home"),
            "PATH": "/usr/bin:/bin",
            "LANG": "C.UTF-8",
            "LC_ALL": "C.UTF-8",
            "TMPDIR": str(state / "tmp"),
            "XDG_CONFIG_HOME": str(state / "home/.config"),
            "XDG_CACHE_HOME": str(state / "home/.cache"),
            "XDG_DATA_HOME": str(state / "home/.local/share"),
            "XDG_STATE_HOME": str(state / "home/.local/state"),
            "RUST_LOG": "warn",
        }
        arguments = [str(binary)]
        if name == "zhtw":
            environment["ZHTW_NO_NETWORK"] = "1"
            # An explicit first-party config prevents discovery of a checked-out
            # repository's .zhtw-mcp.toml and its alternate store paths.
            project_config = runtime / "project.toml"
            expected_config = (
                f'translation_memory = "{state}/translation-memory.json"\n'
            )
            if (
                project_config.is_symlink()
                or project_config.read_text() != expected_config
            ):
                raise ValueError("zhtw runtime config changed")
            arguments.extend(["--config", str(project_config)])
        elif name == "hackmd":
            workspace = HOME / "obsidian/HackMD"
            if not workspace.is_dir() or workspace.is_symlink():
                raise ValueError("HackMD workspace is missing or is a symlink")
            environment.update(
                {
                    "HACKMD_API_TOKEN": token("HACKMD_API_TOKEN"),
                    "HACKMD_API_URL": "https://api.hackmd.io/v1",
                    "HACKMD_MCP_WORKSPACE_ROOT": str(workspace),
                    "HACKMD_MCP_STATE_DIR": str(state / "sync"),
                    "HACKMD_MCP_OTEL": "0",
                }
            )
        else:
            environment.update(
                {
                    "MOODLE_URL": "https://moodle.ncku.edu.tw",
                    "MOODLE_TOKEN": token("MOODLE_TOKEN"),
                    "MOODLE_READ_ONLY": "0",
                    "MOODLE_DISABLE_TOOLS": "",
                    "MOODLE_TIMEZONE": "Asia/Taipei",
                    "MOODLE_TIMEOUT_SECS": "30",
                }
            )
            arguments.append("serve")

        # No inherited .env, proxy, loader, tracing-export, or unrelated auth
        # variables. stdin/stdout remain the MCP transport; diagnostics use stderr.
        os.chdir(state)
        os.lseek(descriptor, 0, os.SEEK_SET)
        os.set_inheritable(descriptor, True)
        os.execve(descriptor, arguments, environment)
    finally:
        os.close(descriptor)


if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in SERVERS:
        sys.exit("usage: knowledge-mcp-launcher.py zhtw|hackmd|moodle")
    try:
        launch(sys.argv[1])
    except (OSError, ValueError):
        # Do not render exception objects that could include credentials.
        sys.exit(
            "knowledge MCP startup refused; check pinned runtime, private state, workspace and credential configuration"
        )
