extends Node

const GOLD := Color(1, 0.843, 0, 1)
const WHITE := Color(1, 1, 1, 1)

const EVENTS := ["player_turn_start", "ball_started"]

func _ready() -> void:
	for event in EVENTS:
		MPF.server.add_event_handler(event, _on_turn_event)
	call_deferred("_update_highlight")

func _exit_tree() -> void:
	for event in EVENTS:
		MPF.server.remove_event_handler(event, _on_turn_event)

func _on_turn_event(_kwargs = null) -> void:
	call_deferred("_update_highlight")

func _update_highlight() -> void:
	if not MPF.game or MPF.game.player.is_empty():
		return
	var current: int = MPF.game.player.get("number", 0)
	if current <= 0:
		return
	var overlay := get_parent()
	if not overlay:
		return
	for i in range(1, 5):
		var tag: Label = overlay.get_node_or_null("PlayerStrip/P%d/P%dTag" % [i, i])
		var score: Label = overlay.get_node_or_null("PlayerStrip/P%d/P%dScore" % [i, i])
		if not tag or not score:
			continue
		var color := GOLD if i == current else WHITE
		tag.add_theme_color_override("font_color", color)
		score.add_theme_color_override("font_color", color)
