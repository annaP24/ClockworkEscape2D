extends Control
@onready var score: Label = $HBoxContainer/Score

func _process(_delta: float) -> void:
	score.text = str(GameManager.max_collected)
