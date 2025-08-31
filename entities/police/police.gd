class_name Police extends GridTraveller

#region ENUMS
enum HouseState {
	NONE,
	GOING_IN,
	GOING_OUT,
	WAITING,
}
#endregion

#region CONSTANTS
const DIRECTION_MAP: Dictionary[String, Vector2i] = {
	'up': Vector2i.UP,
	'left': Vector2i.LEFT,
	'down': Vector2i.DOWN,
	'right': Vector2i.RIGHT,
}
const FRIGHTEN_ALMOST_OVER_TIME: float = 2.0
const POINTS_DEFAULT: int = 200
#endregion

#region VARIABLES
@export var house_center_point: Vector2 = Vector2(112, 140)
@export var house_entrance_point: Vector2 = Vector2(112, 116)
@export var house_state_reset: HouseState = HouseState.NONE:
	set(hsr):
		if !HouseState.values().has(hsr) or hsr == house_state_reset:
			return
		house_state_reset = hsr
@export var house_waiting_point: Vector2 = Vector2(112, 140)
@export var pikpok: PikPok
@export var spawn_point: Vector2 = Vector2.ZERO
@export var tile_target_scatter: Vector2i = Vector2i.ZERO

@onready var animatedsprite_2d_default: AnimatedSprite2D = $animatedsprite2d_default
@onready var animatedsprite_2d_taken: AnimatedSprite2D = $animatedsprite2d_taken
@onready var animatedsprite_2d_frightened: AnimatedSprite2D = $animatedsprite2d_frightened
@onready var area_2d_tunnel_trigger: Area2D = $area2d_tunnel_trigger
@onready var collectable_2d: Collectable2D = $Collectable2D
@onready var collector_2d: Collector2D = $Collector2D
@onready var timer_frighten: Timer = $timer_frighten
@onready var timer_house: Timer = $timer_house

var frighten: bool = false:
	set(f):
		if f == frighten:
			return
		frighten = f
		GM.police_frighten += 1 if f else -1
		animatedsprite_2d_frightened.visible = f
		animatedsprite_2d_default.visible = !f
		collectable_2d.disabled = !f
		if !taken:
			collector_2d.disabled = f
		points = POINTS_DEFAULT
		if f:
			tile_direction = -tile_direction
		if animatedsprite_2d_frightened.is_playing():
			animatedsprite_2d_frightened.stop()
var house_state: HouseState = house_state_reset:
	set(hs):
		if !HouseState.values().has(hs) or hs == house_state:
			return
		house_state = hs
		match hs:
			HouseState.WAITING:
				if timer_house and GM.mode == GM.Mode.PLAYING:
					timer_house.start()
var house_target_point: Vector2 = Vector2.ZERO:
	set(htp):
		house_target_point = htp
		tile_direction = global_position.direction_to(htp).round()
		match house_state:
			HouseState.GOING_IN:
				if global_position == house_waiting_point:
					house_state = HouseState.WAITING
					taken = false
			HouseState.GOING_OUT:
				if htp == Vector2.ZERO:
					tile_direction = DIRECTION_MAP['left']
					house_state = HouseState.NONE
var taken: bool = false:
	set(t):
		if t == taken:
			return
		taken = t
		GM.police_retreating += 1 if t else -1
		if t:
			SS.stats.score += points
			SS.stats.police_taken += 1
			SS.save_stats()
		else:
			collector_2d.disabled = false
		# to keep things simple, just always set frighten to false at this point
		frighten = false
		animatedsprite_2d_default.visible = !t
		animatedsprite_2d_taken.visible = t
var in_tunnel: bool = false
var mode: GM.PoliceMode = GM.police_mode:
	set(m):
		if !GM.PoliceMode.values().has(m) or m == mode:
			return
		tile_direction = -tile_direction
		mode = m
var points: int = POINTS_DEFAULT
var tile_target: Vector2i = Vector2i.ZERO:
	set(tt):
		if tt == tile_target:
			return
		tile_target = tt
#endregion

#region FUNCTIONS
func _process(delta: float) -> void:
	if GM.mode != GM.Mode.PLAYING:
		return
	
	super(delta)
	
	if house_state != HouseState.NONE:
		if house_target_point == Vector2.ZERO:
			house_target_point = get_next_house_target_point()
		global_position = global_position.move_toward(house_target_point, delta * speed)
		if global_position == house_target_point:
			house_target_point = get_next_house_target_point()
		return
	
	if global_position != coords_move_to:
		global_position = global_position.move_toward(coords_move_to, delta * speed)
		if taken:
			if tile == grid.get_tile_from_coords(house_entrance_point):
				house_state = HouseState.GOING_IN
	
	if frighten and timer_frighten.time_left <= FRIGHTEN_ALMOST_OVER_TIME and !animatedsprite_2d_frightened.is_playing():
		animatedsprite_2d_frightened.play()

func _ready() -> void:
	area_2d_tunnel_trigger.area_entered.connect(on_tunnel_trigger_area_entered)
	area_2d_tunnel_trigger.area_exited.connect(on_tunnel_trigger_area_exited)
	collectable_2d.collected.connect(on_collected)
	GM.police_frighten_time.connect(on_police_frighten_time)
	GM.mode_changed.connect(on_game_mode_changed)
	GM.reset.connect(on_reset)
	SS.stats.police_taken_changed.connect(on_police_taken_changed)
	tile_direction_changed.connect(on_tile_direction_changed)
	timer_frighten.timeout.connect(on_timer_frighten_timeout)
	timer_house.timeout.connect(on_timer_house_timeout)
	
	coords_move_to = grid.get_coords_from_tile(tile + tile_direction)
	house_state = house_state_reset
	on_tile_direction_changed(tile_direction)

func calculate_tile_direction_next() -> Vector2i:
	if frighten:
		return get_tile_direction_while_frightened()
	if taken:
		tile_target = grid.get_tile_from_coords(house_entrance_point)
		return get_tile_direction_next_from_tile_target()
	
	mode = GM.police_mode
	if mode == GM.PoliceMode.SCATTER:
		tile_target = tile_target_scatter
	if mode == GM.PoliceMode.CHASE:
		tile_target = get_tile_target_during_chase()
	return get_tile_direction_next_from_tile_target()

func get_next_house_target_point() -> Vector2:
	match house_state:
		HouseState.GOING_IN:
			if house_target_point == Vector2.ZERO:
				return house_entrance_point
			elif house_target_point == house_entrance_point:
				return house_center_point
			elif house_target_point == house_center_point:
				return house_waiting_point
		HouseState.GOING_OUT:
			if ![house_center_point, house_entrance_point].has(house_target_point):
				return house_center_point
			elif house_target_point == house_center_point:
				return house_entrance_point
			elif house_target_point == house_entrance_point:
				return Vector2.ZERO
		HouseState.WAITING:
			var above: Vector2 = Vector2(house_waiting_point.x, house_waiting_point.y - 4)
			var below: Vector2 = Vector2(house_waiting_point.x, house_waiting_point.y + 4)
			return above if house_target_point != above else below
	return Vector2.ZERO

func get_speed() -> float:
	if taken:
		return speed * 2.0
	match GM.level:
		1:
			if in_tunnel:
				return speed * 0.4
			elif GM.police_frighten > 0:
				return speed * 0.5 
			return speed * 0.75
		2, 3, 4:
			if in_tunnel:
				return speed * 0.45
			elif GM.police_frighten > 0:
				return speed * 0.55
			return speed * 0.85
		5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20:
			if in_tunnel:
				return speed * 0.5
			elif GM.police_frighten > 0:
				return speed * 0.6
			return speed * 0.95
		_:
			if in_tunnel:
				return speed * 0.5
			return speed * 0.95

func get_tile_direction_next_from_tile_target() -> Vector2i:
	if grid == null:
		return Vector2i.ZERO
	var next_tile_direction: Vector2i = Vector2i.ZERO
	for direction: Vector2i in DIRECTION_MAP.values():
		# ignore the direction from which the police came from
		if direction == -tile_direction:
			continue
		# ignore if the tile direction is not walkable
		if !is_tile_walkable(tile + direction):
			continue
		# if no next direction has been set yet: set it
		if next_tile_direction == Vector2i.ZERO:
			next_tile_direction = direction
			continue
		# override the next tile direction with this one only if it is closer
		if (tile + direction).distance_to(tile_target) < (tile + next_tile_direction).distance_to(tile_target):
			next_tile_direction = direction
	# if no next tile direction was set: walk back as last resort
	return next_tile_direction if next_tile_direction != Vector2i.ZERO else -tile_direction

func get_tile_direction_while_frightened() -> Vector2i:
	var directions_except_backwards = DIRECTION_MAP.values().filter(
		func (d: Vector2i): return d != -tile_direction
	)
	
	var random_direction = directions_except_backwards.pick_random()
	if is_tile_walkable(tile + random_direction):
		return random_direction
	
	for direction: Vector2i in DIRECTION_MAP.values():
		# ignore the direction from which the police came from
		if direction == -tile_direction:
			continue
		if is_tile_walkable(tile + direction):
			return direction
	# if no next tile direction was set: walk back as last resort
	return -tile_direction

func get_tile_target_during_chase() -> Vector2i:
	return tile_target_scatter

func on_collected() -> void:
	taken = true

func on_game_mode_changed(m: GM.Mode) -> void:
	match m:
		GM.Mode.PLAYING:
			if house_state == HouseState.WAITING:
				timer_house.start()
		GM.Mode.DEATH:
			await get_tree().create_timer(1.0).timeout
			visible = false
			process_mode = Node.PROCESS_MODE_DISABLED
			

func on_police_frighten_time(time: float) -> void:
	if taken:
		return
	frighten = true
	timer_frighten.start(time)
	if animatedsprite_2d_frightened.is_playing():
		animatedsprite_2d_frightened.stop()

func on_police_taken_changed(_pt: int) -> void:
	if !taken and frighten:
		points *= 2

func on_tile_direction_changed(td: Vector2i) -> void:
	if DIRECTION_MAP.values().has(td):
		animatedsprite_2d_default.play(DIRECTION_MAP.find_key(td))
		animatedsprite_2d_frightened.play(DIRECTION_MAP.find_key(td))

func on_timer_frighten_timeout() -> void:
	frighten = false

func on_timer_house_timeout() -> void:
	if house_state == HouseState.WAITING:
		house_state = HouseState.GOING_OUT

func on_tunnel_trigger_area_entered(area: Area2D) -> void:
	if area is Tunnel:
		in_tunnel = true

func on_tunnel_trigger_area_exited(area: Area2D) -> void:
	if area is Tunnel:
		in_tunnel = false

func on_reset(_type: GM.ResetType) -> void:
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	frighten = false
	taken = false
	global_position = spawn_point
	house_state = house_state_reset
	house_target_point = Vector2i.ZERO
	points = POINTS_DEFAULT
	tile = grid.get_tile_from_coords(global_position)
	tile_direction = tile_direction_reset
	tile_target = Vector2i.ZERO
#endregion
