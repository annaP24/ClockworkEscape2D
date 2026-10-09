extends ColorRect
class_name ConfirmPopup

signal confirmed
signal cancelled

@onready var message_label: Label = %MessageLabel
@onready var yes_button: StandardButton = %YesButton
@onready var cancel_button: StandardButton = %CancelButton

func _ready() -> void:
	yes_button.pressed.connect(_on_yes_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	cancel_button.grab_focus()

func set_message(text: String) -> void:
	message_label.text = text

func _on_yes_pressed() -> void:
	confirmed.emit()
	queue_free()

func _on_cancel_pressed() -> void:
	cancelled.emit()
	queue_free()
