@warning_ignore_start("unused_signal")
extends Node

signal sm_start_game
signal sm_quit_game
signal sm_settings
signal sm_continue_game

signal world_hide_sm(hide : bool)

signal lb_quit_level
signal lb_restart_level
signal lb_return_to_map(level_id : int)
