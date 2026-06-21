extends MPFSlide

func _ready() -> void:
	# Optional: default highlight to Queens
	highlight_selection(true)

func _on_btn_queens_pressed() -> void:
	MPF.server.send_event("set_location_queens")

func _on_btn_zamunda_pressed() -> void:
	MPF.server.send_event("set_location_zamunda")

# UI highlight helpers; you can also listen to MPF events:
# 'location_cursor_is_queens' / 'location_cursor_is_zamunda' via GMC if desired.
func highlight_selection(is_queens: bool) -> void:
	var q = $Margin/VBox/HBox/BtnQueens
	var z = $Margin/VBox/HBox/BtnZamunda
	q.modulate = Color(1, 1, 1, 1) if is_queens else Color(0.8, 0.8, 0.8, 1)
	z.modulate = Color(0.8, 0.8, 0.8, 1) if is_queens else Color(1, 1, 1, 1)
