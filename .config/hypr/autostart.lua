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
