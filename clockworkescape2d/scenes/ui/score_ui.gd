extends Control
@onready var score: Label = $HBoxContainer/Score

func _ready() -> void:
	EventBus.world_hide_score_view.connect(_on_hide_socore)

func _process(_delta: float) -> void:
	score.text = str(GameManager.max_collected)

func _on_hide_socore(is_score_visible : bool) -> void:
	visible = is_score_visible
