extends Control

const LINES := [
	"可恶的野猪全都被消灭了",
	"世界又恢复到以往的宁静",
	"但这一切，只还是开始"
]

var current_line := -1
var tween: Tween

@onready var label: Label = $Label


func show_line(line: int) -> void:
	current_line = line
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	if line > 0:
		pass
