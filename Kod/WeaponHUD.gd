extends Control

@onready var icon_left = $CanvasLayer/Control/HBoxContainer/TextureRect
@onready var icon_center = $CanvasLayer/Control/HBoxContainer/TextureRect2
@onready var icon_right = $CanvasLayer/Control/HBoxContainer/TextureRect3
@onready var container = $CanvasLayer/Control/HBoxContainer

func _ready():
	_wyczysc_hud()

func _wyczysc_hud():
	icon_left.texture = null
	icon_center.texture = null
	icon_right.texture = null
	icon_left.visible = false
	icon_center.visible = false
	icon_right.visible = false

func aktualizuj_hud(ekwipunek: Array, aktualny_index: int):
	if ekwipunek.size() == 0:
		_wyczysc_hud()
		return

	# 1. ŚRODKOWA BROŃ (Aktualna)
	var bron = ekwipunek[aktualny_index]
	if bron and bron.tekstura:
		icon_center.texture = bron.tekstura
		icon_center.custom_minimum_size = Vector2(100, 100)
		icon_center.modulate.a = 1.0
		icon_center.visible = true
	
	# 2. LEWA BROŃ (Poprzednia)
	var left_index = aktualny_index - 1
	if left_index >= 0:
		var bron_l = ekwipunek[left_index]
		if bron_l and bron_l.get("tekstura"):
			icon_left.texture = bron_l.tekstura
			icon_left.custom_minimum_size = Vector2(60, 60)
			icon_left.modulate.a = 0.5
			icon_left.visible = true
		else:
			icon_left.visible = false
	else:
		icon_left.visible = false

	# 3. PRAWA BROŃ (Następna)
	var right_index = aktualny_index + 1
	if right_index < ekwipunek.size():
		var bron_r = ekwipunek[right_index]
		if bron_r and bron_r.get("tekstura"):
			icon_right.texture = bron_r.tekstura
			icon_right.custom_minimum_size = Vector2(60, 60)
			icon_right.modulate.a = 0.5
			icon_right.visible = true
		else:
			icon_right.visible = false
	else:
		icon_right.visible = false

	# WYMUSZENIE ODŚWIEŻENIA UKŁADU
	# To sprawi, że HBoxContainer "zauważy" nowe ikony i je poukłada
	if container:
		container.queue_sort()
