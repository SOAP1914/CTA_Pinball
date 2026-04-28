extends TextureRect
## Pans a wider-than-viewport background image back and forth across the
## ultrawide playfield display. Attach to a TextureRect that is wider than
## the display (e.g. 3200px wide in a 2560px viewport).

@export var scroll_speed: float = 20.0
@export var max_offset: float = 640.0

var _direction: float = -1.0
var _offset: float = 0.0

func _process(delta: float) -> void:
    _offset += scroll_speed * _direction * delta
    if abs(_offset) >= max_offset:
        _direction *= -1.0
        _offset = clampf(_offset, -max_offset, max_offset)
    position.x = _offset
