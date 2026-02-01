extends Resource
class_name WeaponData_Podstawowe

@export var nazwa: String = "Młot"
@export var tekstura: Texture2D
@export var visual_offset: Vector2 = Vector2.ZERO # DODAJ TO: pozwala przesunąć grafikę względem kolizji
@export var obrazenia: int = 1
@export var zasieg: float = 120.0
@export var szybkosc_ataku: float = 0.2
@export var odrzut_gracza: float = 75.0
@export var kat_startowy: float = -110.0
@export var kat_koncowy: float = 40.0
