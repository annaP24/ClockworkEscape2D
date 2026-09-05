extends Control
@onready var score_label: Label = %ScoreLabel
@onready var deaths_label: Label = %DeathsLabel
@onready var levels_label: Label = %LevelsLabel

func _ready() -> void:
	EventBus.world_hide_score_view.connect(_on_hide_socore)

func _process(_delta: float) -> void:
	score_label.text = str(GameSaveManager.max_collected) + "/ 60"
	deaths_label.text = str(GameSaveManager.max_deaths_for_slot)
	levels_label.text = str(GameSaveManager.max_level_reached) + "/ 20"

func _on_hide_socore(is_score_visible : bool) -> void:
	visible = is_score_visible
