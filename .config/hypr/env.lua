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
