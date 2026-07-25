extends Node

## Hides the gameplay HUD during the game-start intro video.
## MPF lifecycle gating can miss stale widgets; visibility is the reliable backstop.

const INTRO_VAR := "game_start_intro_playing"
const HIDE_EVENTS := ["game_started"]
const SHOW_EVENTS := ["game_start_intro_done", "ball_will_end", "tilt"]

func _ready() -> void:
	for event_name in HIDE_EVENTS:
		MPF.server.add_event_handler(event_name, _on_hide_event)
	for event_name in SHOW_EVENTS:
		MPF.server.add_event_handler(event_name, _on_show_event)
	if MPF.game:
		MPF.game.game_started.connect(_on_hide_event)
		MPF.game.machine_update.connect(_on_machine_var)
	call_deferred("_sync_visibility")

func _exit_tree() -> void:
	for event_name in HIDE_EVENTS:
		MPF.server.remove_event_handler(event_name, _on_hide_event)
	for event_name in SHOW_EVENTS:
		MPF.server.remove_event_handler(event_name, _on_show_event)
	if MPF.game:
		if MPF.game.game_started.is_connected(_on_hide_event):
			MPF.game.game_started.disconnect(_on_hide_event)
		if MPF.game.machine_update.is_connected(_on_machine_var):
			MPF.game.machine_update.disconnect(_on_machine_var)

func _on_hide_event(_kwargs = null) -> void:
	_set_overlay_visible(false)

func _on_show_event(_kwargs = null) -> void:
	_set_overlay_visible(true)

func _on_machine_var(var_name: String, value) -> void:
	if var_name == INTRO_VAR:
		_set_overlay_visible(value == 0)

func _sync_visibility() -> void:
	if not MPF.game:
		return
	var intro_playing = MPF.game.machine_vars.get(INTRO_VAR, 0)
	_set_overlay_visible(intro_playing == 0)

func _set_overlay_visible(is_visible: bool) -> void:
	var overlay := get_parent()
	if overlay:
		overlay.visible = is_visible
