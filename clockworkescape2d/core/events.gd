# core/events.gd
class_name GameEvents
## Central repository for typed game events. Provides type safety and IDE autocomplete.

class LevelCompleted:
	var level_id: int
	var collectables_found: int
	var time_elapsed: float
	
	func _init(p_level_id: int, p_collectables: int, p_time: float = 0.0) -> void:
		level_id = p_level_id
		collectables_found = p_collectables
		time_elapsed = p_time

class PlayerDamaged:
	var amount: int
	var source: Node2D
	var position: Vector2
	
	func _init(p_amount: int, p_source: Node2D = null, p_pos: Vector2 = Vector2.ZERO) -> void:
		amount = p_amount
		source = p_source
		position = p_pos

class CollectableCollected:
	var collectable_id: int
	var level_id: int
	var position: Vector2
	
	func _init(p_collectable_id: int, p_level_id: int, p_pos: Vector2 = Vector2.ZERO) -> void:
		collectable_id = p_collectable_id
		level_id = p_level_id
		position = p_pos

class GameStateChanged:
	var old_state: int
	var new_state: int
	var context: String
	
	func _init(p_old: int, p_new: int, p_context: String = "") -> void:
		old_state = p_old
		new_state = p_new
		context = p_context
