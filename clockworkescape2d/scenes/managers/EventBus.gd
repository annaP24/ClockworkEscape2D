@warning_ignore_start("unused_signal")
extends Node
## Central event bus for game-wide signal routing.
##
## Signal flow: UI/Scenes → EventBus → World orchestrator
## All signals flow upward; direct references flow downward.
## This keeps systems decoupled and testable.

# ========== MENU/UI SIGNALS ==========
## Emitted when player presses Start in main menu
signal menu_start_game
## Emitted when player quits from menu
signal menu_quit_game
## Emitted when player opens settings
signal menu_show_settings
## Emitted when player opens save slots view
signal menu_show_game_slots

# ========== SETTINGS SIGNALS ==========
## Emitted when brightness slider changes (0.0-1.0)
signal settings_brightness_changed(value: float)

# ========== WORLD/UI STATE SIGNALS ==========
## Emitted to toggle start menu visibility
signal world_show_menu(show: bool)
## Emitted to hide settings menu
signal world_hide_settings_menu(hide: bool)
## Emitted to hide save slots view
signal world_hide_slots_view(hide: bool)
## Emitted to hide score/stats view
signal world_hide_score_view(hide: bool)
## Emitted when UI data needs refresh
signal world_update_data

# ========== LEVEL CONTROL SIGNALS ==========
## Emitted when player requests to quit current level
signal level_quit_requested
## Emitted when player requests to restart level
signal level_restart_requested
## Emitted when player returns to world map (includes level_id)
signal level_return_to_map(level_id: int)
## Emitted when player completes a level
signal level_completed

# ========== PLAYER/ENVIRONMENT SIGNALS ==========
## Emitted when player touches ground (includes footstep sound name)
signal player_touched_ground(sound: String)

# ========== PLATFORM/EXIT SIGNALS ==========
## Emitted when exit platform finishes transition
signal exit_animation_finished

# ========== PROGRESSION SIGNALS ==========
## Emitted when a save slot is selected
signal save_slot_selected(slot_id: int)

# @warning_ignore_end("unused_signal")

# ========== BACKWARD COMPATIBILITY LAYER ==========
# Legacy signal aliases for existing code (deprecated, use new names above)
var sm_start_game: Signal:
	get: return menu_start_game
var sm_quit_game: Signal:
	get: return menu_quit_game
var sm_settings: Signal:
	get: return menu_show_settings
var sm_show_game_slots: Signal:
	get: return menu_show_game_slots
var s_brightness_changed: Signal:
	get: return settings_brightness_changed
var world_show_sm: Signal:
	get: return world_show_menu
var lb_quit_level: Signal:
	get: return level_quit_requested
var lb_restart_level: Signal:
	get: return level_restart_requested
var lb_return_to_map: Signal:
	get: return level_return_to_map
var exit_level_finished: Signal:
	get: return exit_animation_finished
var slot_pressed: Signal:
	get: return save_slot_selected
