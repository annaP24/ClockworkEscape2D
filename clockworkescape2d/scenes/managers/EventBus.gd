@warning_ignore_start("unused_signal")
extends Node

#----------- Start menu ---------------
signal sm_start_game
signal sm_quit_game
signal sm_settings
signal sm_show_game_slots
#----------- Settings -----------------
signal s_brightness_changed(value : float)


#----------- World -----------------
signal world_show_sm(show : bool)
signal world_hide_settings_menu(hide : bool)
signal world_hide_slots_view(hide : bool)
signal world_hide_score_view(hide : bool)
signal world_update_data
#----------- Level -----------------
signal lb_quit_level
signal lb_restart_level
signal lb_return_to_map(level_id : int)


signal pl_touched_ground(sound : String)

#----------- Exit platform -----------------
signal exit_level_finished

#----------- Save slots -----------------
signal slot_pressed(id: int)
