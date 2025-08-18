extends Area2D
class_name Comp2dHurtbox

# Diese Komponente erzeugt ein signsal wenn eine aktive hitbox
# trifft

signal hurt(damage)

# --------Variables-----------------------------------------------------------

# --------Functions-----------------------------------------------------------
func take_damage(damage_amount: float):
	hurt.emit(damage_amount)

# --------Signals-------------------------------------------------------------
