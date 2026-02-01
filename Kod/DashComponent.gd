extends Node

@export var dash_force = 300.0 # To wystarczy, żeby poczuć boost, ale nie stracić kontroli
@export var cooldown_powietrze = 0.8
@export var cooldown_ziemia = 0.3

var is_dashing = false
var can_dash = true

func start_dash(player: CharacterBody2D):
	if not can_dash: return
	
	is_dashing = true
	can_dash = false
	
	# --- LOGIKA DODAWANIA PRĘDKOŚCI ---
	# Sprawdzamy, w którą stronę patrzy gracz (na podstawie skali lub flip_h)
	# Jeśli masz postać obróconą w prawo, kierunek to 1, w lewo -1
	var direction = 1
	if player.has_node("Sprite2D"):
		direction = -1 if player.get_node("Sprite2D").flip_h else 1
	elif player.scale.x < 0:
		direction = -1

	# DODAJEMY siłę do obecnej prędkości (nie ustawiamy jej na sztywno)
	player.velocity.x += direction * dash_force
	
	# Opcjonalnie: mały boost w górę, jeśli dashujesz w powietrzu
	if not player.is_on_floor():
		player.velocity.y -= 100 
	# ----------------------------------

	player.modulate = Color(2, 2, 2) # Błysk
	
	# Czas trwania efektu wizualnego pędu
	await get_tree().create_timer(0.2).timeout
	
	is_dashing = false
	player.modulate = Color.WHITE
	
	# Cooldown zależny od podłoża
	var aktualny_cooldown = cooldown_ziemia if player.is_on_floor() else cooldown_powietrze
	
	await get_tree().create_timer(aktualny_cooldown).timeout
	can_dash = true
