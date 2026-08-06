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
    -- clipboard history (SUPER+V to pick from it)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- screen sharing: make sure xdg-desktop-portal-hyprland gets the required vars
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    -- load Xft.dpi=144 into XWayland so X11 Qt apps (VLC) scale to 1.5x
    hl.exec_cmd("xrdb -merge ~/.Xresources")
    -- start the XWayland->Wayland screencast bridge so X11 apps (Zoom, XWayland browsers) can share screen
    hl.exec_cmd("xwaylandvideobridge")
end)
