# Hyprland Config Review — 2026-08-06

Reviewed against Hyprland 0.56.1 docs (wiki.hypr.land), the current NVIDIA wiki
page, and common patterns from popular community setups. Items marked
**[APPLIED]** were changed on 2026-08-06; everything else is still open.

Overall: clean, well-organized config. The module split and the reusable
monitor profiles in `monitors.lua` are better than most dotfiles out there.

## Actual issues

1. **TV mode inconsistency (`monitors.lua` / `functions.lua`).** The TV's full
   EDID list includes `3840x2160@119.88`, so the startup line's `@120` request
   matches fine. But the `M.tv` profile used by `toggle_tv` says `@60`, so
   toggling TV mode brings it up at 60 Hz while a fresh boot declares 120 Hz.
   Pick one — `@120` in the profile if the HDMI cable is 2.1-rated (48 Gbps
   needed for 4K120 at full chroma). See "TV gaming notes" below.

2. **No screen lock.** DECLINED (2026-08-06) — user explicitly doesn't want
   the PC to lock. Original suggestion kept below for reference.
   `hyprlock` is not installed and hypridle only does DPMS
   — the machine wakes straight into the session, and there's no
   suspend/lock handling. Recommended `hypridle.conf` additions:

   ```ini
   general {
       lock_cmd = pidof hyprlock || hyprlock
       before_sleep_cmd = loginctl lock-session
   }
   listener {
       timeout = 600
       on-timeout = loginctl lock-session
   }
   ```

   The TV-mode `systemd-inhibit` lock will still suppress these correctly.

   Note: the existing hypridle listener's odd-looking
   `hyprctl dispatch 'hl.dsp.dpms({...})'` syntax was tested and **works** —
   Lua-config Hyprland evaluates the dispatch argument as Lua.

3. **`brightnessctl -r` on resume restores nothing** — nothing ever saves
   state with `brightnessctl -s`. Either save on-timeout or drop the `-r`.

4. **[APPLIED]** Polkit authentication agent: `hyprpolkitagent` installed and
   running via `systemctl --user enable --now hyprpolkitagent.service`
   (auto-starts with graphical-session.target, restarts on crash; no
   autostart.lua entry needed). Registered listener confirmed in the journal.

5. **XWayland app scaling.** With `xwayland:force_zero_scaling`, X11 apps
   render at raw pixels and need toolkit-level scaling. **[APPLIED]** Final
   setup (2026-08-06):
   - `GDK_SCALE=2` commented out in `env.lua` (nothing looked oversized;
     re-enable if an X11 GTK app ever looks tiny).
   - Qt apps: `QT_QPA_PLATFORM=wayland;xcb`,
     `QT_AUTO_SCREEN_SCALE_FACTOR=1`,
     `QT_WAYLAND_DISABLE_WINDOWDECORATION=1` added to `env.lua`.
   - VLC 3 hard-disables Qt's Wayland backend (verified: still XWayland even
     with the platform hint), so `.Xresources` now sets `Xft.dpi: 144`
     (96 × 1.5 monitor scale; old 163 commented out) and `autostart.lua` runs
     `xrdb -merge ~/.Xresources`. Verified via screenshots: VLC UI renders at
     1.5× with this, tiny without.

## NVIDIA (vs current wiki recommendations)

- **[APPLIED]** `ELECTRON_OZONE_PLATFORM_HINT=auto` added to `env.lua` —
  Electron apps (VSCode, Obsidian, Vesktop…) run native Wayland: no XWayland
  flicker, sharp at fractional scale.
- **[APPLIED]** VA-API hardware video decode: `libva-nvidia-driver` +
  `libva-utils` installed; `NVD_BACKEND=direct` and
  `MOZ_DISABLE_RDD_SANDBOX=1` in `env.lua`;
  `media.ffmpeg.vaapi.enabled=true` via the default profile's `user.js`.
  `vainfo` verified NVDEC exposes H.264/HEVC/VP9/AV1. Takes effect after
  Hyprland restart (env) + Firefox restart (pref). Verify: play 4K YouTube,
  watch the `dec` column in `nvidia-smi dmon`. Security note: the RDD-sandbox
  relaxation is required by the nvidia shim — a decoder exploit would land in
  a less-confined process. Delete `user.js` + the two env lines to revert.
- **[APPLIED]** `debug:damage_tracking = 2` removed from `window_rules.lua` —
  it was the default value, and the wiki warns against setting it at all.
- `opengl:nvidia_anti_flicker = 0` trades flicker-safety for latency — fine to
  keep if no flicker is observed.
- **[APPLIED]** Stray `nohup.out` (a July hyprpaper crash log — assertion
  failure on wake-from-DPMS) deleted from the config dir.

## Performance / hygiene

- **[APPLIED]** Blur tuned in `look_and_feel.lua`: `size 8 / passes 1` →
  `size 5 / passes 3` (smoother falloff), plus `popups = true` so
  wofi/menus blur too.
- **[APPLIED]** Leftover sample device `epic-mouse-v1` removed from
  `input.lua`.
- `disable_hyprland_logo = true` would skip loading unused logo/wallpaper
  assets (hyprpaper covers them anyway). **Deliberately not applied.**
- **Daemon supervision:** consider systemd user services for waybar /
  hypridle / hyprpaper instead of exec-once — crashed daemons (like that
  hyprpaper crash) restart themselves.
- **`toggle_tv` kills hyprsunset with `pkill`** — hyprsunset 0.4 has IPC:
  `hyprctl hyprsunset identity` disables the tint without killing the
  process; cleaner and keeps the schedule intact.

## Usability ideas (from popular setups)

- **[APPLIED]** Clipboard history: `cliphist` installed; text+image
  `wl-paste --watch` lines in `autostart.lua`; `SUPER+V` → wofi picker in
  `keybinds.lua`. Watchers also started manually for the current session.
- **More screenshot binds:** declined (2026-08-06) — region→clipboard is
  enough.
- **[APPLIED]** Exit confirmation: `SUPER+SHIFT+E` now asks via wofi before
  exiting. Note: `hyprctl dispatch` args are evaluated as Lua in this build,
  so the shell side must call `hyprctl dispatch "hl.dsp.exit()"`, not
  `dispatch exit`.
- **[APPLIED]** Group styling: `group { col.border_* }` matches the
  active-border cyan/green gradient; groupbar font_size 12 / height 20.
- **[APPLIED]** Float rules: pavucontrol (old + `org.pulseaudio.` class
  names), blueman-manager, nm-connection-editor float at 1024x864 (percent
  size strings are ignored by the Lua rule path — verified empirically);
  Firefox Picture-in-Picture floats + pins. Note: pavucontrol restores its
  own remembered GTK size over the size rule.
- **Aesthetic:** `decoration:rounding_power = 4` with `rounding = 10` gives
  squircle corners. Skip animated `borderangle` loops — constant redraws are
  real GPU cost at 4K.

## TV gaming notes (4K TV, RTX 3070)

Full EDID modes worth knowing: `3840x2160@119.88`, `2560x1440@120`,
`1920x1080@119.88`. **[APPLIED]** `M.tv` profile bumped to `3840x2160@120` and
`misc:vrr = 2` (fullscreen-only adaptive sync) set. 4K120 needs an Ultra High
Speed HDMI cable + the LG input's Deep Color/Game Optimizer setting enabled —
black flashes/dropouts mean the cable; fall back to `@60` or `2560x1440@120`.
For low-latency gaming consider LG's Game Optimizer input mode (also unlocks
ALLM) and, if chasing latency, `allow_tearing = true` plus per-game
`immediate` window rules.

## Explicitly fine — don't touch

- Animation curves (current-gen defaults, look good).
- hyprpaper / hyprsunset configs (verified working via IPC).
- VRR/tearing for the desk monitors (both fixed 60 Hz).
- DP-2 position math (2560x0 is correct for DP-1 at 1.5 scale).
