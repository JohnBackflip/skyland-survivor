extends Resource
class_name SidearmData

enum AttackType {DIRECT, ARTILLERY}

@export var art: Texture2D
@export var projectile_data: Resource
@export var attack_type: AttackType
@export var damage: float
@export var cooldown: float

@export_category("Extra Properties")
@export var projectile_speed: float
@export var effect_radius: float
