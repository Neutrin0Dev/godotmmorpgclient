class_name MonsterSpawner
extends Area3D

@onready var rng = RandomNumberGenerator.new()
@export var monster_scene: PackedScene
@export var monster_counter: int = 3
@export var MonsterPlaceHolder: Node3D

var sync_seed : int = 1
var has_spawned : bool = false

func _ready() -> void:
	NetworkTime.on_tick.connect(monster_spawning)
	rng.seed = sync_seed  # Seed synchronisé

func monster_spawning(delta, tick):
	# Spawn une seule fois
	if has_spawned:
		return
	
	var current_monsters_count = MonsterPlaceHolder.get_child_count()
	if current_monsters_count == 0:
		batch_monster_spawn()
		has_spawned = true

func batch_monster_spawn():
	for i in range(monster_counter):
		var calculated_position : Vector3 = random_position_calcule()
		
		var monster = monster_scene.instantiate()
		monster.name = "monster_" + str(i)
		
		# ✅ Position AVANT add_child
		monster.position = calculated_position
		var monsterInput = monster.find_child("MonsterInput")
		if monsterInput.has_method("get_spawning_area"):
			var spawning_radius = get_spawning_radius()
			var spawning_area_position = get_spawning_area_position()
			monsterInput.get_spawning_area(spawning_radius,spawning_area_position)
			MonsterPlaceHolder.add_child(monster, true)
			monster.set_multiplayer_authority(1, true)
		
			print("[Spawn] %s at %s on peer %d" % [
				monster.name, 
				monster.global_position,
				multiplayer.get_unique_id()
			])
			sync_seed += 1
		
func random_position_calcule() -> Vector3:
	var radius = get_spawning_radius()
	return Vector3(
		rng.randf_range(-radius, radius),
		0,  # Un peu en hauteur pour la gravité
		rng.randf_range(-radius, radius)
	)
	
	return Vector3.ZERO

func get_spawning_radius():
	var collision_shape : CollisionShape3D = $CollisionShape3D
	var radius : float = 0.0
	
	if collision_shape.shape is SphereShape3D:
		var sphere_shape = collision_shape.shape as SphereShape3D
		radius = sphere_shape.radius
		return radius

func get_spawning_area_position():
	var collision_shape : CollisionShape3D = $CollisionShape3D
	var spawning_area_position = collision_shape.global_position
	return spawning_area_position
