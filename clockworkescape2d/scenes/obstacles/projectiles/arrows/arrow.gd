extends Projectile


var is_ignore_once : bool = true

func _process(_delta: float) -> void:
	global_position += Vector2(1,1) * speed * current_direction
	#move_and_slide()
func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.name == "TileMapLayer_2":
		if is_ignore_once:
			is_ignore_once = false
		else:
			queue_free()
