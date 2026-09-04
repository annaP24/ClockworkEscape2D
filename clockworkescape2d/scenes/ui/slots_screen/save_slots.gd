extends Control
var slot1_data : Dictionary
var slot2_data : Dictionary
var slot3_data : Dictionary
@onready var stats_sl_1: Stats2 = %Stats_sl1
@onready var empty_label_1: Label = %EmptyLabel1
@onready var stats_sl_2: Stats2 = %Stats_sl2
@onready var empty_label_2: Label = %EmptyLabel2
@onready var stats_sl_3: Stats2 = %Stats_sl3
@onready var empty_label_3: Label = %EmptyLabel3
@onready var play_button: TextureButton = %Play
@onready var delete_button: TextureButton = %DeleteButton
@onready var back_button: StandardButton = %BackButton
@onready var slot_1_button: TextureButton = %Slot1Button
var selected_slot : int = 0

func _ready() -> void:
	check_slot_data()
	if selected_slot == 0:
		play_button.disabled = true
	if GameSaveManager.is_joypad_connected:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		slot_1_button.grab_focus()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func check_slot_data():
	slot1_data = GameSaveManager.check_progress_data_for_slot(1)
	slot2_data = GameSaveManager.check_progress_data_for_slot(2)
	slot3_data = GameSaveManager.check_progress_data_for_slot(3)

	if slot1_data.is_empty():
		stats_sl_1.visible = false
		empty_label_1.visible = true
	else:
		stats_sl_1.visible = true
		empty_label_1.visible = false
		stats_sl_1.fill_data(slot1_data)
	if slot2_data.is_empty():
		stats_sl_2.visible = false
		empty_label_2.visible = true
	else:
		stats_sl_2.visible = true
		empty_label_2.visible = false
		stats_sl_2.fill_data(slot2_data)
	if slot3_data.is_empty():
		stats_sl_3.visible = false
		empty_label_3.visible = true
	else:
		stats_sl_3.visible = true
		empty_label_3.visible = false
		stats_sl_3.fill_data(slot3_data)

func _enable_disable_buttons(slot : int, toggle_on : bool):
	if toggle_on:
		selected_slot = slot
		play_button.disabled = false
	else:
		selected_slot = 0

	if slot == 1:
		if !slot1_data.is_empty():
			delete_button.disabled = false
		else:
			delete_button.disabled = true
	elif slot == 2:
		if !slot2_data.is_empty():
			delete_button.disabled = false
		else:
			delete_button.disabled = true
	elif slot == 3:
		if !slot3_data.is_empty():
			delete_button.disabled = false
		else:
			delete_button.disabled = true
	elif slot == 0:
		delete_button.disabled = true
		play_button.disabled = true
#---------------------------- SIgnals ----------------------------------------

#func _world_hide_slots_view(is_show : bool)-> void:
	#visible = is_show
	#if visible and GameSaveManager.is_joypad_connected:
		#slot_1_button.grab_focus()
#func _on_back_button_pressed() -> void:
	#AudioManager.play_sfx("click")
	#EventBus.world_show_menu.emit(true)
	#visible = false

func _on_update_data()-> void:
	check_slot_data()

func _on_slot_1_button_toggled(toggled_on: bool) -> void:
	AudioManager.play_sfx("click")
	_enable_disable_buttons(1, toggled_on)

func _on_slot_2_button_toggled(toggled_on: bool) -> void:
	AudioManager.play_sfx("click")
	_enable_disable_buttons(2, toggled_on)

func _on_slot_3_button_toggled(toggled_on: bool) -> void:
	AudioManager.play_sfx("click")
	_enable_disable_buttons(3, toggled_on)

#func _on_play_pressed() -> void:
	#AudioManager.play_sfx("click")
	#if selected_slot != 0:
		#EventBus.save_slot_selected.emit(selected_slot)
#
