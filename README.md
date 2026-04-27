# CTA_Pinball

Coming to America Pinball Machine

Created by Ricardo E James II

## How to Run

- Requirements: MPF installed (virtualenv path set in `gmc.cfg`), Godot 4.5 with the GMC addon enabled.
- Local setup: run `tools/setup_dev_env.sh` to create `.venv` and install MPF.
- Configure MPF path: edit `gmc.cfg` → set `executable_path` to your MPF `mpf(.exe)`.
- Virtual run: in `gmc.cfg`, set `spawn_mpf=true` and `mpf_args="-x"` for the virtual platform. GMC adds the machine path and text-console flag.
- Hardware run: set the FAST port in `config/config.yaml` under `fast.net.port` (e.g., `COM5`).
- Start from Godot: open the project, run the main scene; GMC will connect to MPF if configured.
- Keyboard (simulated switches): `Enter` = start, `v` = left flipper, `z` = right flipper.

## Developer Notes

- Layout
  - MPF configs: `config/*.yaml` (hardware, switches, coils, ball_devices, displays, modes list).
  - Modes: `modes/<mode>/config/<mode>.yaml`.
  - GMC: `addons/mpf-gmc/*`; slides in `slides/*.tscn` (plus overlays/scripts).
  - Media/audio: `video/*`, `sounds/*`.

- Mode Flow
  - Attract: starts on `reset_complete` → shows `slides/attract.tscn` and plays opening music.
  - Base: starts on `game_started`, queues location selection, displays `slides/location_choice.tscn`.
  - Selection: flippers set cursor; `s_start_active` confirms → posts either `start_mode_queens` or `start_mode_zamunda` and ends base.
  - Hubs: `queens` → `arriving_in_queens`; `zamunda` → `the_prince_awakens`.

- Inputs & Events
  - Switch IDs: `s_left_flipper`, `s_right_flipper`, `s_start`, etc. MPF emits `_active` events automatically.
  - Keyboard mapping for dev: set in `gmc.cfg` (e.g., `enter` → `s_start`, `v` → `s_left_flipper`, `z` → `s_right_flipper`).

- Adding a New Mode
  - Add mode name to `config/modes.yaml`.
  - Create `modes/<name>/config/<name>.yaml` with `mode: start_events`, `stop_events`, and desired `shots`, `counters`, `event_player`, `slide_player`, `sound_player`.
  - Kick off from a hub via an event like `start_mode_<name>`.

- Slides & Media
  - `slide_player` keys reference Godot scenes, e.g., `slides/location_choice.tscn`.
  - Prefer lightweight scenes that extend GMC/MPF base classes when applicable.

- Audio
  - Busses configured in `gmc.cfg` (`music`, `effects`, `voice`).
  - In `sound_player`, set `bus` and `action` (`play`, `stop`) to control layering.

- Hardware Notes
  - Set FAST NET port in `config/config.yaml` (`fast.net.port: COMx`) for real hardware.
  - Tune flipper `default_hold_power` to your coils/mechs; current values are placeholders.

- Dev Tips
  - To run MPF directly: `.venv/bin/mpf . -t -x`.
  - Increase logging in `gmc.cfg` for debugging (e.g., `logging_game`, `logging_media`).
  - Common simulated inputs: `Enter` = start, `v` = left flipper, `z` = right flipper.
