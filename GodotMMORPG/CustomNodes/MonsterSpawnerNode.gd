# MonsterSpawner.gd
@tool
class_name MonsterSpawner
extends Area3D

@onready var raycast : RayCast3D = $RayCast3D
@onready var rng = RandomNumberGenerator.new()
# Variables exportées (modifiables dans l'inspecteur)
@export var monster_scene: PackedScene  # Scène du monstre à spawner
@export var monster_counter: int = 3     # Nombre max de monstres
@export var spawn_delay: float = 10.0   # Délai de respawn (secondes)
@export var detection_radius: float = 50.0  # Rayon de détection du joueur
@export var MonsterPlaceHolder: Node # Node ou les monstres seront instancier
@export var RandomSeed: int
# Variables internes
var current_monsters_count: int = 0
var players_in_zone: Array = []
var spawn_timer: Timer


func _ready() -> void:
	
	rng.seed = RandomSeed
	NetworkTime.on_tick.connect(monster_spawning)
	
func monster_spawning(ticktime, tick):
	current_monsters_count = $MonsterPlaceHolder.get_child_count()
	if current_monsters_count == 0 :
		batch_monster_spawn()
	
func batch_monster_spawn():
	var collision_shape : CollisionShape3D = $CollisionShape3D
	var radius : float = 0.0
	if collision_shape.shape is SphereShape3D:
		var sphere_shape = collision_shape.shape as SphereShape3D
		radius = sphere_shape.radius
		print("Rayon de la sphère : ", radius)

	for i in range(monster_counter):
		var monster = monster_scene.instantiate() as Node3D
		var random_position = Vector3(
			rng.randf_range(-radius, radius),
			raycast.get_collision_point().y,
			rng.randf_range(-radius, radius)
		)
		monster.name = name + str(i)
		MonsterPlaceHolder.add_child(monster)
		monster.set_multiplayer_authority(1)
		monster.global_position = global_position + random_position
		
		
	
