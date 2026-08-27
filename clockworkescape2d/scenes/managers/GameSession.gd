extends Node


var requested_level_path: String = ""
var requested_level_id: int = -1

func set_level_request(path_to_level: String, level_id: int) -> void:
	requested_level_path = path_to_level
	requested_level_id = level_id

func consume_level_request() -> Dictionary:
	var request := {
		"path": requested_level_path,
		"id": requested_level_id,
	}
	requested_level_path = ""
	requested_level_id = -1
	return request
