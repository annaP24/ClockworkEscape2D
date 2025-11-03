extends StaticBody2D
@onready var sprite_2d: Sprite2D = $Sprite2D

#var collectables = [preload("res://scenes/collectables/assets/collectable.png"), preload("res://scenes/collectables/assets/collectable_alternative.png")]
var colors = [Color("3133ff"), Color("a934ff"), Color("a93402"), Color("e87a01"), Color("00b199")]
func _ready() -> void:
	pass
	#sprite_2d.modulate = colors[randi_range(0, colors.size()-1)]
	#sprite_2d.texture = collectables[randi_range(0,1)]
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.collected_objects += 1
		queue_free()
