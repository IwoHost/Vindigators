extends Node

var czy_atakuje = false

# --- SYSTEM BRONI ---
@export var obecna_bron: WeaponData_Podstawowe 
@export var ekwipunek: Array[WeaponData_Podstawowe] = [] 
@export var hud: Control # Zmienione na Control, żeby pasowało do skryptu powyżej!

func _ready():
	if ekwipunek.size() > 0:
		obecna_bron = ekwipunek[0] 
		# Czekamy ułamek sekundy, żeby HUD zdążył się załadować
		await get_tree().process_frame
		if hud:
			hud.aktualizuj_hud(ekwipunek, 0) 

func _input(event):
	if event.is_action_pressed("klawisz_1"):
		zmien_bron(0)
	elif event.is_action_pressed("klawisz_2"):
		zmien_bron(1)

func zmien_bron(index: int):
	if index < ekwipunek.size() and ekwipunek[index] != null:
		obecna_bron = ekwipunek[index]
		print("Zmieniono broń na: ", obecna_bron.nazwa)
		
		if hud:
			hud.aktualizuj_hud(ekwipunek, index)

func wykonaj_atak(player: CharacterBody2D):
	if czy_atakuje or not obecna_bron: return
	
	var attack_zone = player.get_node_or_null("HammerZone")
	if not attack_zone: return

	var weapon_sprite = attack_zone.get_node_or_null("Sprite2D")
	var weapon_collision = attack_zone.get_node_or_null("CollisionShape2D")
	
	if not weapon_sprite or not weapon_collision: return
	
	czy_atakuje = true
	
	var direction = attack_zone.scale.x
	weapon_sprite.texture = obecna_bron.tekstura
	
	attack_zone.position = Vector2.ZERO
	var attack_pos = Vector2(obecna_bron.zasieg, 0)
	weapon_sprite.position = attack_pos
	weapon_collision.position = attack_pos
	
	weapon_sprite.visible = true
	
	player.velocity.x += direction * obecna_bron.odrzut_gracza
	
	var s_angle = obecna_bron.kat_startowy if direction > 0 else -obecna_bron.kat_startowy
	var e_angle = obecna_bron.kat_koncowy if direction > 0 else -obecna_bron.kat_koncowy
	attack_zone.rotation_degrees = s_angle
	
	var tween = player.create_tween()
	tween.tween_property(attack_zone, "rotation_degrees", e_angle, obecna_bron.szybkosc_ataku).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await player.get_tree().create_timer(obecna_bron.szybkosc_ataku / 2.0).timeout
	sprawdz_trafienie(attack_zone)

	await tween.finished
	weapon_sprite.visible = false
	attack_zone.rotation_degrees = 0
	czy_atakuje = false

func sprawdz_trafienie(zone):
	for target in zone.get_overlapping_areas():
		if target.has_method("take_damage"):
			target.take_damage(obecna_bron.obrazenia)
		elif target.get_parent().has_method("take_damage"):
			target.get_parent().take_damage(obecna_bron.obrazenia)

	for target in zone.get_overlapping_bodies():
		if target.has_method("take_damage"):
			target.take_damage(obecna_bron.obrazenia)
