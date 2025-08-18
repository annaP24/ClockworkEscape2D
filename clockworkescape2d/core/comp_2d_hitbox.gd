extends Area2D
class_name Comp2dHitbox

# Init in ready():
# component.set_damage(5)
#
# Bei jedem attack muss set_enable(true) aufgerufen werden
# und set_enable(false) wenn die attacke zu ende ist.

# --------Variables-----------------------------------------------------------
signal hit_something

@export var damage: float = 1
@export var is_enable: bool = true

# --------Functions-----------------------------------------------------------
func _ready() -> void:
	area_entered.connect(_on_area_entered)

func set_damage(new_damage: float):
	damage = new_damage

func get_damage():
	return damage 
	
func set_enable(state: bool):
	is_enable = state
	
func get_enable():
	return is_enable

# --------Signals-------------------------------------------------------------
func _on_area_entered(hurtbox_area: Area2D):
	if hurtbox_area is Comp2dHurtbox:
		if is_enable:
			if hurtbox_area.has_method("take_damage"):
				hurtbox_area.take_damage(damage)
				hit_something.emit()
