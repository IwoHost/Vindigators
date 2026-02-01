extends StaticBody2D

# --- Konfiguracja ---
@export var hp: int = 3
@export var czy_pancerne: bool = false

# --- Referencje ---
@onready var sprite = $Sprite2D
@onready var kolizja_fizyczna = $CollisionShape2D
@onready var strefa_interakcji = $InteractionZone
@onready var particles = $GPUParticles2D

# --- Zmienne stanu ---
var gracz_blisko: bool = false
var czy_otwarte: bool = false
var czy_zniszczone: bool = false

func _ready():
	if strefa_interakcji:
		strefa_interakcji.body_entered.connect(_on_body_entered)
		strefa_interakcji.body_exited.connect(_on_body_exited)
	
	if particles:
		# --- POPRAWKA POZYCJI (Działa przy układaniu na mapie) ---
		var current_pos = global_position
		particles.top_level = true 
		particles.global_position = current_pos
		
		particles.emitting = false
		particles.one_shot = true
		
		# 1. Przypisanie tekstury
		particles.texture = sprite.texture
		
		# 2. Materiał cięcia (H/V Frames)
		var mat = CanvasItemMaterial.new()
		mat.particles_animation = true
		mat.particles_anim_h_frames = 4
		mat.particles_anim_v_frames = 4
		particles.material = mat
		
		# 3. Ustawienia fizyczne
		if particles.process_material is ParticleProcessMaterial:
			var p_mat = particles.process_material
			p_mat.scale_min = 0.04 
			p_mat.scale_max = 0.1
			p_mat.angle_min = 0.0
			p_mat.angle_max = 360.0
			p_mat.anim_offset_min = 0.0
			p_mat.anim_offset_max = 1.0
			p_mat.gravity = Vector3(0, 980, 0)

func _input(event):
	if czy_zniszczone: return
	if event.is_action_pressed("interakcja") and gracz_blisko:
		if not czy_pancerne:
			przelacz_drzwi()

func przelacz_drzwi():
	if czy_otwarte: zamknij()
	else: otworz()

func otworz():
	czy_otwarte = true
	sprite.frame = 1
	sprite.offset.x = 300
	kolizja_fizyczna.set_deferred("disabled", true)

func zamknij():
	czy_otwarte = false
	sprite.frame = 0
	sprite.offset.x = 0
	kolizja_fizyczna.set_deferred("disabled", false)

func take_damage(amount: int = 1):
	if czy_zniszczone: return
	hp -= amount
	
	# Hitstop (Zatrzymanie czasu)
	Engine.time_scale = 0.05
	await get_tree().create_timer(0.05 * Engine.time_scale).timeout
	Engine.time_scale = 1.0
	
	# Błysk HDR
	sprite.modulate = Color(10, 10, 10)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	if hp > 0:
		if particles:
			particles.amount_ratio = 0.2
			particles.restart()
			particles.emitting = true
	else:
		rozwal()

func rozwal():
	if czy_zniszczone: return
	czy_zniszczone = true
	
	# Pokazujemy klatkę gruzów
	sprite.frame = 2 
	sprite.offset.x = 0
	sprite.visible = true
	
	if particles:
		particles.amount_ratio = 1.0
		
		# Przepinamy cząsteczki do świata (root), żeby nie zniknęły
		var world_pos = particles.global_position
		if particles.get_parent():
			particles.get_parent().remove_child(particles)
		get_tree().root.add_child(particles)
		
		particles.global_position = world_pos
		particles.restart()
		particles.emitting = true
		
		get_tree().create_timer(20.0).timeout.connect(particles.queue_free)
	
	# Wyłączamy fizykę i interakcję
	kolizja_fizyczna.set_deferred("disabled", true)
	strefa_interakcji.set_deferred("monitoring", false)

func _on_body_entered(body):
	if body.name == "Player": gracz_blisko = true

func _on_body_exited(body):
	if body.name == "Player": gracz_blisko = false
