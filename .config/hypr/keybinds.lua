---------------------
---- KEYBINDINGS ----
---------------------

local p  = require("programs")
local fn = require("functions")

local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN",        hl.dsp.exec_cmd(p.terminal))
hl.bind(mainMod .. " + SHIFT + Q",     hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E",     hl.dsp.exit())
hl.bind(mainMod .. " + M",             hl.dsp.exec_cmd(p.fileManager))
hl.bind(mainMod .. " + SPACE",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",             hl.dsp.exec_cmd(p.menu))
hl.bind(mainMod .. " + P",             hl.dsp.window.pseudo())          -- dwindle
hl.bind(mainMod .. " + Q",             hl.dsp.layout("togglesplit"))    -- dwindle
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + CONTROL + M",   hl.dsp.exec_cmd("pavucontrol"))
hl.bind(mainMod .. " + TAB",           hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + SHIFT + R",     hl.dsp.exec_cmd("hyprctl reload"))

-- Toggle TV output (HDMI-A-1) vs PC screens (see functions.lua)
hl.bind(mainMod .. " + SHIFT + P", fn.toggle_tv)

-- Toggle the DP-2 monitor (see functions.lua)
hl.bind(mainMod .. " + SHIFT + D", fn.toggle_dp2)

-- toggle opacity
hl.bind(mainMod .. " + O",             hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }))

-- Move focus with mainMod + h/l/k/j
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Move windows with keyboard
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- Move workspace to monitor
hl.bind("CTRL + SUPER + left",  hl.dsp.workspace.move({ monitor = "l" }))
hl.bind("CTRL + SUPER + right", hl.dsp.workspace.move({ monitor = "r" }))

-- Switch workspaces (mainMod + [0-9]) and move active window to workspace (+ SHIFT)
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Groups
hl.bind(mainMod .. " + t", hl.dsp.group.toggle())

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Resize active window
hl.bind(mainMod .. " + SHIFT + o", hl.dsp.window.resize({ x = 35,  y = 0,   relative = true }))
hl.bind(mainMod .. " + SHIFT + y", hl.dsp.window.resize({ x = -35, y = 0,   relative = true }))
hl.bind(mainMod .. " + SHIFT + i", hl.dsp.window.resize({ x = 0,   y = -35, relative = true }))
hl.bind(mainMod .. " + SHIFT + u", hl.dsp.window.resize({ x = 0,   y = 35,  relative = true }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys (volume / brightness)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),  { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Screencap
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
