extends MPFSlide

const GOLD := Color(1, 0.843, 0, 1)
const BRIGHT := Color(1, 1, 1, 1)
const DIM := Color(0.55, 0.55, 0.55, 1)

const EVENTS := ["set_location_queens", "set_location_zamunda"]

@onready var _queens_container: PanelContainer = $Margin/VBox/HBox/QueensCardContainer
@onready var _zamunda_container: PanelContainer = $Margin/VBox/HBox/ZamundaCardContainer
@onready var _queens_card: TextureRect = $Margin/VBox/HBox/QueensCardContainer/QueensCard
@onready var _zamunda_card: TextureRect = $Margin/VBox/HBox/ZamundaCardContainer/ZamundaCard

var _style_selected: StyleBoxFlat
var _style_unselected: StyleBoxFlat

func _ready() -> void:
	_build_styles()
	for event in EVENTS:
		MPF.server.add_event_handler(event, _on_selection_event)
	call_deferred("_refresh_highlight")

func _exit_tree() -> void:
	for event in EVENTS:
		MPF.server.remove_event_handler(event, _on_selection_event)

func action_update(_settings: Dictionary = {}, _kwargs: Dictionary = {}) -> void:
	call_deferred("_refresh_highlight")

func _on_selection_event(_kwargs = null) -> void:
	call_deferred("_refresh_highlight")

func _build_styles() -> void:
	_style_selected = StyleBoxFlat.new()
	_style_selected.bg_color = Color(0, 0, 0, 0)
	_style_selected.border_color = GOLD
	_style_selected.set_border_width_all(6)
	_style_selected.set_corner_radius_all(12)
	_style_selected.content_margin_left = 4
	_style_selected.content_margin_top = 4
	_style_selected.content_margin_right = 4
	_style_selected.content_margin_bottom = 4

	_style_unselected = StyleBoxFlat.new()
	_style_unselected.bg_color = Color(0, 0, 0, 0)
	_style_unselected.set_border_width_all(0)

func _refresh_highlight() -> void:
	if not is_instance_valid(_queens_container) or not is_instance_valid(_zamunda_container):
		return
	if not MPF.game or MPF.game.player.is_empty():
		highlight_selection(true)
		return
	var loc: int = MPF.game.player.get("selected_location", 0)
	match loc:
		2:
			highlight_selection(false)
		_:
			highlight_selection(true)

func highlight_selection(is_queens: bool) -> void:
	_apply_card_state(_queens_container, _queens_card, is_queens)
	_apply_card_state(_zamunda_container, _zamunda_card, not is_queens)

func _apply_card_state(container: PanelContainer, card: TextureRect, selected: bool) -> void:
	if not container or not card:
		return
	if selected:
		container.add_theme_stylebox_override("panel", _style_selected)
		container.modulate = BRIGHT
		card.modulate = BRIGHT
	else:
		container.add_theme_stylebox_override("panel", _style_unselected)
		container.modulate = DIM
		card.modulate = DIM
