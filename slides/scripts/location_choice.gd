extends Control

signal location_selected(name: String)

@onready var option_a: Button = $Buttons/OptionA
@onready var option_b: Button = $Buttons/OptionB

func _ready() -> void:
    if option_a:
        option_a.pressed.connect(func(): _emit_choice("option_a"))
    if option_b:
        option_b.pressed.connect(func(): _emit_choice("option_b"))

func _emit_choice(name: String) -> void:
    emit_signal("location_selected", name)

