# Clockwork Escape 2D - Architecture Guide

## Overview

**Engine**: Godot 4.x  
**Architecture Style**: Component-based + Event-driven  
**Communication Pattern**: Bottom-to-top signals via EventBus  
**Code Style**: Static typed GDScript, strongly typed signals

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────┐
│                   WORLD.GD (Orchestrator)           │
│      Manages game state & level transitions         │
└─────────────────────────────────────────────────────┘
                           ▲
                           │ (listens)
                           │
┌──────────────────────────────────────────────────────┐
│                    EVENT BUS (Singleton)             │
│   Global signal hub: menu, level, settings, player  │
│   Pattern: All emissions flow UP from child scenes  │
└──────────────────────────────────────────────────────┘
         ▲                      ▲                 ▲
         │ (emits)             │ (emits)       │ (emits)
         │                     │               │
   ┌──────────┐          ┌───────────┐  ┌──────────────┐
   │ UI/MENUS │          │  LEVELS   │  │ PLAYER CHAR. │
   │ Scenes   │          │ Obstacles │  │  + FSM       │
   └──────────┘          └───────────┘  └──────────────┘
         │                    │                │
         └────────────────────┼────────────────┘
         (direct refs ↓)      │ (components)
                         ┌────┴─────┐
                         │ MANAGERS  │
                         │ (Audio,   │
                         │ Game,     │
                         │ Visuals)  │
                         └───────────┘
```

---

## Core Patterns

### 1. **EventBus (Global Signal Hub)**

**File**: `scenes/managers/EventBus.gd`

Central singleton routing all game events. Decouples scenes — UI doesn't need references to World, and vice versa.

**Signal Categories**:
- `menu_*` — Main menu interactions
- `settings_*` — Settings/preferences
- `world_*` — UI state changes
- `level_*` — Level control (quit, restart, return)
- `player_*` — Player state changes
- `save_slot_*` — Progression/save system

**Usage**:
```gdscript
# UI emits (child → parent via EventBus)
EventBus.menu_start_game.emit()

# World listens
EventBus.connect("menu_start_game", _on_menu_start_game)
```

**Key Rule**: Signals **always flow upward**. Direct node references flow **downward only**.

---

### 2. **FSM (Finite State Machine)**

**Files**: 
- `core/general/comp_fsm_node.gd` — FSM controller
- `core/general/state.gd` — Base state class
- `scenes/character_custom_data_layer/fsm/*.gd` — 9 state implementations

**State Lifecycle**:
1. `Enter(player)` — Initialize state (set animations, timers)
2. `Update(delta)` — Frame-based logic
3. `Physics_Update(delta)` — Physics-based logic
4. `Exit()` — Cleanup

**Example**: Player movement states (Idle → Run → Jump → Fall)

**Debouncing**: 0.2s timer prevents rapid transitions (prevents collision/animation bugs).

---

### 3. **Component-Based Architecture**

**Files**:
- `core/comp_2d_hitbox.gd` — Offensive collision (Area2D wrapper)
- `core/comp_2d_hurtbox.gd` — Defensive collision (receives damage)
- `core/comp_object_pool.gd` — Object pooling (NEW)

**Pattern**: Reusable components avoid inheritance bloat.

**Example Damage Flow**:
```
Obstacle.Comp2dHitbox.area_entered()
  → Comp2dHurtbox.take_damage()
    → emit hurt(damage)
      → Character FSM handles (damage animation or death)
        → emit player_died
          → EventBus propagates to World
```

---

### 4. **Managers (Singletons)**

**Autoloaded Managers** (defined in `project.godot`):

| Manager | Purpose | Key Methods |
|---------|---------|-------------|
| `GameManager` | Save/load progress, level tracking | `save_progress()`, `load_progress()` |
| `AudioManager` | Music/SFX pooling, volume control | `play_sfx()`, `play_music()` |
| `VisualsManager` | UI effects (hover, transitions) | Custom visual effects |
| `FadeScreen` | Screen transitions | `fade_out()`, `fade_in()` |
| `EventBus` | Global signal routing | All signal definitions |

**Initialization Order** (in `world.gd._initialize_managers()`):
1. GameManager (load saves first)
2. AudioManager (configure from GameManager state)
3. VisualsManager (prepare UI effects)

---

### 5. **Scene Hierarchy**

```
World (Root orchestrator)
├── StartMenu (UI)
├── SettingsMenu (UI)
├── SaveSlotsView (UI)
├── WorldMap (Level selection)
├── Scene (dynamically loaded level)
│   ├── Player (CharacterBody2D)
│   │   ├── FSM (CompFsmNode)
│   │   │   ├── StateIdle
│   │   │   ├── StateRun
│   │   │   ├── StateJump
│   │   │   ├── StateFall
│   │   │   └── StateWallSlide
│   │   └── Hurtbox (Comp2dHurtbox)
│   ├── Obstacles (Spike, Lightning, etc.)
│   │   └── Hitbox (Comp2dHitbox)
│   ├── Collectables (instances of collectable.tscn)
│   ├── Platforms
│   └── ExitPlatform (level completion)
└── CanvasLayers
    └── BrightnessLayer (shader effects)
```

---

## Communication Patterns

### Upward (Child → Parent via EventBus)

```gdscript
# Child emits
EventBus.level_completed.emit()

# Parent listens
EventBus.connect("level_completed", _on_level_completed)
```

### Downward (Parent → Child via exports or @onready)

```gdscript
# Parent exports reference
@export var player: Node2D

# Child gets reference via @onready
@onready var animation_player: AnimationPlayer = $AnimationPlayer
```

### Horizontal (Scene ↔ Scene via EventBus)

```gdscript
# UI listens to level events
EventBus.connect("level_quit_requested", _on_level_quit)

# Level emits completion
EventBus.level_completed.emit()
```

---

## Performance Considerations

### Object Pooling (for high-frequency objects)

**Use `CompObjectPool` for**:
- Collectables (spawn frequently)
- Particle effects (sparks, explosions)
- Projectiles (if added later)

**Example**:
```gdscript
var collectable_pool = CompObjectPool.new("res://scenes/collectables/collectable.tscn", 20)
var instance = collectable_pool.get_instance()
instance.position = spawn_pos
# Later:
collectable_pool.return_instance(instance)
```

### Node Caching

Always cache frequently accessed nodes:
```gdscript
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _process(_delta: float) -> void:
    animation_player.play("idle")  # No tree search each frame
```

### Avoid Searching Tree in Loops

✗ Bad:
```gdscript
func _process(_delta):
    for enemy in get_tree().get_nodes_in_group("enemies"):
        enemy.take_damage(1)  # Searches tree every frame
```

✓ Good:
```gdscript
var enemies: Array[Node] = []

func _ready():
    enemies = get_tree().get_nodes_in_group("enemies")  # Cache once
```

---

## Adding New Features

### Adding a New Level

1. Create `scenes/levels/level_XX.tscn`
2. Inherit from `level_base.gd`
3. Place obstacles, collectables, platforms
4. Create exit platform connecting to `level_completed` signal

### Adding a New UI Menu

1. Create scene in `scenes/ui/my_menu/my_menu.tscn`
2. Emit signals via EventBus (never direct references)
3. Connect to World via EventBus in `world.gd`

**Example**:
```gdscript
# my_menu.gd
func _on_start_pressed():
    EventBus.menu_start_game.emit()

# world.gd
func _ready():
    EventBus.connect("menu_start_game", _on_menu_start_game)
```

### Adding a New Obstacle Type

1. Create `scenes/obstacles/my_obstacle/my_obstacle.tscn`
2. Inherit from `CharacterBody2D` or `Area2D`
3. Add `Comp2dHitbox` child component
4. Connect hitbox signals as needed

---

## Code Guidelines (from .github/github-instructions.md)

✅ **Do**:
- Use static typing: `var x: int = 5`
- Keep functions small and focused
- Cache frequently accessed nodes with `@onready`
- Use signals for cross-scene communication
- Prefer `@export` for node configuration
- Use object pooling for high-frequency spawns

❌ **Avoid**:
- Godot 3.x syntax
- Deeply nested code (refactor into functions)
- Hardcoded screen resolutions
- Repeated `get_node()` calls in `_process()`
- Direct node references between independent scenes (use EventBus instead)

---

## Debugging Tips

1. **EventBus signal flow**: Add `print()` statements in emit sites to trace signal path
2. **FSM state changes**: Log state transitions in `CompFsmNode.change_state()`
3. **Physics issues**: Check `_physics_process()` frame rate and collision masks
4. **Performance**: Use Godot's built-in profiler (Debug → Monitor) to check frame time

---

## Future Improvements

1. **Dialog system**: Create `DialogEventBus` for NPC conversations
2. **Enemy AI**: Apply FSM pattern to enemies with their own state machines
3. **Weapon system**: Use component pattern for different weapon types
4. **Level progression**: Expand `GameManager` to track global progress
5. **Replay system**: Record EventBus signal emissions to create playback

---

**Last Updated**: 2026-06-17
