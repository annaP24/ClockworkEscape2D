# World FSM refactor

The world flow is being refactored to use a state machine instead of a large collection of boolean toggles and direct `if`/`match` code paths.

## Goal

Keep the root `World` node as a coordinator, and move each screen mode into a dedicated state object.

## States

- `MainMenuState`
- `SettingsState`
- `SaveSlotsState`
- `WorldMapState`
- `LevelState`

## Pattern

Each state owns:

- enter behavior
- exit behavior
- visibility toggling
- process-mode configuration
- audio/input state
- transitions to other states

## Example

```gdscript
state_machine.change_to(WorldStateMachine.WorldView.MAIN_MENU)
```

The `WorldStateMachine` holds the active state and calls the state lifecycle methods when the view changes.

## Benefits

- less branching in the world root node
- each screen has explicit enter/exit behavior
- easier to add new views later
- aligns with the existing FSM pattern used in player logic
