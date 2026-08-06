-----------------------
---- WINDOW RULES ----
-----------------------

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

hl.window_rule({
    -- utility windows are awkward tiled; float them at a sane size
    -- (40%x60% of DP-1 logical 2560x1440 — percent size isn't supported here)
    name  = "float-utility-windows",
    match = { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol|blueman-manager|nm-connection-editor)$" },

    float = true,
    size  = "1024 864",
})

hl.window_rule({
    -- Firefox Picture-in-Picture: float and keep on top across workspaces
    name  = "firefox-pip",
    match = { title = "^Picture-in-Picture$" },

    float = true,
    pin   = true,
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
    },
})
