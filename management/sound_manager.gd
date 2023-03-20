extends Node


const DEFAULT_PITCH = 1.0
const MIN_VOLUME_DB = -80.0
const FADE_IN_SECONDS = 0.5
const FADE_OUT_SECONDS = 5.0
const DEFAULT_LANGUAGE = "en"

var current_music_id: Global.MUSIC = Global.MUSIC.NONE
var current_ambience_id: Global.AMBIENCES = Global.AMBIENCES.NONE
var music_queue: Array
var music_queue_index = 0

var _music_paths: Dictionary
var _ambience_paths: Dictionary
var _sfx: Dictionary
var _letters: Dictionary

@onready var _sound_player_groups: Dictionary = {
	Global.SOUND_TYPES.MUSIC: $MusicPlayers.get_children(),
	Global.SOUND_TYPES.SFX: $SFXPlayers.get_children(),
	Global.SOUND_TYPES.AMBIENCE: $AmbiencePlayers.get_children()
}


func _ready() -> void:
	_connect_signals()
	_debug_setup()


## You can cause weird things to happen if you call this function several times
## rapidly with different music_id's. So try not to do that.
func play_music(music_id: Global.MUSIC, volume: float = 0.0, fade: bool = true) -> void:
	if current_music_id == music_id:
		return
	
	current_music_id = music_id
	stop_music(fade)
	
	if music_id == Global.MUSIC.NONE:
		return
	
	var music_resource: Resource = load(_music_paths[music_id])
	_play_sound(Global.SOUND_TYPES.MUSIC, music_resource, volume, DEFAULT_PITCH, fade)


func play_ambience(ambience_id: Global.AMBIENCES, volume: float = 0.0, fade: bool = true) -> void:
	if current_ambience_id == ambience_id:
		return
	
	current_ambience_id = ambience_id
	stop_ambience(fade)
	
	if ambience_id == Global.AMBIENCES.NONE:
		return
	
	var ambience_resource: Resource = load(_ambience_paths[ambience_id])
	_play_sound(Global.SOUND_TYPES.AMBIENCE, ambience_resource, volume, DEFAULT_PITCH, fade)
	
	
func play_sfx(sfx_id: int, volume: float = 0.0, pitch: float = 1.0) -> void:
	if _sfx[sfx_id] is Array:
		_play_random_sfx(_sfx[sfx_id], volume, pitch)
		return
	
	_play_sound(Global.SOUND_TYPES.SFX, _sfx[sfx_id], volume, pitch)


func play_letter(letter: String, volume: float = 0.0, pitch: float = 1.0) -> void:
	var letter_resource: Resource = _letters[letter]
	_play_sound(Global.SOUND_TYPES.SFX, letter_resource, volume, pitch)


func stop_music(fade: bool = true) -> void:
	_stop_sounds_type(Global.SOUND_TYPES.MUSIC, fade)


func stop_ambience(fade: bool = true) -> void:
	_stop_sounds_type(Global.SOUND_TYPES.AMBIENCE, fade)


func stop_sfx() -> void:
	_stop_sounds_type(Global.SOUND_TYPES.SFX)


func play_next_in_queue():
	assert(music_queue.size() > 0)
	play_music(music_queue[music_queue_index])
	music_queue_index = (music_queue_index + 1) % music_queue.size()


func can_use_tts() -> bool:
	var voice_array: PackedStringArray = DisplayServer.tts_get_voices_for_language(DEFAULT_LANGUAGE)
	return voice_array.size() <= 0


func play_tts(text: String, volume_db: int = 50, pitch: float = 1.0, speed: float = 1.0) -> void:
	var voice_array: PackedStringArray = DisplayServer.tts_get_voices_for_language(DEFAULT_LANGUAGE)
	DisplayServer.tts_speak(text, voice_array[0], volume_db, pitch, speed)


func _play_sound(sound_type_id: int, sound_resource: Resource, volume: float,
pitch: float, fade: bool = false) -> void:
	var sound_player: AudioStreamPlayer = _get_available_audio_player(sound_type_id)
	
	if sound_player:
		_load_and_play(sound_player, sound_resource, volume, pitch, fade)
		return
	
	_print_overloaded_players_error(sound_type_id)


func _play_random_sfx(sfx_array: Array, volume: float = 0.0,
pitch: float = 1.0) -> void:
	var random_sound: Resource = sfx_array.pick_random()
	_play_sound(Global.SOUND_TYPES.SFX, random_sound, volume, pitch)


func _stop_player(audio_stream_player: AudioStreamPlayer) -> void:
	audio_stream_player.stop()


func _load_and_play(sound_player: AudioStreamPlayer, sound_resource: Resource,
volume: float, pitch: float, fade: bool = false) -> void:
	sound_player.stop()
	if pitch <= 0.0:
		pitch = 0.1
	sound_player.pitch_scale = pitch
	sound_player.stream = sound_resource
	
	if fade:
		sound_player.volume_db = MIN_VOLUME_DB
		var tween = create_tween()
		tween.tween_property(sound_player, "volume_db", volume, FADE_IN_SECONDS)
		sound_player.play()
		return
	
	sound_player.volume_db = volume
	sound_player.play()


func _stop_sounds_type(sound_players_group_id: int, fade: bool = false) -> void:
	var active_audio_players: Array = _get_audio_players_in_use(sound_players_group_id)
	
	for audio_player in active_audio_players:
		if not fade:
			audio_player.stop()
			continue
		
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(audio_player, "volume_db", MIN_VOLUME_DB, FADE_OUT_SECONDS)
		fade_out_tween.tween_callback(_stop_player.bind(audio_player))


func _get_available_audio_player(sound_player_group_id: int) -> AudioStreamPlayer:
	var possible_sound_players: Array = _sound_player_groups[sound_player_group_id]

	for sound_player in possible_sound_players:
		if not sound_player.playing:
			return sound_player
	
	_print_overloaded_players_error(sound_player_group_id)
	return null


func _get_audio_players_in_use(sound_player_group_id: int) -> Array:
	var possible_sound_players: Array = _sound_player_groups[sound_player_group_id]
	var active_sound_players: Array = []
	
	for sound_player in possible_sound_players:
		if sound_player.playing:
			active_sound_players.append(sound_player)
	
	return active_sound_players


func _initialize_sounds() -> void:
	pass


func _add_sfx(sfx_id: Global.SFX, path: String) -> void:
	_sfx[sfx_id] = load(path)


func _add_random_sfx_array(sfx_id: Global.SFX, path_array: Array) -> void:
	var sound_array: Array = []
	
	for path in path_array:
		sound_array.append(load(path))
	
	_sfx[sfx_id] = sound_array


func _add_music(music_id: Global.MUSIC, path: String) -> void:
	_music_paths[music_id] = path


func _add_ambience(ambience_id: Global.AMBIENCES, path: String) -> void:
	_ambience_paths[ambience_id] = path


func _debug_setup() -> void:
	var music_category_name: String = "Music test"
	var ambience_category_name: String = "Ambience test"
	var sfx_category_name: String = "SFX test"
	
	_debug_sounds_setup(music_category_name, Global.SOUND_TYPES.MUSIC)
	_debug_sounds_setup(ambience_category_name, Global.SOUND_TYPES.AMBIENCE)
	_debug_sounds_setup(sfx_category_name, Global.SOUND_TYPES.SFX)


func _debug_sounds_setup(category_name: String, sound_type: Global.SOUND_TYPES) -> void:
	var sound_keys: Array
	match sound_type:
		Global.SOUND_TYPES.MUSIC:
			sound_keys = Global.MUSIC.keys()
		Global.SOUND_TYPES.AMBIENCE:
			sound_keys = Global.AMBIENCES.keys()
		Global.SOUND_TYPES.SFX:
			sound_keys = Global.SFX.keys()
	
	for sound_part in (sound_keys.size() / DebugMenu.DEBUG_LIMIT) + 1:
		var min_index = sound_part * DebugMenu.DEBUG_LIMIT
		var max_index = min((sound_part + 1) * DebugMenu.DEBUG_LIMIT, sound_keys.size())
	
		if min_index >= sound_keys.size():
			break
	
		var numbered_category_name: String = "%s %d" % [category_name, sound_part]
		DebugMenu.add_category(numbered_category_name)
		
		for i in range(min_index, max_index):
			match sound_type:
				Global.SOUND_TYPES.MUSIC:
					DebugMenu.add_option(numbered_category_name, sound_keys[i].to_lower().capitalize(), play_music, [ Global.MUSIC[sound_keys[i]] ])
				Global.SOUND_TYPES.AMBIENCE:
					DebugMenu.add_option(numbered_category_name, sound_keys[i].to_lower().capitalize(), play_ambience, [ Global.AMBIENCES[sound_keys[i]] ])
				Global.SOUND_TYPES.SFX:
					DebugMenu.add_option(numbered_category_name, sound_keys[i].to_lower().capitalize(), play_sfx, [ Global.SFX[sound_keys[i]] ])


func _get_sound_players_group_name(players_group_id: int) -> String:
	var sound_players_group_name: String = Global.SOUND_TYPES.keys()[players_group_id].to_lower()
	return sound_players_group_name


func _connect_signals() -> void:
	SignalManager.music_load_needed.connect(_add_music)
	SignalManager.ambience_load_needed.connect(_add_ambience)
	SignalManager.sfx_load_needed.connect(_add_sfx)


func _print_unknown_sound_id_error(sound_id: int, players_group_id: int) -> void:
	if not OS.is_debug_build():
		return
	
	printerr("ERROR\nattempted to play unknown sound with id: %s in group: %s" % [sound_id, _get_sound_players_group_name(players_group_id)])


func _print_overloaded_players_error(players_group_id: int) -> void:
	if not OS.is_debug_build():
		return
	
	printerr("ERROR\n%s players overloaded" % _get_sound_players_group_name(players_group_id))
