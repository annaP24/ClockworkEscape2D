extends Control
## Top-center tutorial banner. Stays visible until the tutorial controller dismisses it via hide_banner().

@onready var title_label: Label = %TitleLabel
@onready var text_label: Label = %TextLabel

func _ready() -> void:
	visible = false

func show_banner(text: Array[String]) -> void:
	title_label.text = text[0] if text.size() > 0 else ""
	text_label.text = text[1] if text.size() > 1 else ""
	visible = true

func hide_banner() -> void:
	visible = false
