-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- VA-API -> NVDEC hardware video decode (libva-nvidia-driver)
hl.env("NVD_BACKEND", "direct")
-- required for the nvidia VA-API shim inside Firefox's decode process;
-- deliberate tradeoff: relaxes the RDD sandbox (see CONFIG_REVIEW.md)
hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")

-- run Electron/CEF apps native Wayland (no XWayland flicker, sharp at 1.5x scale)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- integer-only GTK scale; only affects X11/XWayland GTK apps (renders them
-- ~33% oversized on the 1.5x monitor — re-enable if X11 GTK apps look tiny)
-- hl.env("GDK_SCALE", "2")

-- Qt apps (VLC etc.): prefer native Wayland so they scale to the monitor
-- instead of rendering tiny under XWayland; fall back to X11 if unavailable
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

hl.config({
    cursor = {
        no_hardware_cursors = false,
    },
    -- unscale XWayland
    xwayland = {
        force_zero_scaling = true,
    },
})
