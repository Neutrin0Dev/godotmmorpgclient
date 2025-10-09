extends Node3D

@export var monster_name : String
@export var monster_scene : PackedScene
@export var monster_counter : int
@export var spawn_path : Node3D
@export var spawn_area : CollisionShape3D

var spawn_radius
var area_center

func _ready() -> void:
	if not multiplayer.is_server():
		return
	spawn_radius = spawn_area.shape.get("radius")
	area_center = spawn_area.global_position
	var monster_current_counter = spawn_path.get_child_count()
	if monster_current_counter == 1:
		initial_monster_spawn()

func initial_monster_spawn():
	for i in range(monster_counter):
		spawn_monster(i)

func spawn_monster(count: int):
	var monster = monster_scene.instantiate()
	monster.name = monster_name + str(count)
	monster.radius = spawn_radius
	monster.radius_center = area_center
	spawn_path.add_child(monster)
	monster.global_position = Vector3(
		randf_range(-spawn_radius, spawn_radius),
		0,
		randf_range(-spawn_radius, spawn_radius)
	)
	await get_tree().process_frame
