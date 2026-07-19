# core/comp_object_pool.gd
extends Node
class_name CompObjectPool
## Simple object pool for high-frequency spawn objects (particles, collectables).
## Prevents frame drops by reusing instances instead of allocating new ones.
##
## Usage:
##   var pool := CompObjectPool.new("res://scenes/collectables/collectable.tscn", 20)
##   var instance := pool.get_instance()
##   instance.position = spawn_pos
##   instance.show()
##   # When done:
##   pool.return_instance(instance)

var pool: Array[Node] = []
var prefab_path: String
var pool_size: int
var prefab: PackedScene

func _init(path: String, size: int = 10) -> void:
	prefab_path = path
	pool_size = size
	prefab = load(path)
	
	if prefab == null:
		push_error("ObjectPool: Failed to load prefab at %s" % path)
		return
	
	_preallocate_pool()

## Pre-allocate pool instances to avoid runtime allocation
func _preallocate_pool() -> void:
	for i in range(pool_size):
		var instance := prefab.instantiate()
		instance.hide()
		instance.set_meta("pooled", true)
		pool.append(instance)

## Get an instance from the pool, or create a new one if pool is empty
func get_instance() -> Node:
	if pool.is_empty():
		var instance := prefab.instantiate()
		instance.set_meta("pooled", true)
		return instance
	
	var instance : Node = pool.pop_front()
	instance.show()
	return instance

## Return instance to the pool for reuse
func return_instance(instance: Node) -> void:
	if instance == null:
		return
	
	instance.hide()
	
	# Reset position/state if it has these properties
	if "position" in instance:
		instance.position = Vector2.ZERO
	if "velocity" in instance:
		instance.velocity = Vector2.ZERO
	
	if pool.size() < pool_size * 2:  # Allow pool to grow slightly
		pool.append(instance)
	else:
		instance.queue_free()

## Get current pool statistics
func get_stats() -> Dictionary:
	return {
		"available": pool.size(),
		"max_size": pool_size,
		"prefab_path": prefab_path
	}
