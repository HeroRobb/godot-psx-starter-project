extends "res://management/sound_manager.gd"


func _initialize_sounds() -> void:
	_add_music(Global.MUSIC.ITS_SAX, "res://sounds/its_sax.ogg")
	_add_music(Global.MUSIC.ALL_BEHIND_THE_CURTAINS, "res://sounds/all_behind_the_curtainsLOOPING.ogg")
	_add_music(Global.MUSIC.CRONCH, "res://sounds/cronch_loopable.ogg")
	_add_music(Global.MUSIC.EVERY_ATOM_IS_COMPOSED_OF_DOUBT, "res://sounds/every_atom_is_composed_of_doubtLOOPING.ogg")
	_add_music(Global.MUSIC.FISHERMAN_AT_DUSK, "res://sounds/fisherman_at_dusk_ambientLOOPING.ogg")
	_add_music(Global.MUSIC.HELL, "res://sounds/hell.ogg")
	_add_music(Global.MUSIC.STRUGGLE_TOWARDS_HOPE, "res://sounds/struggle toward hope.ogg")
	_add_music(Global.MUSIC.WOOD_CARVING, "res://sounds/Wood Carving.ogg")
	_add_ambience(Global.AMBIENCES.FOGHORN, "res://sounds/foghorn_four_times.ogg")
	_add_ambience(Global.AMBIENCES.LOST, "res://sounds/lost_ambienceLOOPING.ogg")
	_add_sfx(Global.SFX.BLIP, "res://sounds/blip2shortest.wav")
	_add_sfx(Global.SFX.UI_CHANGE, "res://sounds/blip2shortest.wav")
	_add_sfx(Global.SFX.UI_CONFIRM, "res://sounds/blip2shortest.wav")
	_add_sfx(Global.SFX.UI_CANCEL, "res://sounds/blip2shortest.wav")
	_add_sfx(Global.SFX.NJB, "res://sounds/njb_intro.ogg")
	_add_sfx(Global.SFX.PAGE_TURN, "res://sounds/page_turn.wav")
	_add_random_sfx_array(Global.SFX.STONE_STEP, ["res://sounds/stepstone_1.wav", "res://sounds/stepstone_2.wav", "res://sounds/stepstone_3.wav", "res://sounds/stepstone_4.wav", "res://sounds/stepstone_5.wav", "res://sounds/stepstone_6.wav", "res://sounds/stepstone_7.wav", "res://sounds/stepstone_8.wav"])
	
