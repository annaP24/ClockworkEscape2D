@warning_ignore_start("unused_signal")
extends Node

#----------- Start menu ---------------
signal sm_start_game
signal sm_quit_game
signal sm_settings
signal sm_continue_game
#----------- Settings -----------------
signal s_brightness_changed(value : float)


#----------- World -----------------
signal world_show_sm(show : bool)
signal world_hide_settings_menu(hide : bool)

#----------- Level -----------------
signal lb_quit_level
signal lb_restart_level
signal lb_return_to_map(level_id : int)


signal pl_touched_ground(sound : String)
