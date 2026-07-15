-------------------
---- FUNCTIONS ----
-------------------

-- Abstract display-toggle logic, kept out of keybinds.lua so the bindings stay
-- declarative. Reuses the monitor profiles defined in monitors.lua.

local mon = require("monitors")

local M = {}

-- Toggle TV output (HDMI-A-1) vs PC screens (ported from toggle_tv.sh)
function M.toggle_tv()
    -- Decide direction from DP-1 (primary desk monitor), NOT the TV. This way, if
    -- the screens are ever off, the toggle ALWAYS brings them back -- you can't get
    -- stuck with every output dark. (A TV-based check could: if the TV reads off
    -- while screens are also off, it would keep trying to wake the TV forever.)
    local dp1 = hl.get_monitor("DP-1")
    if dp1 and not dp1.disabled then
        -- PC screens are on -> switch to TV
        hl.monitor({ output = mon.tv.output, mode = mon.tv.mode, position = mon.tv.position, scale = mon.tv.scale, disabled = false })
        hl.monitor({ output = "DP-1", disabled = true })
        hl.monitor({ output = "DP-2", disabled = true })
        hl.timer(function()
            hl.dispatch(hl.dsp.dpms({ action = "on", monitor = "HDMI-A-1" }))
        end, { timeout = 1000, type = "oneshot" })
        hl.exec_cmd("notify-send 'TV mode on'")
    else
        -- PC screens are off (TV mode, or a jammed all-dark state) -> restore them
        hl.monitor({ output = "HDMI-A-1", disabled = true })
        hl.monitor({ output = mon.dp1_default.output, mode = mon.dp1_default.mode, position = mon.dp1_default.position, scale = mon.dp1_default.scale, disabled = false })
        hl.monitor({ output = mon.dp2.output, mode = mon.dp2.mode, position = mon.dp2.position, scale = mon.dp2.scale, disabled = true })
        -- force panels out of DPMS/power-save; re-enabling alone can leave them
        -- logically on but physically asleep (esp. nvidia). Timer delay avoids
        -- racing the mode-set before the outputs are ready.
        hl.timer(function()
            hl.dispatch(hl.dsp.dpms({ action = "on" }))
        end, { timeout = 1000, type = "oneshot" })
        hl.exec_cmd("notify-send 'TV mode off'")
    end
end

-- Toggle the DP-2 monitor (ported from toggle_second_screen.sh)
function M.toggle_dp2()
    local m = hl.get_monitor("DP-2")
    if m and not m.disabled then
        hl.exec_cmd("notify-send 'Disabling DP-2...'")
        hl.monitor({ output = "DP-2", disabled = true })
    else
        hl.exec_cmd("notify-send 'Enabling DP-2...'")
        hl.monitor({ output = mon.dp2.output, mode = mon.dp2.mode, position = mon.dp2.position, scale = mon.dp2.scale, disabled = false })
    end
end

return M
