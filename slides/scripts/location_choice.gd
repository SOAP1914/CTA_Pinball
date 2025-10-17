extends MPFSlide

# Helper to safely post an MPF event no matter how the singleton is named
func post_mpf_event(ev: String) -> void:
  if Engine.has_singleton("MPF"):
    Engine.get_singleton("MPF").post_event(ev)
  elif has_node("/root/MPF"):
    get_node("/root/MPF").post_event(ev)
  elif Engine.has_singleton("MpfGmc"):
    Engine.get_singleton("MpfGmc").post_event(ev)
  else:
    print("MPF bridge not found; would post:", ev)

func _ready() -> void:
  # Optional: default highlight to Queens
  highlight_selection(true)

func _on_btn_queens_pressed() -> void:
  post_mpf_event("location_queens_selected")

func _on_btn_zamunda_pressed() -> void:
  post_mpf_event("location_zamunda_selected")

# UI highlight helpers; you can also listen to MPF events:
# 'location_cursor_is_queens' / 'location_cursor_is_zamunda' via GMC if desired.
func highlight_selection(is_queens: bool) -> void:
  var q = $Margin/VBox/HBox/BtnQueens
  var z = $Margin/VBox/HBox/BtnZamunda
  q.modulate = Color(1,1,1,1) if is_queens else Color(0.8,0.8,0.8,1)
  z.modulate = Color(0.8,0.8,0.8,1) if is_queens else Color(1,1,1,1)
