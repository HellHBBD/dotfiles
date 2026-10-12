"""Exercise display-mode.sh through mocked commands; never contact Hyprland."""

import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

SCRIPT = (
    Path(__file__).resolve().parents[1]
    / "hyprland/.config/hypr/scripts/display-mode.sh"
)

MOCK = r"""#!/usr/bin/python3
import fcntl
import json
import os
import re
import sys
from pathlib import Path

root = Path(os.environ["DISPLAY_TEST_ROOT"])
path = root / "scenario.json"
name = Path(sys.argv[0]).name
args = sys.argv[1:]
# Read the complete piped menu before locking: its producer also uses the mock.
options = sys.stdin.read().splitlines() if name == "fuzzel" else []
lock = (root / "mock.lock").open("w")
fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
state = json.loads(path.read_text())
state.setdefault("calls", []).append([name, *args])
result = ""
status = 0
if name == "hyprctl":
    if args[:2] == ["-j", "monitors"]:
        result = json.dumps(state["monitors"])
    elif args == ["-j", "workspaces"]:
        result = json.dumps(state.get("workspaces", []))
    elif args == ["-j", "activeworkspace"]:
        result = json.dumps({"id": state.get("active", 1)})
    elif args[0] == "eval":
        code = args[1]
        if state.get("fail_eval"):
            status = 1
        else:
            if "hl.monitor" in code:
                fields = dict(re.findall(r'(\w+) = ("(?:[^"\\]|\\.)*"|true|false|[\d.]+)', code))
                fields = {k: json.loads(v) for k, v in fields.items()}
                monitor = next(m for m in state["monitors"] if m["name"] == fields["output"])
                monitor.update(disabled=fields["disabled"], mirrorOf=fields["mirror"] or "none")
                if isinstance(fields["scale"], (int, float)):
                    monitor["scale"] = fields["scale"]
                monitor["transform"] = fields["transform"]
            for workspace, output in re.findall(r'workspace = (\d+), monitor = ("(?:[^"\\]|\\.)*")', code):
                for item in state.get("workspaces", []):
                    if item["id"] == int(workspace):
                        item["monitor"] = json.loads(output)
            result = "ok"
    else:
        raise RuntimeError(args)
elif name == "fuzzel":
    state.setdefault("menus", []).append(options)
    choice = state.get("choices", []).pop(0) if state.get("choices") else None
    if choice is None:
        status = 1
    else:
        selected = [option for option in options if option.startswith(choice)]
        if not selected:
            raise RuntimeError((choice, options))
        result = selected[0]
        if state.get("drop_after_choice") == choice:
            state["monitors"] = [m for m in state["monitors"] if m["name"] != state["drop_output"]]
elif name == "audio-output-policy.sh":
    pass
elif name not in ("notify-send", "sleep"):
    raise RuntimeError(name)
path.write_text(json.dumps(state))
if result:
    print(result)
sys.exit(status)
"""


def monitor(name, *, focused=False, disabled=False, mirror="none", scale=1):
    return {
        "id": int(name.rsplit("-", 1)[-1]) if name.rsplit("-", 1)[-1].isdigit() else 0,
        "name": name,
        "description": "Fixture display",
        "disabled": disabled,
        "mirrorOf": mirror,
        "focused": focused,
        "width": 1920,
        "height": 1080,
        "refreshRate": 144,
        "availableModes": ["1920x1080@144.00Hz", "1920x1080@60.00Hz"],
        "scale": scale,
        "transform": 0,
        "x": 0,
        "y": 0,
        "activeWorkspace": {"id": 1},
    }


class DisplayModeTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(
            prefix="display-mode-", dir="/tmp/opencode"
        )
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        bin_dir = self.root / "bin"
        bin_dir.mkdir()
        for name in ("hyprctl", "fuzzel", "notify-send", "sleep"):
            path = bin_dir / name
            path.write_text(MOCK)
            path.chmod(0o755)
        audio = self.root / "home/.config/hypr/scripts/audio-output-policy.sh"
        audio.parent.mkdir(parents=True)
        audio.write_text(MOCK)
        audio.chmod(0o755)
        (self.root / "runtime").mkdir()
        self.env = {
            **os.environ,
            "PATH": f"{bin_dir}:/usr/bin:/bin",
            "HOME": str(self.root / "home"),
            "XDG_RUNTIME_DIR": str(self.root / "runtime"),
            "DISPLAY_TEST_ROOT": str(self.root),
        }
        self.state_file = self.root / "runtime/hypr-display-mode.json"

    def run_menu(self, monitors, choices=(), *, args=(), **scenario):
        path = self.root / "scenario.json"
        path.write_text(
            json.dumps({"monitors": monitors, "choices": list(choices), **scenario})
        )
        result = subprocess.run(
            ["bash", str(SCRIPT), *args],
            env=self.env,
            capture_output=True,
            text=True,
            timeout=15,
            check=False,
        )
        self.assertEqual(result.stderr, "", result.stderr)
        state = json.loads(path.read_text())
        return result.returncode, state

    def evals(self, state):
        return [c[2] for c in state["calls"] if c[:2] == ["hyprctl", "eval"]]

    def test_desktop_single_output(self):
        code, state = self.run_menu([monitor("HDMI-A-1", focused=True)])
        self.assertEqual(code, 0)
        self.assertFalse(self.evals(state))
        self.assertNotIn("menus", state)
        self.assertIn("目前只有一台螢幕", str(state["calls"]))
        self.assertNotIn("找不到內建", str(state["calls"]))

    def test_laptop_internal_connector_is_discovered(self):
        code, state = self.run_menu(
            [monitor("eDP-2", scale=1.25), monitor("DP-3", focused=True, scale=1.5)],
            ["鏡像"],
            workspaces=[{"id": 4, "monitor": "DP-3"}],
        )
        self.assertEqual(code, 0)
        self.assertEqual(state["workspaces"][0]["monitor"], "eDP-2")
        calls = "\n".join(self.evals(state))
        self.assertIn('mirror = "eDP-2"', calls)
        self.assertIn("scale = 1.5", calls)
        self.assertIn('mode = "1920x1080@144.00"', calls)
        self.assertNotIn("audio-output-policy.sh", str(state["calls"]))

    def test_desktop_focused_source_and_mst_target(self):
        code, state = self.run_menu(
            [monitor("DP-1"), monitor("DP-2", focused=True), monitor("DP-3-1")],
            ["DP-3-1", "延伸並移動目前"],
            active=7,
            workspaces=[{"id": 7, "monitor": "DP-2"}],
        )
        self.assertEqual(code, 0)
        self.assertIn("DP-2 → DP-3-1", str(state["calls"]))
        self.assertEqual(state["workspaces"][0]["monitor"], "DP-3-1")
        self.assertNotIn("audio-output-policy.sh", str(state["calls"]))

    def test_enable_disabled_target(self):
        code, state = self.run_menu(
            [monitor("DP-1", focused=True), monitor("HDMI-A-2", disabled=True)],
            ["延伸顯示"],
        )
        self.assertEqual(code, 0)
        self.assertFalse(state["monitors"][1]["disabled"])
        self.assertIn('position = "auto-right"', "\n".join(self.evals(state)))

    def test_change_source(self):
        code, state = self.run_menu(
            [monitor("DP-1", focused=True), monitor("DP-2")],
            ["更換來源", "DP-2", "鏡像"],
        )
        self.assertEqual(code, 0)
        self.assertIn('mirror = "DP-2"', "\n".join(self.evals(state)))

    def test_unplug_before_disable_does_not_mutate(self):
        for dropped in ("DP-1", "DP-2"):
            with self.subTest(dropped=dropped):
                code, state = self.run_menu(
                    [monitor("DP-1", focused=True), monitor("DP-2")],
                    ["停用"],
                    drop_after_choice="停用",
                    drop_output=dropped,
                )
                self.assertEqual(code, 1)
                self.assertFalse(self.evals(state))

    def test_disable_and_restore_only_existing_owned_workspaces(self):
        monitors = [monitor("DP-1", focused=True), monitor("DP-2", scale=1.5)]
        workspaces = [{"id": 1, "monitor": "DP-1"}, {"id": 3, "monitor": "DP-2"}]
        code, state = self.run_menu(monitors, ["停用"], workspaces=workspaces)
        self.assertEqual(code, 0)
        self.assertTrue(state["monitors"][1]["disabled"])
        stored = json.loads(self.state_file.read_text())
        self.assertEqual(stored["outputs"]["DP-2"]["workspaces"], [3])
        stored["outputs"]["DP-2"]["workspaces"] += [8, 9]
        stored["outputs"]["HDMI-A-3"] = {"source": "DP-1", "workspaces": [12]}
        self.state_file.write_text(json.dumps(stored))
        state["workspaces"].append({"id": 9, "monitor": "HDMI-A-3"})
        code, restored = self.run_menu(
            state["monitors"], ["延伸顯示"], workspaces=state["workspaces"]
        )
        self.assertEqual(code, 0)
        self.assertIn({"id": 3, "monitor": "DP-2"}, restored["workspaces"])
        self.assertIn({"id": 9, "monitor": "HDMI-A-3"}, restored["workspaces"])
        self.assertNotIn("workspace = 8", "\n".join(self.evals(restored)))
        self.assertIn("scale = 1.5", "\n".join(self.evals(restored)))

    def test_mirror_repair_uses_actual_source_without_menu(self):
        self.state_file.write_text(
            json.dumps(
                {
                    "version": 2,
                    "outputs": {"DP-3": {"source": "DP-2", "workspaces": [5]}},
                }
            )
        )
        code, state = self.run_menu(
            [monitor("DP-2", focused=True), monitor("DP-3", mirror="DP-2")],
            args=["--repair-mirror"],
            workspaces=[{"id": 5, "monitor": "DP-3"}],
        )
        self.assertEqual(code, 0)
        self.assertNotIn("menus", state)
        self.assertEqual(state["workspaces"][0]["monitor"], "DP-2")
        self.assertEqual(
            json.loads(self.state_file.read_text())["outputs"]["DP-3"]["workspaces"],
            [5],
        )

    def test_repair_non_mirror_single_display_is_silent(self):
        code, state = self.run_menu([monitor("HDMI-A-1")], args=["--repair-mirror"])
        self.assertEqual(code, 0)
        self.assertFalse(self.evals(state))
        self.assertFalse(any(c[0] in ("fuzzel", "notify-send") for c in state["calls"]))

    def test_legacy_state_is_scoped_to_original_pair(self):
        self.state_file.write_text("[3, 8]")
        code, state = self.run_menu(
            [monitor("eDP-1"), monitor("HDMI-A-1", disabled=True)],
            ["延伸顯示"],
            workspaces=[{"id": 3, "monitor": "eDP-1"}],
        )
        self.assertEqual(code, 0)
        self.assertEqual(state["workspaces"][0]["monitor"], "HDMI-A-1")
        self.assertNotIn("workspace = 8", "\n".join(self.evals(state)))
        self.assertIn("audio-output-policy.sh", str(state["calls"]))

    def test_cannot_disable_another_mirror_source(self):
        code, state = self.run_menu(
            [
                monitor("DP-1", focused=True),
                monitor("DP-2"),
                monitor("DP-3", mirror="DP-2"),
            ],
            ["DP-2", "停用"],
            workspaces=[{"id": 5, "monitor": "DP-2"}],
        )
        self.assertEqual(code, 1)
        self.assertFalse(self.evals(state))

    def test_cancel_and_failed_apply(self):
        monitors = [monitor("DP-1", focused=True), monitor("DP-2")]
        code, state = self.run_menu(monitors)
        self.assertEqual(code, 0)
        self.assertFalse(self.evals(state))
        code, state = self.run_menu(monitors, ["延伸顯示"], fail_eval=True)
        self.assertEqual(code, 1)
        self.assertNotIn("已延伸顯示", str(state["calls"]))

    def test_other_target_state_and_special_workspace_are_preserved(self):
        other = {"source": "DP-1", "workspaces": [12]}
        self.state_file.write_text(
            json.dumps({"version": 2, "outputs": {"DP-3": other}})
        )
        code, state = self.run_menu(
            [monitor("DP-1", focused=True), monitor("DP-2"), monitor("DP-3")],
            ["DP-2", "鏡像"],
            workspaces=[
                {"id": 5, "monitor": "DP-2"},
                {"id": -99, "monitor": "DP-2"},
            ],
        )
        self.assertEqual(code, 0)
        self.assertEqual(
            json.loads(self.state_file.read_text())["outputs"]["DP-3"], other
        )
        self.assertIn({"id": -99, "monitor": "DP-2"}, state["workspaces"])

    def test_corrupt_state_and_invalid_cached_settings(self):
        self.state_file.write_text("{")
        monitors = [monitor("DP-1", focused=True), monitor("DP-2", disabled=True)]
        code, state = self.run_menu(monitors, ["延伸顯示"])
        self.assertEqual(code, 0)
        self.assertTrue(self.evals(state))
        self.state_file.write_text(
            json.dumps(
                {
                    "version": 2,
                    "outputs": {
                        "DP-2": {
                            "source": "DP-1",
                            "workspaces": [],
                            "settings": {
                                "mode": "preferred",
                                "scale": 1,
                                "position": "0x0",
                                "transform": "0); unexpected()",
                            },
                        }
                    },
                }
            )
        )
        code, state = self.run_menu(monitors, ["延伸顯示"])
        self.assertEqual(code, 1)
        self.assertFalse(self.evals(state))

    def test_rotation_and_no_available_source(self):
        rotated = monitor("DP-2", scale=1.5)
        rotated.update(width=1080, height=1920, transform=1)
        code, state = self.run_menu(
            [monitor("DP-1", focused=True), rotated], ["延伸顯示"]
        )
        self.assertEqual(code, 0)
        self.assertIn('mode = "1920x1080@144.00"', "\n".join(self.evals(state)))
        self.assertIn("transform = 1", "\n".join(self.evals(state)))
        code, state = self.run_menu([monitor("DP-1", disabled=True)])
        self.assertEqual(code, 1)
        self.assertFalse(self.evals(state))


if __name__ == "__main__":
    unittest.main()
