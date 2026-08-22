# Clockwork Escape 2D Refactor Plan

This document is a proposed refactor plan based on the current architecture and the best-practice principles discussed in the Godot 4 best-practices book. It is intentionally a planning document only; no production code is changed yet.

## 1. Goal

Improve the project’s maintainability, reduce hidden dependencies, and align the architecture more closely with Godot 4 best practices without breaking the current gameplay loop.

The current project already has a good conceptual direction:
- event-driven communication through a global bus
- FSM-based player logic
- screen and manager separation
- game-state orchestration through a root scene

The main problems are not conceptual; they are structural and lifecycle-related.

---

## 2. Current architecture assessment

### What is already healthy

- The project uses a central event bus for cross-scene communication: [scenes/managers/EventBus.gd](scenes/managers/EventBus.gd)
- Game orchestration is mostly centralized in the world/root node: [scenes/world.gd](scenes/world.gd)
- Character behavior is modeled as a state machine: [core/general/comp_fsm_node.gd](core/general/comp_fsm_node.gd)
- Reusable collision components exist for hitbox/hurtbox logic: [core/comp_2d_hitbox.gd](core/comp_2d_hitbox.gd) and [core/comp_2d_hurtbox.gd](core/comp_2d_hurtbox.gd)
- Managers are separated for sound, settings, and progression: [scenes/managers/AudioManager.gd](scenes/managers/AudioManager.gd), [scenes/managers/SettingManager.gd](scenes/managers/SettingManager.gd), and [scenes/managers/GameSaveManager.gd](scenes/managers/GameSaveManager.gd)

### Main architectural issues

- [scenes/world.gd](scenes/world.gd) is acting as a global coordinator, UI controller, level loader, transition manager, and state tracker at once.
- The save/progression logic is overburdened in [scenes/managers/GameSaveManager.gd](scenes/managers/GameSaveManager.gd).
- Event payloads in [scenes/managers/EventBus.gd](scenes/managers/EventBus.gd) still pass UI node instances, which creates strong coupling.
- The FSM in [core/general/comp_fsm_node.gd](core/general/comp_fsm_node.gd) has initialization and transition logic that is not fully consistent or cleanly separated.
- Global autoload state is used heavily, which is fine for Godot but needs stricter responsibility boundaries.

---

## 3. Refactor principles

The refactor should follow these principles:

1. Keep Godot’s signal-driven architecture, but reduce hidden coupling.
2. Split large coordinator files into cohesive responsibilities.
3. Make autoloads act as narrow services, not as entire game containers.
4. Prefer semantic events over UI-object payloads.
5. Keep gameplay logic decoupled from save/transient UI state.
6. Preserve the gameplay loop while reducing long-term maintenance risk.

---

## 4. Priority refactor goals

### Priority 1 — Break up the world orchestrator

File to target:
- [scenes/world.gd](scenes/world.gd)

Reason:
This file is doing far too much: menu flow, level lifecycle, scene loading, transitions, and state updates. It should become a coordinator that delegates work instead of owning everything.

Proposed split:
- GameStateController: owns current game mode and high-level transitions
- LevelLoaderService: loads/unloads levels and manages current level lifecycle
- UIStateController: handles menu/settings/world map visibility
- TransitionController: handles fade/transition flow and pending actions

Outcome:
- the world node becomes simpler and more readable
- responsibilities are easier to test and extend
- new states or menus require smaller changes

---

### Priority 2 — Separate save/data concerns from gameplay logic

Files to target:
- [scenes/managers/GameSaveManager.gd](scenes/managers/GameSaveManager.gd)
- [scenes/managers/SettingManager.gd](scenes/managers/SettingManager.gd)

Reason:
This code mixes:
- state persistence
- progression rules
- per-level save logic
- total play-time tracking
- slot metadata
- settings persistence

Proposed split:
- SaveService: reads/writes config files
- ProgressService: stores max level, collectibles, session totals
- SettingsService: persists brightness and audio settings
- SessionTracker: tracks play time and deaths per session/slot

Outcome:
- easier to debug corrupted save files
- less accidental coupling between gameplay and save rules
- easier to add new save slots or profile systems later

---

### Priority 3 — Reduce tight coupling in event signals

File to target:
- [scenes/managers/EventBus.gd](scenes/managers/EventBus.gd)

Reason:
Signals like `button_pressed(id : TextureButton)` couple listeners to concrete UI nodes instead of semantic actions.

Proposed change:
- replace UI-object references with stable IDs or action names
- define a clear vocabulary of event payloads
- avoid sending scene internals through global signals

Example direction:
- `button_pressed(button_id: StringName)`
- `menu_start_requested`
- `settings_brightness_changed(value: float)`

Outcome:
- decoupled UI and gameplay layers
- easier testing and future UI redesigns
- cleaner domain events

---

### Priority 4 — Harden the FSM implementation

Files to target:
- [core/general/comp_fsm_node.gd](core/general/comp_fsm_node.gd)
- [scenes/character_custom_data_layer/character.gd](scenes/character_custom_data_layer/character.gd)

Reason:
The FSM intent is strong, but the actual implementation is still too permissive and partly incomplete. There is hidden transactional logic, duplicated initialization, and unclear state transitions.

Proposed change:
- centralize FSM setup in a single initialization path
- ensure transition guard logic is explicit and consistent
- remove dead or duplicated lifecycle code
- separate state logic from player controller logic where practical

Outcome:
- more predictable state transitions
- easier debugging of movement edge cases
- less risk of state desynchronization

---

### Priority 5 — Clarify process and pause semantics

Files to target:
- [scenes/world.gd](scenes/world.gd)
- [scenes/world_map/world_map.gd](scenes/world_map/world_map.gd)
- [scenes/levels/level_base.gd](scenes/levels/level_base.gd)

Reason:
The project relies on broad tree pause patterns and global process switches, which is functional but risky.

Proposed change:
- isolate gameplay pause from UI pause
- use process_mode intentionally instead of blanket tree pause
- define which nodes should pause and which should remain responsive

Outcome:
- fewer accidental freezes
- cleaner menu/game interactions
- easier debugging of edge cases during transitions

---

## 5. Proposed target architecture

The refactor should move the project toward this high-level structure:

- Root scene / GameCoordinator
  - manages state flow and coordination
- GameStateManager
  - current menu, map, level, settings, death/restart states
- LevelLoader
  - loads scenes and owns transition logic
- Save/Progress system
  - persistence and unlock logic
- UIController layer
  - menu visibility and interaction wiring
- Character FSM layer
  - movement states and combat/death state handling
- Manager services
  - audio, settings, visuals, fade, effects

This keeps the current design direction but makes each layer narrower and more predictable.

---

## 6. Planned refactor sequence

### Phase 1 — Architectural cleanup

1. Define a single game-state model and map it to current states.
2. Reduce responsibilities in [scenes/world.gd](scenes/world.gd).
3. Create a dedicated level loading abstraction.
4. Consolidate transition handling from fade/return/restart logic.

### Phase 2 — Data and save refactor

1. Split save/config duties from progression rules.
2. Separate settings persistence from runtime settings behavior.
3. Standardize progress keys and slot logic.
4. Add validation for missing or malformed save files.

### Phase 3 — Signal cleanup

1. Replace UI object payloads with semantic IDs.
2. Review all event bus consumers for overuse of direct node references.
3. Confirm signal names match their purpose and layer ownership.

### Phase 4 — FSM and lifecycle stabilization

1. Clean up initialization in [core/general/comp_fsm_node.gd](core/general/comp_fsm_node.gd).
2. Make transitions explicit and testable.
3. Remove unused timers and state flags that no longer play a role.

### Phase 5 — Pause/process hardening

1. Audit where `get_tree().paused` is used.
2. Limit pauses to relevant systems.
3. Verify that UI, world map, and level logic behave correctly when they are toggled.

---

## 7. Specific files to review in the refactor

- [scenes/world.gd](scenes/world.gd)
- [scenes/managers/EventBus.gd](scenes/managers/EventBus.gd)
- [scenes/managers/GameSaveManager.gd](scenes/managers/GameSaveManager.gd)
- [scenes/managers/SettingManager.gd](scenes/managers/SettingManager.gd)
- [scenes/levels/level_base.gd](scenes/levels/level_base.gd)
- [core/general/comp_fsm_node.gd](core/general/comp_fsm_node.gd)
- [scenes/character_custom_data_layer/character.gd](scenes/character_custom_data_layer/character.gd)
- [scenes/world_map/world_map.gd](scenes/world_map/world_map.gd)
- [scenes/ui/start_screen/start_menu.gd](scenes/ui/start_screen/start_menu.gd)

---

## 8. Success criteria

The refactor is successful when:

- no scene file is acting as a giant “god object”
- manager singletons are small and focused
- event payloads are semantic and not UI-instance-driven
- save and progress logic has a clear owner
- FSM transitions are easy to reason about and debug
- adding a new menu, level, or save feature requires fewer cross-file edits

---

## 9. Non-goals for this refactor

This refactor should not:
- rewrite the entire game gameplay systems from scratch
- majorly change the visual style or UX flow
- add a new engine or framework abstraction just for the sake of it
- increase coupling in the name of “cleanliness”

The purpose is to improve architecture without destabilizing the current game.

---

## 10. Recommended order of execution

1. World coordinator split
2. Event bus cleanup
3. Save/progression separation
4. FSM stabilization
5. Pause/process refinement
6. Final audit and simplification

This order delivers the biggest maintainability gains early while still keeping risk manageable.

---

## 11. Final recommendation

The project is already far better than a typical prototype because it has a solid high-level architecture and a clearly intended event-driven design. The refactor should not throw away that direction; it should reduce the coupling and clarification gaps that are emerging as the game grows.

The most valuable move is to stop treating the root world scene and the global manager layer as a single catch-all system, then clean up the save and event contracts afterward.

---

## 12. Step-by-step checklist

Use this checklist as the execution sequence for the actual refactor work. Each item should be completed and verified before moving to the next phase.

### Phase A — Stabilize the architecture

- [ ] Review the current responsibilities of [scenes/world.gd](scenes/world.gd) and document what belongs to the world root vs. service classes.
- [ ] Define the game-state enum and lifecycle model for menu, world map, settings, save slots, and in-level flow.
- [ ] Extract a dedicated level loader from the world root without changing runtime behavior.
- [ ] Extract a dedicated transition controller for fade-in/out and pending actions.
- [ ] Move UI visibility toggling into a dedicated UI controller or state handler.
- [ ] Confirm all menu and gameplay transitions still behave correctly after the split.
- [ ] Validate that no code in the world root is managing gameplay rules directly.

### Phase B — Simplify the event contract

- [ ] Audit all signals in [scenes/managers/EventBus.gd](scenes/managers/EventBus.gd).
- [ ] Replace UI object payloads with semantic identifiers or simple value payloads.
- [ ] Rename signals that are ambiguous or too UI-specific.
- [ ] Remove any signal that only exists to propagate a node reference.
- [ ] Ensure all listeners use the event bus consistently and do not rely on direct parent/child references.
- [ ] Confirm all menu buttons trigger actions through semantic events rather than object identity.

### Phase C — Clean up save and settings boundaries

- [ ] Separate file I/O logic from gameplay/progression rules in [scenes/managers/GameSaveManager.gd](scenes/managers/GameSaveManager.gd).
- [ ] Separate settings persistence from runtime settings logic in [scenes/managers/SettingManager.gd](scenes/managers/SettingManager.gd).
- [ ] Review all ConfigFile keys and ensure they are namespaced consistently.
- [ ] Validate missing-file and malformed-file behavior for each save slot.
- [ ] Keep progression logic, session tracking, and persistence in distinct layers.
- [ ] Confirm progress still loads correctly after a clean save and a corrupted save edge case.

### Phase D — Harden the FSM

- [ ] Review the initialization flow in [core/general/comp_fsm_node.gd](core/general/comp_fsm_node.gd).
- [ ] Remove duplicate or dead setup logic between `start()` and `_ready()`.
- [ ] Make transition guard checks explicit and consistent.
- [ ] Confirm `state_changed` and timer logic are either used correctly or removed.
- [ ] Validate that state changes are triggered only from valid transitions.
- [ ] Confirm all movement states still enter/exit cleanly.

### Phase E — Review pause and lifecycle behavior

- [ ] Audit all uses of `get_tree().paused` across the project.
- [ ] Define which systems should pause and which should remain active during menus and scene transitions.
- [ ] Replace blanket pauses with narrower process-mode controls where practical.
- [ ] Confirm world map, UI, and level scenes behave correctly during pause and unpause.
- [ ] Verify no UI element can freeze the entire game unintentionally.

### Phase F — Final quality pass

- [ ] Check that each file now has a tighter responsibility boundary.
- [ ] Review remaining autoload dependencies and ensure they are true service singletons, not hidden game controllers.
- [ ] Confirm every manager has a single purpose and does not manipulate unrelated state.
- [ ] Run through a full gameplay loop: start menu → save slots → map → level → restart/quit → return to map.
- [ ] Check for broken transitions, stuck UI states, or duplicate event subscriptions.
- [ ] Confirm the project is easier to extend with a new menu, level, or mechanic than before the refactor.

### Exit conditions

The refactor is ready to stop when all of the following are true:

- [ ] The root world scene is no longer a catch-all controller.
- [ ] Signals no longer carry direct UI-object payloads for core flow.
- [ ] Save and settings logic are separated and testable.
- [ ] FSM initialization and transitions are consistent and readable.
- [ ] Pause and lifecycle behavior are predictable.
- [ ] A new level or menu can be added without large cross-file refactors.

---

This checklist can be used as the project’s execution ledger for the refactor work. It is intentionally concrete, so the refactor can proceed in small, verifiable steps without changing game behavior unexpectedly.
