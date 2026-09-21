extends StaticBody2D
class_name Chunk

#chunk class used to create one bit of terrain of the world
#aka procgen prep

const CHUNK_WIDTH  = 280
const GROUND_HEIGHT  = 100


#set chunk width and height of ground to 200 px and 100px - constant. 

@onready var _polygon: Polygon2D = $Polygon2D

var _chunk_index: int = 0

#assigning varibles with linked nodes using $, and creating chunk index variables

const TREE_VARIANTS: int = 12
static var _last_tree_variant: int = -1

func _spawn_background() -> void:
	"randomly picks a tree backdrop variant, avoiding immediate repeats"
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _chunk_index * 777
	var variant: int = rng.randi_range(1, TREE_VARIANTS)

	if variant == _last_tree_variant and TREE_VARIANTS > 1:
		variant = (variant % TREE_VARIANTS) + 1  # shift to a different one

	_last_tree_variant = variant
	var path: String = "res://backgrounds/tree_bg_%d.png" % variant

	if not ResourceLoader.exists(path):
		return

	var bg: Sprite2D = Sprite2D.new()
	bg.texture = load(path)
	bg.centered = false
	bg.position = Vector2(0, -position.y)
	bg.z_index = -1
	add_child(bg)

var _clouds: Array = []
const CLOUD_DRIFT_SPEED: float = 10.0  # pixels per second, tweak to taste


const CLOUD_VARIANTS: int = 5
const CLOUD_SPAWN_CHANCE: float = 0.35

func _spawn_clouds() -> void:
	"occasionally adds a cloud layer above the treeline for this chunk"
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _chunk_index * 333

	if rng.randf() > CLOUD_SPAWN_CHANCE:
		return

	var variant: int = rng.randi_range(1, CLOUD_VARIANTS)
	var path: String = "res://backgrounds/cloud_bg_%d.png" % variant

	if not ResourceLoader.exists(path):
		return

	var cloud: Sprite2D = Sprite2D.new()
	cloud.scale = Vector2(1.5, 1.5)
	cloud.texture = load(path)
	cloud.centered = false
	cloud.position = Vector2(0, -position.y - 100)
	cloud.z_index = 0
	add_child(cloud)
	_clouds.append(cloud)

func _process(delta: float) -> void:
	"slowly drifts clouds sideways for a bit of life"
	for cloud in _clouds:
		if is_instance_valid(cloud):
			cloud.position.x += CLOUD_DRIFT_SPEED * delta
			
	if is_instance_valid(_fog_sprite):
		var pulse: float = (sin(Time.get_ticks_msec() / 1000.0) + 1.0) / 2.0
		_fog_sprite.modulate.a = lerp(0.2, 0.4, pulse)

func _ready() -> void:
	# test
	if get_parent().name == 'Main':
		setup(0)
		
const ITEM_SPAWN_CHANCE: float = 0.3
const _item_scene: PackedScene = preload("res://item.tscn")


func _spawn_items(heights: Array, step: float) -> void:
	'maybe spawn an item somewhere on this chunk'
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _chunk_index * 1000
	
	if rng.randf() > ITEM_SPAWN_CHANCE:
		return
	
	var step_idx: int = rng.randi_range(0, POINTS_PER_CHUNK - 1)
	var item_x: float = (step_idx * step) + (step / 2)
	var item_y: float = heights[step_idx] - 30
	
	var types: Array = Item.TYPES
	var chosen_type: String = types[rng.randi_range(0, types.size() - 1)]
	
	var new_item: Item = _item_scene.instantiate()
	add_child(new_item)
	new_item.position = Vector2(item_x, item_y)
	new_item.setup(chosen_type)
		
		
const BUSH_SPAWN_CHANCE: float = 0.25

func _spawn_berry_bush(heights: Array, step: float) -> void:
	"occasionally spawns a collectible berry bush"
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _chunk_index * 444

	if rng.randf() > BUSH_SPAWN_CHANCE:
		return

	var step_idx: int = rng.randi_range(0, POINTS_PER_CHUNK - 1)
	var bush_x: float = (step_idx * step) + (step / 2)
	var bush_y: float = heights[step_idx] - 20

	var bush_scene: PackedScene = preload("res://item.tscn")
	var new_bush: Item = bush_scene.instantiate()
	add_child(new_bush)
	new_bush.position = Vector2(bush_x, bush_y)
	new_bush.setup("berries")

		
func setup(chunk_index: int) -> void: #public
	_chunk_index = chunk_index
	position.x = chunk_index * CHUNK_WIDTH
	position.y = 500 
	_generate_terrain() #calling inbult function from GE

#time to implement Perlin noise to creaet a smooth procedgen

const POINTS_PER_CHUNK: int = 4      # how many sample points along the top
const TERRAIN_AMPLITUDE: float = 200.0 # how tall the bumps are
const TERRAIN_BASE: float = 200.0     # base ground height
const NOISE_FREQUENCY: float = 0.009  # smaller = wider hills, larger = bumpier


# A shared noise generator - same seed = same world every time
static var _noise: FastNoiseLite = _setup_noise()

static func _setup_noise() -> FastNoiseLite:
	'create the noise generator thats used by all chunks'
	var n: FastNoiseLite = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_PERLIN
	#using perlin noise as its smoother
	n.seed = 42
	n.frequency = NOISE_FREQUENCY
	return n
	
#replace generate terrain to implement perlin noise

const GRASS_THICKNESS: float = 80.0    # how thick the green strip is
const SHADOW_THICKNESS: float = 10.0    # how tall each shadow band is


func _generate_terrain() -> void:
	'builds blocky terrain with grass + dirt + shadows'
	_spawn_background()
	var top_points: PackedVector2Array = PackedVector2Array()   # top edge of the ground
	var step: float = float(CHUNK_WIDTH) / POINTS_PER_CHUNK
	
	
	# Sample heights for each step
	var heights: Array = []
	for i in range(POINTS_PER_CHUNK):
		var world_x: float = position.x + (i * step)
		var noise_value: float = _noise.get_noise_1d(world_x)
		var y: float = -noise_value * TERRAIN_AMPLITUDE
		y = round(y / 40.0) * 40.0
		heights.append(y)
	
	# Clamp height jumps so terrain is always jumpable
	const MAX_STEP: float = 120.0
	for i in range(1, heights.size()):
		var diff: float = heights[i] - heights[i - 1]
		if abs(diff) > MAX_STEP:
			heights[i] = heights[i - 1] + (MAX_STEP if diff > 0 else -MAX_STEP)
	
	# Build the top edge with flat steps
	for i in range(POINTS_PER_CHUNK):
		top_points.append(Vector2(i * step, heights[i]))
		top_points.append(Vector2((i + 1) * step, heights[i]))
	
	#  DIRT 
	var dirt_points: PackedVector2Array = top_points.duplicate()
	dirt_points.append(Vector2(CHUNK_WIDTH, TERRAIN_BASE + 200))
	dirt_points.append(Vector2(0, TERRAIN_BASE + 200))
	_polygon.polygon = dirt_points
	_polygon.uv = dirt_points  # use the same coordinates so texture tiles at actual pixel scale
	_polygon.texture = load("res://backgrounds/dirt_texture.png")
	_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_polygon.color = Color(1, 1, 1)
	
		# Clear any old collision shapes from a previous generation
	for child in get_children():
		if child is CollisionShape2D:
			child.queue_free()

	# One simple rectangle collider per terrain step - always reliable
	for i in range(POINTS_PER_CHUNK):
		var x1: float = i * step
		var x2: float = (i + 1) * step
		var top_y: float = heights[i]
		var bottom_y: float = TERRAIN_BASE + 200

		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(x2 - x1, bottom_y - top_y)

		var col: CollisionShape2D = CollisionShape2D.new()
		col.shape = shape
		col.position = Vector2((x1 + x2) / 2.0, (top_y + bottom_y) / 2.0)
		add_child(col)
	
	# GRASS - one rectangle per step
	for i in range(POINTS_PER_CHUNK):
		var gx1: float = i * step
		var gx2: float = (i + 1) * step
		var gy: float = heights[i]
		var grass_rect: PackedVector2Array = PackedVector2Array()
		grass_rect.append(Vector2(gx1, gy))
		grass_rect.append(Vector2(gx2, gy))
		grass_rect.append(Vector2(gx2, gy + GRASS_THICKNESS))
		grass_rect.append(Vector2(gx1, gy + GRASS_THICKNESS))
		_make_overlay_polygon("Grass_%d" % i, grass_rect, Color(0.45, 0.65, 0.30), "res://backgrounds/grass_texture.png")
	
	# SHADOWS
	# One thin band right under each step
	for i in range(POINTS_PER_CHUNK):
		var x1: float = i * step
		var x2: float = (i + 1) * step
		var y: float = heights[i]
		var shadow: PackedVector2Array = PackedVector2Array()
		shadow.append(Vector2(x1, y))
		shadow.append(Vector2(x2, y))
		shadow.append(Vector2(x2, y + SHADOW_THICKNESS))
		shadow.append(Vector2(x1, y + SHADOW_THICKNESS))
		_make_overlay_polygon("Shadow_%d" % i, shadow, Color(0, 0, 0, 0.25))
		
	_spawn_items(heights, step)
	_spawn_berry_bush(heights, step)
	_spawn_decorative_bush(heights, step)
	
	_spawn_background()
	_spawn_clouds()
	_spawn_stipple()
	_spawn_fog()
	_spawn_fog_patch()
	_spawn_barn()

	
	


func _grass_strip(top_points: PackedVector2Array) -> PackedVector2Array:
	'returns the grass strip polygon - top edge + a band below it'
	var grass: PackedVector2Array = top_points.duplicate()
	for i in range(top_points.size() - 1, -1, -1):
		var p: Vector2 = top_points[i]
		grass.append(Vector2(p.x, p.y + GRASS_THICKNESS))
	return grass

func _make_overlay_polygon(node_name: String, points: PackedVector2Array, color: Color, texture_path: String = "") -> void:
	print("Making overlay: ", node_name, " with ", points.size(), " points")
	var poly: Polygon2D = Polygon2D.new()
	poly.name = node_name
	poly.polygon = points
	poly.color = color
	poly.z_index = 1
	if texture_path != "" and ResourceLoader.exists(texture_path):
		poly.texture = load(texture_path)
		var offset_uv: PackedVector2Array = PackedVector2Array()
		for p in points:
			offset_uv.append(p + Vector2(10, 00))
		poly.uv = offset_uv
		poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		poly.color = Color(1, 1, 1)
	add_child(poly)

func _spawn_stipple() -> void:
	"adds a stipple overlay for this chunk"
	var path: String = "res://backgrounds/stipple.png"
	if not ResourceLoader.exists(path):
		return
	var overlay: Sprite2D = Sprite2D.new()
	overlay.texture = load(path)
	overlay.centered = false
	overlay.position = Vector2(0, -position.y)
	overlay.modulate = Color(1, 1, 1, 0.6)
	overlay.z_index = 20
	add_child(overlay)

var _fog_sprite: Sprite2D

func _spawn_fog() -> void:
	"adds a fog layer for this chunk"
	var path: String = "res://backgrounds/fog_light.png"
	if not ResourceLoader.exists(path):
		return
	_fog_sprite = Sprite2D.new()
	_fog_sprite.texture = load(path)
	_fog_sprite.centered = false
	_fog_sprite.position = Vector2(0, -position.y + 300)
	_fog_sprite.modulate = Color(0.8, 0.8, 0.8, 0.2)
	_fog_sprite.z_index = 15
	add_child(_fog_sprite)
	
	
const FOG_PATCH_VARIANTS: int = 2
const FOG_PATCH_CHANCE: float = 0.3
	
func _spawn_fog_patch() -> void:
	"occasionally adds a fog patch split into front/back layers around the player"
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _chunk_index * 555

	if rng.randf() > FOG_PATCH_CHANCE:
		return

	var variant: int = rng.randi_range(1, FOG_PATCH_VARIANTS)
	var path: String = "res://backgrounds/fog_patch_%d.png" % variant

	print("Fog patch check - path: ", path, " exists: ", ResourceLoader.exists(path))
	if not ResourceLoader.exists(path):
		return

	if not ResourceLoader.exists(path):
		return



	
		
	
	# Back layer - behind the player
	var fog_back: Sprite2D = Sprite2D.new()
	fog_back.texture = load(path)
	fog_back.centered = false
	fog_back.position = Vector2(0, -position.y + 200)
	fog_back.modulate = Color(0.85, 0.85, 0.85, 0.3)
	fog_back.z_index = 5   # below player (player is 10)
	add_child(fog_back)
	_clouds.append(fog_back)

	# Front layer - in front of the player, slightly offset for variation
	var fog_front: Sprite2D = Sprite2D.new()
	fog_front.texture = load(path)
	fog_front.centered = false
	fog_front.position = Vector2(20, -position.y + 220)
	fog_front.modulate = Color(0.85, 0.85, 0.85, 0.5)  # slightly lighter so it doesn't obscure too much
	fog_front.z_index = 16   # above player
	add_child(fog_front)
	_clouds.append(fog_front)
	
const BARN_INTERVAL_CHUNKS: int = 36  # ~10,000px ÷ 280px chunk width ≈ 36

func _spawn_barn() -> void:
	"a barn landmark appearing roughly every 10,000 pixels"
	if _chunk_index % BARN_INTERVAL_CHUNKS != 0 or _chunk_index == 0:
		return

	var path: String = "res://backgrounds/barn.png"
	if not ResourceLoader.exists(path):
		return

	var barn: Sprite2D = Sprite2D.new()
	barn.texture = load(path)
	barn.centered = false
	barn.position = Vector2(0, -position.y + -50)  # adjust based on barn art's actual height
	barn.z_index = -0.5
	add_child(barn)
	
const BUSH_BG_CHANCE: float = 0.7

func _spawn_decorative_bush(heights: Array, step: float) -> void:
	"adds a non-collectible berry bush for visual detail"
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _chunk_index * 222

	if rng.randf() > BUSH_BG_CHANCE:
		return

	var path: String = "res://backgrounds/berry_bush.png"
	if not ResourceLoader.exists(path):
		return

	var step_idx: int = rng.randi_range(0, POINTS_PER_CHUNK - 1)
	var bush_x: float = step_idx * step
	var bush_y: float = heights[step_idx]

	var bush: Sprite2D = Sprite2D.new()
	bush.texture = load(path)
	bush.scale = Vector2(1.5, 1.5)
	bush.centered = false
	bush.modulate = Color(0,0.3,0, 0.6)
	bush.position = Vector2(bush_x, bush_y - 100)
	bush.z_index = -0.8
	add_child(bush)
