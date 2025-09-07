extends Control

@onready var level_button_1: LevelButton = %LevelButton1
@onready var level_button_2: LevelButton = %LevelButton2
@onready var level_button_3: LevelButton = %LevelButton3
@onready var level_button_4: LevelButton = %LevelButton4
@onready var level_button_5: LevelButton = %LevelButton5
@onready var level_button_6: LevelButton = %LevelButton6
@onready var button_left: Button = %ButtonLeft
@onready var button_right: Button = %ButtonRight
@onready var parent = get_parent()

@onready var buttons_array : Array = [level_button_1, level_button_2, level_button_3 , level_button_4, level_button_5, level_button_6]
var path : String = "res://scenes/levels/scenes/"
var levels : Array
var current_page : int = 0
var buttons_per_page = 6
var current_level_path : String

func _ready() -> void:
	parent = get_parent()
	print(parent)
	levels =  read_folder()
	set_lavel_paths(0)
	update_arrows()
	FadeScreen.connect("fade_out_finished", _on_fade_out_finished)
	
func update_arrows():
	if current_page > 0:
		button_left.disabled = false
	else:
		button_left.disabled = true
		
	if levels.size() > buttons_per_page * (current_page+1):
		button_right.disabled = false
	else:
		button_right.disabled = true	
func read_folder() -> Array:
	var dir = DirAccess.open(path)
	if dir:
		return dir.get_files()
	else:
		return []
		
func set_lavel_paths(delta):
	var cnt = current_page * buttons_per_page + delta
	for button in buttons_array:
		if cnt <= levels.size()-1:
			button.set_scene_path(path + levels[cnt])
			button.set_text(str(cnt+1))
			cnt+=1
		else:
			button.set_scene_path("")
			button.set_text("-")
					
func _on_level_button_pressed() -> void:
	FadeScreen.fade_out()
	current_level_path = level_button_1.scene_path

func _on_level_button_2_pressed() -> void:
	parent.load_level(level_button_2.scene_path)

func _on_level_button_3_pressed() -> void:
	parent.load_level(level_button_3.scene_path)

func _on_level_button_4_pressed() -> void:
	parent.load_level(level_button_4.scene_path)

func _on_level_button_5_pressed() -> void:
	parent.load_level(level_button_5.scene_path)

func _on_level_button_6_pressed() -> void:
	parent.load_level(level_button_6.scene_path)

func _on_button_left_pressed() -> void:
	current_page -= 1
	set_lavel_paths(0)
	update_arrows()

func _on_button_right_pressed() -> void:
	current_page += 1
	set_lavel_paths(0)
	update_arrows()
	
func _on_fade_out_finished():
	parent.load_level(current_level_path)
	current_level_path = ""
