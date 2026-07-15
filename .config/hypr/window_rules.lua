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
    debug = {
        damage_tracking = 2,
    },
})
