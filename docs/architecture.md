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

### `step(state, input) -> new_state`
The main simulation tick. Advances game state by one frame.

```gdscript
var state = {"tick": 0, "health": 100}
var input = {"action": "attack", "target": 42}
var next_state = CoreAPI.step(state, input)
# next_state = {"tick": 1, "health": 100, ...}
```

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
├── core_api.gd     # The three seams: step, decide, generate
├── schema.gd       # JSON normalization, validation helpers
└── sim_clock.gd    # Batch simulation driver

godot/tests/
└── fixtures/       # JSON test files
    ├── step_basic.json
    └── step_edge_cases.json
```

## Data Contracts

### State Dictionary
Game state is a flat dictionary with primitives:
```gdscript
{
    "tick": 0,           # Current simulation tick
    "seed": 12345,       # RNG seed for reproducibility
    "health": 100,       # Player health
    "position_x": 0.0,   # Use primitives, not Vector2
    "position_y": 0.0,
}
```

**Rules:**
- Only use: `int`, `float`, `String`, `bool`, `Array`, `Dictionary`
- No Godot types: `Vector2`, `Node`, `Resource`
- Flat structure preferred for easy serialization

### Input Dictionary
Per-tick input:
```gdscript
{
    "delta": 1,          # Tick delta (usually 1)
    "action": "move",    # Player action
    "direction_x": 1.0,  # Input direction
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
