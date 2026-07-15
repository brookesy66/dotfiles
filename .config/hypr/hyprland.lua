-- Hyprland Lua config — ported from hyprland.conf
-- Target: Hyprland 0.55.4 (hyprlang deprecated since 0.55, Lua is the new format)
-- Docs: https://wiki.hypr.land/Configuring/Start/
--
-- NOTE: if this file exists, Hyprland loads it INSTEAD of hyprland.conf.
-- To fall back to the old config, rename/remove this file and restart Hyprland.

--hl.config({ debug = { disable_logs = false } })


------------------
---- MONITORS ----
------------------

-- https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({ output = "DP-1", mode = "3840x2160", position = "0x0", scale = 1.5 })
hl.monitor({ output = "DP-2", mode = "1920x1080", position="2560x0" , scale = 1, disabled = true})
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "auto-right", scale = 3, disabled = true })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "wofi --show drun"


-------------------
---- AUTOSTART ----
-------------------

-- https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("waybar")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("udiskie")
    -- screen sharing: make sure xdg-desktop-portal-hyprland gets the required vars
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    -- start the XWayland->Wayland screencast bridge so X11 apps (Zoom, XWayland browsers) can share screen
    hl.exec_cmd("xwaylandvideobridge")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- toolkit-specific scale (was 2)
hl.env("GDK_SCALE", "2")

hl.config({
    cursor = {
        no_hardware_cursors = false,
    },
    -- unscale XWayland
    xwayland = {
        force_zero_scaling = true,
    },
})


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,

        active_opacity   = 0.95,
        inactive_opacity = 0.9,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 8,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Bezier curves (https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/)
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

hl.config({
    dwindle = {
        preserve_split       = true,
        special_scale_factor = 0.98,
        force_split          = 2,
    },
    master = {
        new_status = "master",
    },
    scrolling = {
        direction = "down"
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- gestures (disabled in original)
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Example per-device config
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN",        hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Q",     hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E",     hl.dsp.exit())
hl.bind(mainMod .. " + M",             hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SPACE",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",             hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",             hl.dsp.window.pseudo())          -- dwindle
hl.bind(mainMod .. " + Q",             hl.dsp.layout("togglesplit"))    -- dwindle
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + CONTROL + M",   hl.dsp.exec_cmd("pavucontrol"))
hl.bind(mainMod .. " + TAB",           hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + SHIFT + R",     hl.dsp.exec_cmd("hyprctl reload"))

-- Toggle TV output (HDMI-A-1) vs PC screens (ported from toggle_tv.sh)
hl.bind(mainMod .. " + SHIFT + P", function()
    -- Decide direction from DP-1 (primary desk monitor), NOT the TV. This way, if
    -- the screens are ever off, the toggle ALWAYS brings them back -- you can't get
    -- stuck with every output dark. (A TV-based check could: if the TV reads off
    -- while screens are also off, it would keep trying to wake the TV forever.)
    local dp1 = hl.get_monitor("DP-1")
    if dp1 and not dp1.disabled then
        -- PC screens are on -> switch to TV
        hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x0", scale = 3, disabled = false })
        hl.monitor({ output = "DP-1", disabled = true })
        hl.monitor({ output = "DP-2", disabled = true })
        hl.timer(function()
            hl.dispatch(hl.dsp.dpms({ action = "on", monitor = "HDMI-A-1" }))
        end, { timeout = 1000, type = "oneshot" })
        hl.exec_cmd("notify-send 'TV mode on'")
    else
        -- PC screens are off (TV mode, or a jammed all-dark state) -> restore them
        hl.monitor({ output = "HDMI-A-1", disabled = true })
        hl.monitor({ output = "DP-1", mode = "3840x2160", position = "0x0", scale = 1.5, disabled = false })
        hl.monitor({ output = "DP-2", mode = "1920x1080", position = "2560x0", scale = 1, disabled = true })
        -- force panels out of DPMS/power-save; re-enabling alone can leave them
        -- logically on but physically asleep (esp. nvidia). Timer delay avoids
        -- racing the mode-set before the outputs are ready.
        hl.timer(function()
            hl.dispatch(hl.dsp.dpms({ action = "on" }))
        end, { timeout = 1000, type = "oneshot" })
        hl.exec_cmd("notify-send 'TV mode off'")
    end
end)

-- Toggle the DP-2 monitor (ported from toggle_second_screen.sh)
hl.bind(mainMod .. " + SHIFT + D", function()
    local mon = hl.get_monitor("DP-2")
    if mon and not mon.disabled then
        hl.exec_cmd("notify-send 'Disabling DP-2...'")
        hl.monitor({ output = "DP-2", disabled = true })
    else
        hl.exec_cmd("notify-send 'Enabling DP-2...'")
        hl.monitor({ output = "DP-2", mode = "1920x1080", position = "2560x0", scale = 1, disabled = false })
    end
end)

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


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.workspace_rule( { workspace = "10", layout = "scrolling" } )

-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
hl.window_rule({
    -- Ignore maximize requests from all apps
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- xwaylandvideobridge rules for screen sharing
hl.window_rule({
    name  = "xwayland-video-bridge-fixes",
    match = { class = "xwaylandvideobridge" },

    no_initial_focus = true,
    no_focus         = true,
    no_anim          = true,
    no_blur          = true,
    max_size         = "1 1",
    opacity          = 0.0,
})

hl.config({
    opengl = {
        nvidia_anti_flicker = 0,
        -- force_introspection = 2, -- broken @ 0.48.0
    },
    debug = {
        damage_tracking = 2,
    },
})
