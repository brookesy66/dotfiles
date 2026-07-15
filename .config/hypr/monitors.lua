------------------
---- MONITORS ----
------------------

-- https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Named monitor profiles are defined once here and returned so other modules
-- (functions.lua) can reuse the exact mode/position/scale values instead of
-- duplicating the magic numbers.

local M = {
    dp1_default = { output = "DP-1",     mode = "3840x2160",    position = "0x0",    scale = 1.5 },
    dp2         = { output = "DP-2",     mode = "1920x1080",    position = "2560x0", scale = 1 },
    tv          = { output = "HDMI-A-1", mode = "3840x2160@60", position = "0x0",    scale = 3 },
}

-- Default startup layout: desk primary on, second screen + TV off.
hl.monitor({ output = "DP-1", mode = "3840x2160", position = "0x0", scale = 1.5 })
hl.monitor({ output = "DP-2", mode = "1920x1080", position="2560x0" , scale = 1, disabled = true})
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "auto-right", scale = 3, disabled = true })

return M
