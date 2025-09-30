# MonsterSpawner.gd
@tool
class_name MonsterSpawner
extends Area3D

@onready var raycast : RayCast3D = $RayCast3D
@onready var rng = RewindableRandomNumberGenerator.new(15)
# Variables exportées (modifiables dans l'inspecteur)
@export var monster_scene: PackedScene  # Scène du monstre à spawner
@export var monster_counter: int = 3     # Nombre max de monstres
@export var MonsterPlaceHolder: Node3D # Node ou les monstres seront instancier
# Variables internes
var current_monsters_count: int = 0
var random_position : Vector3
@onready var rollbackSynchroniser = $RollbackSynchronizer

func _ready() -> void:
	rollbackSynchroniser.process_settings()
	NetworkTime.on_tick.connect(monster_spawning)

func monster_spawning(delta, tick):
	current_monsters_count = $MonsterPlaceHolder.get_child_count()
	if current_monsters_count == 0 :
		var position_calculated = random_position_calcule()
		batch_monster_spawn()

func batch_monster_spawn():
	for i in range(monster_counter):
		var monster = monster_scene.instantiate() as CharacterBody3D
		var calculated_position : Vector3 = random_position_calcule()
		monster.name = name + str(i)
		monster.set_multiplayer_authority(1)
		MonsterPlaceHolder.add_child(monster)
		monster.global_position = global_position + calculated_position

func random_position_calcule():
	var collision_shape : CollisionShape3D = $CollisionShape3D
	var radius : float = 0.0
	if collision_shape.shape is SphereShape3D:
		var sphere_shape = collision_shape.shape as SphereShape3D
		var position_calculated
		radius = sphere_shape.radius
		random_position = Vector3(
			rng.randf_range(-radius, radius),
			0,
			rng.randf_range(-radius, radius)
		)
		position_calculated = random_position
		return position_calculated
