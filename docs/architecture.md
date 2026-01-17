# Architecture: Deterministic Seams

This template uses a **GDScript-first** approach with **deterministic seams** that enable testing, replays, and future Rust migration.

## Core Concept: The Seam Pattern

All game logic flows through a single function:

```gdscript
# godot/core/core_api.gd
static func step(state: Dictionary, inp: Dictionary) -> Dictionary:
    var next := state.duplicate(true)
    var delta := int(inp.get("delta", 1))
    next["tick"] = int(next.get("tick", 0)) + delta
    return next
```

**Key properties:**
- **Pure-data in/out**: Only dictionaries, no Node references
- **No side effects**: Same inputs always produce same outputs
- **Deterministic**: Enables fixture testing and replays

## Why This Pattern?

### 1. Fixture Testing
Test game logic without running Godot:
```json
{
  "initial_state": { "tick": 0 },
  "input": { "delta": 2 },
  "expected_state": { "tick": 2 }
}
```

### 2. Deterministic Replays
Record inputs → replay produces identical game state:
```gdscript
# SimClock can batch-run ticks
var final_state = SimClock.run_ticks(initial_state, recorded_inputs, 1000)
```

### 3. AI Training
The seam is perfect for ML training loops:
```python
# Python can call the same step() logic
for _ in range(1000):
    state = core.step(state, ai.decide(state))
```

### 4. Rust Migration Path
Swap implementation without changing callers:
```gdscript
static func step(state: Dictionary, inp: Dictionary) -> Dictionary:
    if use_rust():
        return RustCore.step(state, inp)  # Rust implementation
    else:
        # GDScript implementation
        var next := state.duplicate(true)
        ...
```

## The Three Seams

### `step(state, input) -> StepResult`
The main simulation tick. Returns **both** the next state **and** deterministic events.

```gdscript
var state = GameState.from_dict({"tick": 0, "seed_val": 0, "rng_state": 42})
var input = GameInput.from_dict({"delta": 1})
var result: StepResult = CoreAPI.step(state, input)

# result.state = GameState with tick=1
# result.events = [GameEvent.tick_advanced(0, 1)]
```

Events describe "what happened" during the step - they're deterministic outputs, not side effects.
This enables replay systems to re-emit the same events given the same inputs.

### `decide(state) -> decision`
AI decision-making. Returns what action to take given current state.

```gdscript
var state = {"tick": 50, "enemies": [...], "player_pos": Vector2(100, 200)}
var decision = CoreAPI.decide(state)
# decision = {"action": "move", "direction": Vector2(1, 0)}
```

### `generate(seed, params) -> content`
Procedural generation. Creates content deterministically from a seed.

```gdscript
var level = CoreAPI.generate(12345, {"width": 100, "height": 100, "difficulty": 3})
# level = {"tiles": [...], "enemies": [...], "items": [...]}
```

## File Organization

```
godot/core/
├── core_api.gd           # The three seams: step, decide, generate
├── schema.gd             # JSON normalization, validation helpers
├── sim_clock.gd          # Batch simulation driver
└── resources/
    ├── game_state.gd     # Typed state with RNG
    ├── game_input.gd     # Typed input
    ├── game_event.gd     # Deterministic events
    └── step_result.gd    # step() return type (state + events)

godot/adapters/
├── input_adapter.gd      # Godot Input → GameInput
├── view_adapter.gd       # GameState → Node updates
└── event_adapter.gd      # GameEvent → VFX/SFX/UI

godot/tests/
└── fixtures/             # JSON test files
    ├── step_basic.json
    └── step_with_events.json
```

## Data Contracts

### Serialization Layer

The core uses **typed Resources** (`GameState`, `GameInput`) internally, but all data must serialize to JSON-compatible primitives for:
- Fixture testing (JSON files)
- Rust interop (serde)
- Network replay

**Serialized format (Dictionary):**
```gdscript
{
    "tick": 0,           # Current simulation tick
    "seed_val": 12345,   # RNG seed for reproducibility
    "rng_state": 0,      # Deterministic RNG position
}
```

**Typed format (Resource):**
```gdscript
var state := GameState.new()
state.tick = 0
state.seed_val = 12345
state.rng_state = 0
```

### Serialization Rules

When converting to Dictionary (`to_dict()`):
- Only use: `int`, `float`, `String`, `bool`, `Array`, `Dictionary`
- No Godot types: `Vector2`, `Node`, `AudioStream`
- Use `position_x`/`position_y` instead of `Vector2`

**Why?** Dictionaries can be:
1. Serialized to JSON for fixtures
2. Passed to Rust via GDExtension
3. Sent over network for multiplayer
4. Recorded for deterministic replay

### Adapters Bridge the Gap

Adapters convert between serializable state and Godot presentation types:

```
Godot Input singleton  →  InputAdapter  →  GameInput (typed)
GameState (typed)      →  ViewAdapter   →  Node positions (Vector2)
GameEvent (typed)      →  EventAdapter  →  AudioStreamPlayer, VFX scenes
```

The **core** never touches `Input`, `Node`, `Vector2`, or other Godot types. Adapters do that translation at the boundary.

### Input Dictionary
Per-tick input (serialized form):
```gdscript
{
    "delta": 1,          # Tick delta (usually 1)
    "action": "move",    # Player action
    "direction_x": 1.0,  # Input direction (not Vector2)
    "direction_y": 0.0,
}
```

## Testing Workflow

1. **Write the logic** in `godot/core/core_api.gd`
2. **Create a fixture** in `godot/tests/fixtures/my_test.json`
3. **Run tests**: `make dev-fixtures`

```json
// godot/tests/fixtures/attack_reduces_health.json
{
  "initial_state": { "tick": 0, "health": 100 },
  "input": { "action": "take_damage", "damage": 25 },
  "expected_state": { "tick": 1, "health": 75 }
}
```

## Migration to Rust

When performance matters, implement the seam in Rust:

```rust
// rust/core/src/lib.rs
pub fn step(state: HashMap<String, Value>, input: HashMap<String, Value>) -> HashMap<String, Value> {
    let mut next = state.clone();
    let delta = input.get("delta").unwrap_or(&Value::Int(1)).as_i64().unwrap();
    let tick = next.get("tick").unwrap_or(&Value::Int(0)).as_i64().unwrap();
    next.insert("tick".to_string(), Value::Int(tick + delta));
    next
}
```

Then update the GDScript seam to dispatch:
```gdscript
static func step(state: Dictionary, inp: Dictionary) -> Dictionary:
    if use_rust():
        var rust_core = ClassDB.instantiate("RustCore")
        return rust_core.step(state, inp)
    else:
        # GDScript fallback
        ...
```

Run the same fixtures against both implementations to verify equivalence.

## Deterministic Events

Events are messages emitted by `step()` that describe what happened during the simulation tick. They're part of the deterministic output - same inputs produce same events.

### Event Types

```gdscript
enum Type {
    TICK_ADVANCED,      # Simulation time moved forward
    DAMAGE_APPLIED,     # Entity took damage
    ENTITY_SPAWNED,     # New entity created
    ENTITY_DESTROYED,   # Entity removed
    SFX_REQUESTED,      # Play a sound effect
    VFX_REQUESTED,      # Spawn visual effect
    UI_MESSAGE,         # Show UI notification
}
```

### Creating Events

Events are created via factory methods in `GameEvent`:

```gdscript
# In core_api.gd step() function:
events.append(GameEvent.tick_advanced(old_tick, next.tick))
events.append(GameEvent.damage_applied(entity_id, 25, new_health))
events.append(GameEvent.sfx_requested("hit"))
```

### Testing Events

Fixtures can assert both state and events:

```json
{
  "initial_state": { "tick": 0, "seed_val": 0, "rng_state": 0 },
  "input": { "delta": 2 },
  "expected_state": { "tick": 2, "seed_val": 0, "rng_state": 0 },
  "expected_events": [
    { "type": "TICK_ADVANCED", "payload": { "old_tick": 0, "new_tick": 2 } }
  ]
}
```

## Adapters

Adapters form the boundary between the deterministic core and Godot's presentation layer.

### InputAdapter
Converts Godot's `Input` singleton to typed `GameInput`:

```gdscript
func _process(_delta):
    var inp := InputAdapter.read_input()  # Godot Input → GameInput
    var result := CoreAPI.step(state, inp)
```

### ViewAdapter
Applies `GameState` to Godot Nodes for rendering:

```gdscript
ViewAdapter.apply(state, self)  # Update node positions, animations
ViewAdapter.interpolate(prev, next, t, self)  # Smooth rendering between ticks
```

### EventAdapter
Consumes `GameEvent[]` and triggers presentation effects:

```gdscript
var event_adapter := EventAdapter.new()
event_adapter.process_events(result.events, self)  # VFX, SFX, UI
```

The adapter registers asset paths:
```gdscript
event_adapter.sfx_registry["hit"] = "res://audio/sfx/hit.wav"
event_adapter.vfx_registry["explosion"] = "res://vfx/explosion.tscn"
```

**Registry Design:** The registries use `Dictionary` with `String` keys and `String` values (resource paths). This is intentionally simple:
- Keys are semantic identifiers from the core ("hit", "explosion")
- Values are Godot resource paths
- No typed wrapper needed - the simplicity aids debugging and hot-reloading

For larger projects, consider a `Resource`-based registry that can be edited in the Godot inspector.

## Scaling Patterns

As your game grows, evolve the architecture in phases. Each phase builds on the previous while maintaining the deterministic seam contract.

### Current: Typed Resources

The template now uses typed Resource classes for state and input:

```gdscript
# godot/core/resources/game_state.gd
class_name GameState extends Resource

@export var tick: int = 0
@export var seed_val: int = 0

static func from_dict(data: Dictionary):
    # Convert from JSON/Dictionary
    ...

func to_dict() -> Dictionary:
    # Convert to JSON/Dictionary
    return {"tick": tick, "seed_val": seed_val}
```

**Benefits:**
- Autocomplete and type checking in editor
- Explicit field definitions (no magic strings)
- 1:1 mapping to Rust structs
- Resources still serialize through `to_dict()` for fixtures

**Usage:**
```gdscript
# Dictionary API (for fixtures, JSON interop)
var next = CoreAPI.step({"tick": 0, "seed_val": 0}, {"delta": 1})

# Typed API (for game code)
var state = GameState.from_dict({"tick": 0})
var input = GameInput.from_dict({"delta": 1})
var next_state = CoreAPI.step_typed(state, input)
```

### Phase 2: Entity Resources

When you need multiple game objects, add an Entity Resource:

```gdscript
# godot/core/resources/entity.gd
class_name Entity extends Resource

@export var id: int = 0
@export var position_x: float = 0.0
@export var position_y: float = 0.0
@export var health: int = 100

static func from_dict(data: Dictionary):
    var e = Entity.new()
    e.id = int(data.get("id", 0))
    e.position_x = float(data.get("position_x", 0.0))
    e.position_y = float(data.get("position_y", 0.0))
    e.health = int(data.get("health", 100))
    return e

func to_dict() -> Dictionary:
    return {
        "id": id,
        "position_x": position_x,
        "position_y": position_y,
        "health": health
    }
```

Update GameState to include entities:
```gdscript
@export var entities: Dictionary = {}  # id -> Entity

func to_dict() -> Dictionary:
    var ents = {}
    for id in entities:
        ents[str(id)] = entities[id].to_dict()
    return {"tick": tick, "seed_val": seed_val, "entities": ents}
```

### Phase 3: Systems Decomposition

When `step()` grows beyond ~100 lines, decompose into systems:

```gdscript
# godot/core/systems/physics_system.gd
class_name PhysicsSystem

static func step(state: GameState, input: GameInput) -> void:
    for entity in state.entities.values():
        entity.position_x += entity.velocity_x * input.delta
        entity.position_y += entity.velocity_y * input.delta
```

```gdscript
# godot/core/core_api.gd
static func step_typed(state, inp):
    var next = state.duplicate_state()
    PhysicsSystem.step(next, inp)
    CombatSystem.step(next, inp)
    AISystem.step(next, inp)
    return next
```

**When to add systems:**
- Multiple distinct domains (physics, combat, AI)
- Code becomes hard to navigate
- Different tick rates needed (physics every frame, AI every 10 frames)

### Rust Migration Path

Each pattern maps directly to Rust:

| GDScript | Rust |
|----------|------|
| `class_name GameState extends Resource` | `struct GameState` |
| `@export var tick: int` | `pub tick: i32` |
| `static func from_dict(...)` | `impl From<HashMap<...>>` |
| `func to_dict()` | `impl Into<HashMap<...>>` |
| `PhysicsSystem.step(state, input)` | `physics::step(&mut state, &input)` |

When migrating:
1. Implement the Rust struct matching the Resource
2. Add `serde` for JSON serialization
3. Expose through GDExtension bridge
4. Run same fixtures to verify equivalence
5. Swap implementation in `CoreAPI.step()`

### What to Skip

**Don't add until you need it:**
- Full ECS (Bevy-style) - overkill for most games
- Node-based state - harder to migrate
- Complex inheritance - Rust prefers composition
- Generic systems framework - YAGNI

**Keep it simple:**
- Start with typed Resources (current state)
- Add entities when you have multiple game objects
- Add systems when step() gets unwieldy
- Migrate to Rust when you need performance

### Scaling: Event Granularity

Events can be categorized by their semantic level:

**Semantic Events** (what happened):
- `DamageApplied { entity_id, amount, new_health }`
- `EntitySpawned { id, type, x, y }`
- `LevelCompleted { score, time }`

**Presentation Events** (how to show it):
- `SfxRequested { key: "hit" }`
- `VfxRequested { key: "explosion", x, y }`
- `UiMessage { text_key: "game_over" }`

#### Trade-offs

| Approach | Pros | Cons |
|----------|------|------|
| **Semantic only** | Core doesn't know about assets; can swap audio/VFX packs without touching logic | EventAdapter must map semantic → presentation; more code in shell |
| **Mixed (current)** | Simpler; core can request specific effects; less adapter logic | Core couples to asset keys; changing audio requires core changes |
| **Presentation only** | Direct control; no mapping layer | Core becomes a presentation engine; loses semantic meaning |

#### Recommendation

- **Small projects / game jams**: Use mixed approach (current). Ship fast.
- **Larger projects**: Migrate to semantic-only. Core emits `DamageApplied`, EventAdapter decides to play "hit.wav" based on damage type, entity, etc.
- **Rollback/netcode**: Semantic events are safer - presentation can be re-derived from semantic events during resimulation.

#### Migration Path

When moving to semantic-only:
1. Remove `SFX_REQUESTED`, `VFX_REQUESTED` from GameEvent enum
2. Add semantic events for each game action
3. Update EventAdapter to map semantic events to presentation
4. Fixtures only assert semantic events (presentation is non-deterministic in replays anyway)
