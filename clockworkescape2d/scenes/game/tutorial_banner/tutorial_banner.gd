extends PanelContainer
## Top-center tutorial banner. Stays visible until the tutorial controller dismisses it via hide_banner().

@onready var text_label: Label = %Label

func _ready() -> void:
	visible = false

func show_banner(text: String) -> void:
	text_label.text = text
	visible = true

func hide_banner() -> void:
	visible = false
