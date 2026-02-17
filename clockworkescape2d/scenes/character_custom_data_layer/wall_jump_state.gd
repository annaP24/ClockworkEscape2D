extends FsmNodeState

# These should ideally be in your Player script or export variables
@export var neutral_jump_kick_speed: float = 150.0  # The "small kick"
@export var directional_jump_speed: float = 400.0   # The "full jump away"

var jump_direction: float = 0.0

func Enter(player_node):
	super(player_node)

	# 1. Vertical Speed (Constant for all wall jumps)
	player.velocity.y = player.wall_jump_velocity

	# 2. Determine Horizontal Launch Direction and Magnitude
	calculate_wall_jump_velocity()

	print("WallJumpState entered. Dir: ", jump_direction)

func Physics_Update(delta):
	# Apply gravity
	player.apply_gravity(player.jump_gravity, delta)

	# Allow some air control during the jump
	handle_mid_air_steering(delta)

	player.move_and_slide()

	# Transition checks
	handle_wall_jump_end()

func calculate_wall_jump_velocity():
	var input_dir = Input.get_axis("left", "right")
	# wall_side: LEFT = -1, RIGHT = 1 (Verify your enum values)
	var wall_side = player.last_wall_direction

	# Case 1: Directional Jump (Player holds AWAY from the wall)
	# If wall is RIGHT (1) and player presses LEFT (-1), or vice versa
	if input_dir != 0 and sign(input_dir) != wall_side:
		player.velocity.x = input_dir * player.wall_jump_h_speed
		jump_direction = input_dir
		print("Directional Wall Jump")

	# Case 2: Neutral Jump (No input OR holding TOWARD the wall)
	else:
		# Always kick AWAY from the wall regardless of input toward it
		var kick_dir = -wall_side
		#player.velocity.x = kick_dir * neutral_jump_kick_speed
		jump_direction = kick_dir
		print("Neutral Wall Jump (Small Kick)")

func handle_mid_air_steering(delta):
	var input_dir = Input.get_axis("left", "right")

	if input_dir != 0:
		# If user provides input, use your movement function to steer
		# We use a lower acceleration here usually to make the "kick" feel weighty
		player.move_player_x(input_dir)
	else:
		# If no input, let the kick velocity decay naturally
		player.velocity.x = move_toward(player.velocity.x, 0, player.wall_kick_deceleration * delta)

func handle_wall_jump_end():
	# Exit to FallState if we reach the peak or start falling
	if player.velocity.y >= player.wall_jump_y_speed_peak:
		change_state("FallState")

	# Update wall detection to see if we hit a new wall
	player.get_wall_direction()

	# If we hit a wall that is NOT the one we just jumped from, transition out
	# This allows for wall-to-wall jumping
	if player.last_wall_direction != player.WallSide.NONE and player.last_wall_direction != jump_direction * -1:
		change_state("FallState")
