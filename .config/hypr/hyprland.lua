-- Docs: https://wiki.hypr.land/Configuring/Start/

-- `hl` is a global set by Hyprland, so it's available in every required module.

-- Put this config directory on package.path so require() finds sibling files.
-- Prefer self-locating via debug (no hardcoded path); fall back to the XDG/HOME
-- config dir if the debug library isn't available in Hyprland's Lua state.
local here = debug and debug.getinfo(1, "S").source:match("@(.*/)")
    or ((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr/")
package.path = here .. "?.lua;" .. package.path

require("monitors")
require("env")
require("look_and_feel")
require("input")
require("autostart")
require("keybinds")       -- pulls in programs + functions
require("workspaces")
require("window_rules")
