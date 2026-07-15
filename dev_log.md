# Kick Off — Development Log

## Engine
- Godot 4.5

## Architecture

### Ship
- CharacterBody2D
- Custom deterministic movement
- Custom gravity integration
- Velocity stored manually in `velocity_vector`

### Planet
- StaticBody2D
- Gravity provider
- Landing radius
- Collision body

### GravityManager
Responsibilities:
- Register/unregister planets
- Calculate gravity
- Find closest planet
- Landing detection

---

## Day 1

### Completed

- [x] Project structure
- [x] Window configured (1280×720)
- [x] Gravity disabled from engine
- [x] Planet registration system
- [x] CharacterBody-based ship
- [x] Custom thrust
- [x] Custom rotation
- [x] Custom gravity
- [x] Multi-planet support
- [x] Trajectory prediction
- [x] Collision-aware prediction
- [x] GravityManager refactor
- [x] Closest planet helper
- [x] Landing detection framework
- [x] Debug HUD
- [x] Ship state machine foundation

---

## Current Physics

Movement:
- Position integrated through CharacterBody2D
- Velocity stored manually
- Rotation handled manually

Gravity:
- Inverse-square law
- Gravity radius cutoff
- Centralized in GravityManager

Trajectory:
- Uses identical gravity calculation as gameplay
- 300 simulation steps
- Stops at planet collision
- Uses exported prediction variables

---

## Known Issues

- No orbit tuning yet
- No launch state yet
- No atmosphere
- Landing not implemented
- Trajectory line is debug-only

---

## Decisions

### Switched from RigidBody2D → CharacterBody2D

Reason:
Needed deterministic movement and reusable physics for trajectory prediction, ship builder, and future engineering systems.

### Gravity centralized

Reason:
Avoid duplicate formulas and ensure prediction always matches gameplay.

---

## Day 2 Plan

1. Launch preparation HUD
2. NASA interface
3. Escape velocity
4. Closest approach
5. Confidence cone
6. Ship engineering data
7. Kick Off button