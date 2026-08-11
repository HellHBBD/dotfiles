#!/usr/bin/env python3
"""Read active Hyprland binds into a searchable, read-only reference window."""

from __future__ import annotations

import html
import json
import subprocess
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path

import gi

gi.require_version("Adw", "1")
gi.require_version("Gtk", "4.0")
from gi.repository import Adw, Gdk, Gio, Gtk


APP_ID = "com.hellhbbd.HyprlandCheatsheet"
CATEGORY_ORDER = (
    "應用程式",
    "視窗管理",
    "工作區",
    "螢幕擷取",
    "媒體與硬體",
    "系統",
    "其他",
)
CATEGORY_ALIASES = {
    "應用程式": "applications app launcher browser file manager clipboard",
    "視窗管理": "window focus move layout floating fullscreen",
    "工作區": "workspace scratchpad",
    "螢幕擷取": "screenshot capture color picker",
    "媒體與硬體": "audio volume microphone brightness media",
    "系統": "session lock notification power logout",
    "其他": "other",
}
MODIFIERS = ((4, "CTRL"), (8, "ALT"), (64, "SUPER"), (1, "SHIFT"))
KEY_LABELS = {
    "Return": "Enter",
    "Slash": "/",
    "Print": "Print Screen",
    "mouse:272": "滑鼠左鍵",
    "mouse:273": "滑鼠右鍵",
    "mouse_up": "滑鼠滾輪上",
    "mouse_down": "滑鼠滾輪下",
    "XF86AudioRaiseVolume": "音量 +",
    "XF86AudioLowerVolume": "音量 -",
    "XF86AudioMute": "靜音鍵",
    "XF86AudioMicMute": "麥克風靜音鍵",
    "XF86MonBrightnessUp": "亮度 +",
    "XF86MonBrightnessDown": "亮度 -",
    "XF86AudioPlay": "播放鍵",
    "XF86AudioPause": "暫停鍵",
    "XF86AudioNext": "下一首鍵",
    "XF86AudioPrev": "上一首鍵",
}


@dataclass(frozen=True)
class RawBinding:
    modmask: int
    key: str
    category: str
    action: str
    aliases: str


@dataclass(frozen=True)
class Binding:
    category: str
    shortcut: str
    action: str
    aliases: str

    @property
    def searchable(self) -> str:
        return " ".join(
            (
                self.category,
                CATEGORY_ALIASES.get(self.category, ""),
                self.shortcut,
                self.action,
                self.aliases,
            )
        ).casefold()


def structured_description(description: str) -> tuple[str, str, str]:
    parts = [part.strip() for part in description.split("|", 2)]
    if len(parts) == 3 and all(parts):
        return tuple(parts)  # type: ignore[return-value]
    return "其他", description.strip(), ""


def load_raw_bindings() -> list[RawBinding]:
    try:
        result = subprocess.run(
            ["hyprctl", "binds"],
            check=True,
            capture_output=True,
            text=True,
            timeout=3,
        )
    except (
        FileNotFoundError,
        subprocess.CalledProcessError,
        subprocess.TimeoutExpired,
    ) as error:
        raise RuntimeError(f"無法讀取目前生效的 Hyprland 快捷鍵：{error}") from error

    blocks: list[dict[str, str]] = []
    current: dict[str, str] = {}
    for line in result.stdout.splitlines():
        if line and not line.startswith((" ", "\t")):
            if current:
                blocks.append(current)
            current = {}
            continue

        if ":" not in line:
            continue
        name, value = line.strip().split(":", 1)
        current[name.strip()] = value.strip()

    if current:
        blocks.append(current)

    bindings: list[RawBinding] = []
    for block in blocks:
        description = block.get("description", "")
        key = block.get("key", "")
        if not description or not key:
            continue
        try:
            modmask = int(block.get("modmask", "0"))
        except ValueError:
            continue
        category, action, aliases = structured_description(description)
        bindings.append(RawBinding(modmask, key, category, action, aliases))

    if not bindings:
        raise RuntimeError("Hyprland 沒有回傳可顯示的快捷鍵。")
    return bindings


def compact_key(keys: set[str]) -> str:
    if keys == set("1234567890"):
        return "1–0"
    if keys == {"Left", "Right", "Up", "Down"}:
        return "方向鍵"
    if keys == {"Minus", "Equal"}:
        return "- / ="
    if keys == {"mouse_up", "mouse_down"}:
        return "滑鼠滾輪"
    if keys == {"XF86AudioRaiseVolume", "XF86AudioLowerVolume"}:
        return "音量 + / -"
    if keys == {"XF86MonBrightnessUp", "XF86MonBrightnessDown"}:
        return "亮度 + / -"
    if keys == {"XF86AudioPlay", "XF86AudioPause"}:
        return "播放／暫停鍵"
    if keys == {"XF86AudioNext", "XF86AudioPrev"}:
        return "上一首／下一首鍵"
    return " / ".join(KEY_LABELS.get(key, key) for key in sorted(keys))


def format_shortcut(modmask: int, keys: set[str]) -> str:
    modifiers = [name for bit, name in MODIFIERS if modmask & bit]
    tail = compact_key(keys)
    return " + ".join((*modifiers, tail)) if modifiers else tail


def group_bindings(raw_bindings: list[RawBinding]) -> list[Binding]:
    grouped: dict[tuple[int, str, str, str], set[str]] = defaultdict(set)
    for binding in raw_bindings:
        grouped[
            (binding.modmask, binding.category, binding.action, binding.aliases)
        ].add(binding.key)

    bindings = [
        Binding(category, format_shortcut(modmask, keys), action, aliases)
        for (modmask, category, action, aliases), keys in grouped.items()
    ]
    return sorted(
        bindings,
        key=lambda binding: (
            CATEGORY_ORDER.index(binding.category)
            if binding.category in CATEGORY_ORDER
            else len(CATEGORY_ORDER),
            binding.action,
            binding.shortcut,
        ),
    )


def highlight(text: str, query: str) -> str:
    escaped = html.escape(text)
    if not query:
        return escaped

    start = text.casefold().find(query.casefold())
    if start < 0:
        return escaped
    end = start + len(query)
    return f'{html.escape(text[:start])}<span class="match">{html.escape(text[start:end])}</span>{html.escape(text[end:])}'


class CheatSheetApplication(Adw.Application):
    def __init__(self) -> None:
        super().__init__(application_id=APP_ID, flags=Gio.ApplicationFlags.NON_UNIQUE)
        Adw.StyleManager.get_default().set_color_scheme(Adw.ColorScheme.FORCE_DARK)
        self.window: Adw.ApplicationWindow | None = None
        self.bindings: list[Binding] = []
        self.search_entry: Gtk.SearchEntry | None = None
        self.stack: Gtk.Stack | None = None
        self.css_loaded = False
        self.connect("activate", self._activate)

    def _load_css(self) -> None:
        if self.css_loaded:
            return
        provider = Gtk.CssProvider()
        provider.load_from_path(str(Path(__file__).with_name("style.css")))
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        self.css_loaded = True

    def _activate(self, *_args: object) -> None:
        if self._close_existing_window():
            self.quit()
            return
        if self.window and self.window.get_visible():
            self.window.close()
            return

        self._load_css()
        self.window = Adw.ApplicationWindow(application=self, title="Hyprland 快捷鍵")
        self.window.set_default_size(1100, 720)
        self.window.set_size_request(720, 480)
        self.window.connect("close-request", self._on_close)
        self.window.add_controller(self._key_controller())

        try:
            self.bindings = group_bindings(load_raw_bindings())
            self.window.set_content(self._build_content())
        except RuntimeError as error:
            self.window.set_content(self._error_page(str(error)))

        self.window.present()
        if self.search_entry:
            self.search_entry.grab_focus()

    @staticmethod
    def _close_existing_window() -> bool:
        try:
            result = subprocess.run(
                ["hyprctl", "-j", "clients"],
                check=True,
                capture_output=True,
                text=True,
                timeout=3,
            )
            clients = json.loads(result.stdout)
        except (
            json.JSONDecodeError,
            FileNotFoundError,
            subprocess.CalledProcessError,
            subprocess.TimeoutExpired,
        ):
            return False

        for client in clients:
            if client.get("class") != APP_ID:
                continue
            subprocess.run(
                [
                    "hyprctl",
                    "dispatch",
                    f'hl.dsp.window.close({{ address = "{client["address"]}" }})',
                ],
                capture_output=True,
                text=True,
                timeout=3,
            )
            return True
        return False

    def _on_close(self, *_args: object) -> bool:
        self.window = None
        return False

    def _key_controller(self) -> Gtk.EventControllerKey:
        controller = Gtk.EventControllerKey()
        controller.connect("key-pressed", self._on_key_pressed)
        return controller

    def _on_key_pressed(
        self,
        _controller: Gtk.EventControllerKey,
        keyval: int,
        _keycode: int,
        state: Gdk.ModifierType,
    ) -> bool:
        if keyval == Gdk.KEY_Escape:
            if self.search_entry and self.search_entry.get_text():
                self.search_entry.set_text("")
            elif self.window:
                self.window.close()
            return True
        if keyval == Gdk.KEY_f and state & Gdk.ModifierType.CONTROL_MASK:
            if self.search_entry:
                self.search_entry.grab_focus()
            return True
        return False

    def _build_content(self) -> Gtk.Widget:
        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        header = Adw.HeaderBar()
        header.set_title_widget(
            Gtk.Label(label="Hyprland 快捷鍵", css_classes=["title"])
        )
        self.search_entry = Gtk.SearchEntry(placeholder_text="搜尋快捷鍵、功能或分類")
        self.search_entry.set_width_chars(30)
        self.search_entry.connect("search-changed", self._on_search_changed)
        header.pack_end(self.search_entry)
        root.append(header)

        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.CROSSFADE)
        self.stack.add_titled(self._category_page(None), "all", "全部")
        for category in CATEGORY_ORDER:
            category_bindings = [
                binding for binding in self.bindings if binding.category == category
            ]
            if category_bindings:
                self.stack.add_titled(self._category_page(category), category, category)
        self.stack.add_titled(self._search_page([]), "search", "搜尋結果")

        sidebar = Gtk.StackSidebar(stack=self.stack)
        sidebar.set_vexpand(True)
        sidebar.add_css_class("sidebar")
        paned = Gtk.Paned.new(Gtk.Orientation.HORIZONTAL)
        paned.set_start_child(sidebar)
        paned.set_end_child(self.stack)
        paned.set_resize_start_child(False)
        paned.set_shrink_start_child(False)
        paned.set_position(180)
        root.append(paned)
        return root

    def _error_page(self, message: str) -> Gtk.Widget:
        page = Adw.StatusPage(title="無法載入快捷鍵", description=message)
        page.set_vexpand(True)
        return page

    def _on_search_changed(self, entry: Gtk.SearchEntry) -> None:
        if not self.stack:
            return
        query = entry.get_text().strip()
        if not query:
            self.stack.set_visible_child_name("all")
            return
        results = [
            binding
            for binding in self.bindings
            if query.casefold() in binding.searchable
        ]
        current = self.stack.get_child_by_name("search")
        if current:
            self.stack.remove(current)
        self.stack.add_titled(self._search_page(results, query), "search", "搜尋結果")
        self.stack.set_visible_child_name("search")

    def _category_page(self, category: str | None) -> Gtk.Widget:
        if category is None:
            sections = [
                (
                    name,
                    [binding for binding in self.bindings if binding.category == name],
                )
                for name in CATEGORY_ORDER
            ]
        else:
            sections = [
                (
                    category,
                    [
                        binding
                        for binding in self.bindings
                        if binding.category == category
                    ],
                )
            ]

        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=24)
        content.set_margin_top(24)
        content.set_margin_bottom(24)
        content.set_margin_start(28)
        content.set_margin_end(28)
        for name, bindings in sections:
            if not bindings:
                continue
            content.append(
                Gtk.Label(label=name, xalign=0, css_classes=["section-title"])
            )
            grid = Gtk.FlowBox()
            grid.set_selection_mode(Gtk.SelectionMode.NONE)
            grid.set_column_spacing(14)
            grid.set_row_spacing(14)
            grid.set_min_children_per_line(1)
            grid.set_max_children_per_line(2)
            grid.set_homogeneous(True)
            for binding in bindings:
                grid.insert(self._binding_card(binding), -1)
            content.append(grid)

        scroll = Gtk.ScrolledWindow()
        scroll.set_child(content)
        scroll.set_vexpand(True)
        return scroll

    def _search_page(self, results: list[Binding], query: str = "") -> Gtk.Widget:
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        content.set_margin_top(24)
        content.set_margin_bottom(24)
        content.set_margin_start(28)
        content.set_margin_end(28)
        if not results:
            content.append(
                Adw.StatusPage(
                    title="找不到相符的快捷鍵",
                    description="請嘗試輸入分類、按鍵或英文別名。",
                )
            )
        else:
            for binding in results:
                row = Gtk.Box(
                    orientation=Gtk.Orientation.HORIZONTAL,
                    spacing=18,
                    css_classes=["search-row"],
                )
                row.append(
                    Gtk.Label(
                        label=binding.category, xalign=0, css_classes=["category-chip"]
                    )
                )
                shortcut = Gtk.Label(xalign=0, css_classes=["shortcut"])
                shortcut.set_markup(highlight(binding.shortcut, query))
                shortcut.set_hexpand(True)
                action = Gtk.Label(xalign=0, css_classes=["action"])
                action.set_markup(highlight(binding.action, query))
                row.append(shortcut)
                row.append(action)
                content.append(row)

        scroll = Gtk.ScrolledWindow()
        scroll.set_child(content)
        scroll.set_vexpand(True)
        return scroll

    @staticmethod
    def _binding_card(binding: Binding) -> Gtk.FlowBoxChild:
        card = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=8,
            css_classes=["binding-card"],
        )
        card.set_margin_top(16)
        card.set_margin_bottom(16)
        card.set_margin_start(18)
        card.set_margin_end(18)
        shortcut = Gtk.Label(label=binding.shortcut, xalign=0, css_classes=["shortcut"])
        action = Gtk.Label(label=binding.action, xalign=0, css_classes=["action"])
        action.set_wrap(True)
        card.append(shortcut)
        card.append(action)
        child = Gtk.FlowBoxChild()
        child.set_child(card)
        return child


if __name__ == "__main__":
    app = CheatSheetApplication()
    sys.exit(app.run(sys.argv))
