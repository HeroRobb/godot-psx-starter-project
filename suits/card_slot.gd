class_name CardSlot
extends Resource


@export var _slot_type: Global.SLOT_TYPES
@export_range(1, 5) var max_card_amount: int
@export var cards: Array[Card]

var _accepts_card_types: Array[Global.CARD_TYPES]
var _has_use_card: bool = false


func _init() -> void:
	match _slot_type:
		Global.SLOT_TYPES.BUFF:
			_accepts_card_types.append(Global.CARD_TYPES.PLAYER_MODIFIER)
		Global.SLOT_TYPES.AUTO_USE, Global.SLOT_TYPES.MANUAL_USE:
			_accepts_card_types.append(Global.CARD_TYPES.TOOL)
			_accepts_card_types.append(Global.CARD_TYPES.TOOL_MODIFIER)
		Global.SLOT_TYPES.WILD:
			_accepts_card_types.append(Global.CARD_TYPES.PLAYER_MODIFIER)
			_accepts_card_types.append(Global.CARD_TYPES.TOOL)
			_accepts_card_types.append(Global.CARD_TYPES.TOOL_MODIFIER)


func insert_card(new_card: Card) -> bool:
	if not can_insert_card(new_card):
		return false
	
	cards.append(new_card)
	if new_card.get_type() == Global.CARD_TYPES.TOOL:
		_has_use_card = true
	
	return true


func can_insert_card(new_card: Card) -> bool:
	if cards.size() >= max_card_amount:
		return false
	
	if _has_use_card and new_card.get_type() == Global.CARD_TYPES.TOOL:
		return false
	
	return _accepts_card_types.has(new_card.get_type())
