-------------------
---- FUNCTIONS ----
-------------------

-- Abstract display-toggle logic, kept out of keybinds.lua so the bindings stay
-- declarative. Reuses the monitor profiles defined in monitors.lua.

local mon = require("monitors")

local M = {}

-- Toggle TV output (HDMI-A-1) vs PC screens (ported from toggle_tv.sh)
function M.toggle_tv()
    -- decide mode from desk monitor
    local dp1 = hl.get_monitor(mon.dp1_default.output)
    if dp1 and not dp1.disabled then
        -- bring up auto-right to avoid conflict with monitor
        hl.monitor({ output = mon.tv.output, mode = mon.tv.mode, position = "auto-right", scale = mon.tv.scale, disabled = false })
        hl.timer(function()
            -- delay to allow screen on, means workspaces can be transferred
            hl.dispatch(hl.dsp.dpms({ action = "on", monitor = mon.tv.output }))
            hl.monitor({ output = mon.dp1_default.output, disabled = true })
            hl.monitor({ output = mon.dp2.output, disabled = true })
            hl.monitor({ output = mon.tv.output, mode = mon.tv.mode, position = mon.tv.position, scale = mon.tv.scale, disabled = false })
        end, { timeout = 1000, type = "oneshot" })
        -- hypridle: We hold a logind idle-inhibit lock (the same
        -- idea as Waybar's eye button, which uses the Wayland idle-inhibit protocol).
        -- hypridle honours it by default (general:ignore_systemd_inhibit = false), so
        -- it keeps running but never fires its DPMS-off timeout.
        hl.exec_cmd("pkill -x hyprsunset")
        hl.exec_cmd("systemd-inhibit --list | grep -q hypr-tv-idle-inhibit || systemd-inhibit --what=idle --who=hypr-tv-idle-inhibit --why='TV mode' --mode=block sleep infinity")
        hl.exec_cmd("notify-send 'TV mode on'")
    else
        -- bring up auto-right to avoid conflict with monitor
        hl.monitor({ output = mon.dp1_default.output, mode = mon.dp1_default.mode, position = "auto-right", scale = mon.dp1_default.scale, disabled = false })
        hl.monitor({ output = mon.dp2.output, mode = mon.dp2.mode, position = mon.dp2.position, scale = mon.dp2.scale, disabled = true })
        -- delay to allow screen on, means workspaces can be transferred
        hl.timer(function()
            hl.dispatch(hl.dsp.dpms({ action = "on" }))
            hl.monitor({ output = mon.tv.output, disabled = true })
            hl.monitor({ output = mon.dp1_default.output, mode = mon.dp1_default.mode, position = mon.dp1_default.position, scale = mon.dp1_default.scale, disabled = false })
        end, { timeout = 1000, type = "oneshot" })

        hl.exec_cmd("pgrep -x hyprsunset >/dev/null || hyprsunset")
        -- release the idle-inhibit lock
        hl.exec_cmd("kill \"$(systemd-inhibit --list | awk '/hypr-tv-idle-inhibit/{print $4}')\" 2>/dev/null")
        hl.exec_cmd("notify-send 'TV mode off'")
    end
end

-- Toggle the DP-2 monitor (ported from toggle_second_screen.sh)
function M.toggle_dp2()
    local m = hl.get_monitor(mon.dp2.output)
    if m and not m.disabled then
        hl.exec_cmd("notify-send 'Disabling DP-2...'")
        hl.monitor({ output = mon.dp2.output, disabled = true })
    else
        hl.exec_cmd("notify-send 'Enabling DP-2...'")
        hl.monitor({ output = mon.dp2.output, mode = mon.dp2.mode, position = mon.dp2.position, scale = mon.dp2.scale, disabled = false })
    end
end

return M
