# resources/items/morphine_item.gd
class_name MorphineItem
extends MedicalItem

## Každé použití zkrátí trvání efektu a zvýší drain
@export var base_duration: float = 30.0
@export var duration_decay: float = 0.7   # × za každé použití
@export var health_drain_per_sec: float = 0.5
@export var drain_increase: float = 1.5   # × za každé použití

func _init() -> void:
	category = Category.CONSUMABLE
	max_stack = 3
	weight = 0.1
	heal_amount = 0

func use(player: Node) -> bool:
	if not player.has_method("apply_morphine"):
		return false
	player.apply_morphine(self)
	return true
