# -*- coding: utf-8 -*-

import re
import string
from xkeysnail.transform import *

# define timeout for multipurpose_modmap
define_timeout(1)

# [Global modemap] Change modifier keys as in xmodmap
define_modmap({Key.CAPSLOCK: Key.LEFT_CTRL})

# [Multipurpose modmap] Give a key two meanings. A normal key when pressed and
# released, and a modifier key when held down with another key. See Xcape,
# Carabiner and caps2esc for ideas and concept.
define_multipurpose_modmap(
    # Enter is enter when pressed and released. Control when held down.
    {Key.ENTER: [Key.ENTER, Key.RIGHT_CTRL]}
    # Capslock is escape when pressed and released. Control when held down.
    # {Key.CAPSLOCK: [Key.ESC, Key.LEFT_CTRL]
    # To use this example, you can't remap capslock with define_modmap.
)

# [Conditional multipurpose modmap] Multipurpose modmap in certain conditions,
# such as for a particular device.
define_conditional_multipurpose_modmap(
    lambda wm_class, device_name: device_name.startswith("Microsoft"),
    {
        # Left shift is open paren when pressed and released.
        # Left shift when held down.
        Key.LEFT_SHIFT: [Key.KPLEFTPAREN, Key.LEFT_SHIFT],
        # Right shift is close paren when pressed and released.
        # Right shift when held down.
        Key.RIGHT_SHIFT: [Key.KPRIGHTPAREN, Key.RIGHT_SHIFT],
    },
)


# Keybindings for Zeal https://github.com/zealdocs/zeal/
define_keymap(
    re.compile("Zeal"),
    {
        # Ctrl+s to focus search area
        K("C-s"): K("C-k"),
    },
    "Zeal",
)

# Brave and Firefox
define_keymap(
    re.compile("Brave-browser|Firefox"),
    {
        # Brave search tabs
        K("M-Shift-a"): K("C-Shift-a"),
        # Developer tools
        K("M-Super-i"): K("C-Shift-i"),
        # Prevent accidentally sending a message on GitHub
        K("C-ENTER"): K("Shift-ENTER"),
    },
    "Brave and Firefox",
)

# Firefox
def firefox_mapping():
    mapping = {}

    # Select a tab by Cmd+number
    for i in range(0, 10):
        mapping[K("M-KEY_" + str(i))] = K("Super-KEY_" + str(i))

    define_keymap(re.compile("Firefox"), mapping, "Firefox")


firefox_mapping()

# Keybindings for Slack
define_keymap(
    re.compile("Slack"),
    {
        # Prevent accidentally sending a message
        K("C-ENTER"): K("Shift-ENTER"),
    },
    "Slack"
)

# Gnome Terminal
def gnome_terminal_mapping():
    mapping = {
        # Jump to the previous open tab
        K("M-Shift-LEFT_BRACE"): K("C-PAGE_UP"),
        # Jump to the next open tab
        K("M-Shift-RIGHT_BRACE"): K("C-PAGE_DOWN"),
        # Move Tab to the Left
        K("Super-M-Shift-LEFT_BRACE"): K("Shift-C-PAGE_UP"),
        # Move Tab to the Right
        K("Super-M-Shift-RIGHT_BRACE"): K("Shift-C-PAGE_DOWN"),
    }

    # Select a tab by Cmd+number
    for i in range(0, 10):
        mapping[K("M-KEY_" + str(i))] = K("Super-KEY_" + str(i))

    define_keymap(re.compile("Gnome-terminal"), mapping, "Gnome Terminal")


gnome_terminal_mapping()

# macOS-like keybindings in non-Emacs applications
#
# Note: I swapped left-alt and left-super via Gnome tweaks because
#       some programs such as Electron-based apps and Firefox are
#       activating their menu when alt key pressing.
def mac_like_mapping():
    mapping = {
        # History back
        K("M-LEFT_BRACE"): K("Super-LEFT"),
        # History forward
        K("M-RIGHT_BRACE"): K("Super-RIGHT"),
        # Jump to the previous open tab
        K("M-Shift-LEFT_BRACE"): K("C-Shift-TAB"),
        # Jump to the next open tab
        K("M-Shift-RIGHT_BRACE"): K("C-TAB"),
        # Jump to the previous match to your Find Bar search
        K("M-Shift-g"): K("C-Shift-g"),
        # Reopen previously closed tabs in the order they were closed
        K("M-Shift-t"): K("C-Shift-t"),
        # Make everything on the page smaller
        K("M-EQUAL"): K("C-EQUAL"),
        # Make everything on the page bigger
        K("M-MINUS"): K("C-MINUS"),
        # Show preference panel
        K("M-COMMA"): K("C-COMMA"),
    }

    for c in string.ascii_lowercase:
        mapping[K("M-" + c)] = K("C-" + c)

    for i in range(0, 10):
        mapping[K("M-KEY_" + str(i))] = K("C-KEY_" + str(i))

    define_keymap(
        lambda wm_class: wm_class not in ("Emacs", "Gnome-terminal"),
        mapping,
        "macOS-like keys",
    )


mac_like_mapping()


# copied from
# https://github.com/NixOS/nixpkgs/blob/22.11/pkgs/tools/X11/xkeysnail/browser-emacs-bindings.py#L5-L21

aa = False


def aa_setvar(v):
    def _aa_setvar():
        transform._mark_set = False
        global aa
        aa = v

    return _aa_setvar


def aa_ifvar():
    def _aa_ifvar():
        transform._mark_set = False
        global aa
        if aa:
            aa = False
            return K("esc")
        return K("enter")

    return _aa_ifvar


def aa_flipmark():
    def _aa_flipmark():
        transform._mark_set = not transform._mark_set

    return _aa_flipmark


# Emacs-like keybindings in non-Emacs applications
define_keymap(
    lambda wm_class: wm_class not in ("Emacs", "Gnome-terminal", "Virt-manager"),
    {
        # ESC
        K("C-LEFT_BRACE"): Key.ESC,
        # Cursor
        K("C-b"): with_mark(K("left")),
        K("C-f"): with_mark(K("right")),
        K("C-p"): with_mark(K("up")),
        K("C-n"): with_mark(K("down")),
        K("C-h"): with_mark(K("backspace")),
        # Forward/Backward word
        K("M-b"): with_mark(K("C-left")),
        K("M-f"): with_mark(K("C-right")),
        # Beginning/End of line
        K("C-a"): with_mark(K("home")),
        K("C-e"): with_mark(K("end")),
        # Page up/down
        K("M-v"): with_mark(K("page_up")),
        K("C-v"): with_mark(K("page_down")),
        # Beginning/End of file
        K("M-Shift-comma"): with_mark(K("C-home")),
        K("M-Shift-dot"): with_mark(K("C-end")),
        # Newline
        K("C-m"): K("enter"),
        # K("C-j"): K("enter"),
        K("C-o"): [K("enter"), K("left")],
        # Copy
        K("C-w"): [K("C-x"), set_mark(False)],
        K("M-w"): [K("C-c"), set_mark(False)],
        K("C-y"): [K("C-v"), set_mark(False)],
        # Delete
        K("C-d"): [K("delete"), set_mark(False)],
        K("M-d"): [K("C-delete"), set_mark(False)],
        # Kill line
        K("C-k"): [K("Shift-end"), K("C-x"), set_mark(False)],
        # unix-line-discard
        K("C-u"): [K("Shift-home"), K("C-x"), set_mark(False)],
        # Undo
        K("C-slash"): [K("C-z"), set_mark(False)],
        K("C-Shift-ro"): K("C-z"),
        # Mark
        K("C-space"): aa_flipmark(),
        K("C-M-space"): with_or_set_mark(K("C-right")),
        # Search
        K("C-s"): [K("F3"), aa_setvar(True)],
        K("C-r"): [K("Shift-F3"), aa_setvar(True)],
        K("M-Shift-key_5"): K("C-h"),
        K("enter"): aa_ifvar(),
        # Cancel
        K("C-g"): [K("C-g"), aa_setvar(False)],
        # Tab
        K("C-i"): Key.TAB,
        # Escape
        K("C-q"): escape_next_key,
        # C-x YYY
        K("C-x"): {
            # C-x h (select all)
            K("h"): [K("C-home"), K("C-a"), set_mark(True)],
            # C-x C-f (open)
            K("C-f"): K("C-o"),
            # C-x C-s (save)
            K("C-s"): K("C-s"),
            # C-x k (kill tab)
            K("k"): K("C-f4"),
            # C-x C-c (exit)
            K("C-c"): K("C-q"),
            # cancel
            K("C-g"): pass_through_key,
            # C-x u (undo)
            K("u"): [K("C-z"), set_mark(False)],
        },
    },
    "Emacs-like keys",
)
