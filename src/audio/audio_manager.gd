extends Spatial



enum AudioType { SFX, MUSIC }
enum Buses { MASTER, SFX, MUSIC }

export var fade_time : float

const PATH : String = "res://audio/"
const MIN_DB : int = -20
const MAX_DB : int = 0
const SILENCED_DB : int = -69420

onready var tween : Tween = $Tween

var sfx_volume : float = 0.0
var music_volume : float = 0.0
var master_volume : float = 0.0

var silenced : Array = []

var sfx_bus : Array = []
var music_bus : Array = []
var tags : Dictionary = {}
var audio_paths : Dictionary = {
	"jump_sound" : [ "mpc_jump_sound.ogg" ],
	"goose_honk" : [ "goose_honk_1.ogg" ],
	"goose_spawn": ["goose_spawn2.ogg"],
	"goose_wing_flap" : [ "goose_wing_flap_1.ogg", "goose_wing_flap_2.ogg", "goose_wing_flap_3.ogg", "goose_wing_flap_4.ogg" ],
	"grass_footstep" : [ "mpc_grass_footstep_1.ogg", "mpc_grass_footstep_2.ogg", "mpc_grass_footstep_3.ogg", "mpc_grass_footstep_4.ogg" ],
	"ship_footstep" : [ "mpc_ship_footstep_1.ogg", "mpc_ship_footstep_2.ogg", "mpc_ship_footstep_3.ogg", "mpc_ship_footstep_4.ogg" ],
	"grass_landing" : [ "mpc_grass_landing_sound_1.ogg" ],
	"ship_landing" : [ "mpc_ship_landing_sound.ogg" ],
	"ground_layer" : [ "music_groundwalking_layer1_v3.ogg" ],
	"goose_layer" : [ "music_gooseflight_layer2_v3.ogg" ],
	"ship_layer" : [ "music_onship_layer3_v3.ogg" ],
	"ship_melody_layer" : [ "music_onship_melody_layer4_v3.ogg" ]
}



# Public methods

func play_audio(audio_name : String, audio_type : int, tag : String = "") -> AudioStreamPlayer:
	var audio_packed : PackedScene = load("res://scenes/audio/AudioPiece.tscn")
	var audio : AudioStreamPlayer = audio_packed.instance()
	
	var tracks : Array = audio_paths[audio_name]
	var track : String = tracks[rand_range(0, len(tracks))]
	
	audio.stream = load(PATH + track)
	
	match audio_type:
		AudioType.SFX:
			audio.stream.loop = false
			audio.connect("ended", self, "sfx_ended")
			sfx_bus.append(audio)
		
		AudioType.MUSIC:
			music_bus.append(audio)
	
	
	if not tag in tags.keys() && tag != "":
		tags[tag] = audio
		audio.tag = tag
	
	add_child(audio)
	audio.play()
	
	update_volumes()
	
	return audio



func play_3d_audio(audio_name : String, _audio_position : Vector3, audio_type : int, tag : String = "") -> AudioStreamPlayer:
	return play_audio(audio_name, audio_type, tag)
#	var audio_packed : PackedScene = load("res://scenes/audio/AudioPiece3D.tscn")
#	var audio : AudioStreamPlayer3D = audio_packed.instance()
#
#	var tracks : Array = audio_paths[audio_name]
#	var track : String = tracks[rand_range(0, len(tracks))]
#
#	audio.stream = load(PATH + track)
#	audio.translation = audio_position
#
#	match audio_type:
#		AudioType.SFX:
#			audio.stream.loop = false
#			audio.connect("ended", self, "sfx_3d_ended")
#			sfx_bus.append(audio)
#
#		AudioType.MUSIC:
#			music_bus.append(audio)
#
#
#	if not tag in tags.keys() && tag != "":
#		tags[tag] = audio
#		audio.tag = tag
#
#	add_child(audio)
#	audio.play()
#
#	update_volumes()
#
#	return audio



func get_audio(tag : String) -> Node:
	return tags[tag]



func end_audio(tag : String) -> void:
	get_audio(tag).end()



func fade_in_audio(tag : String) -> void:
	unsilence(tag)
	tween.interpolate_property(get_audio(tag), "volume_db", MIN_DB, MAX_DB, fade_time)
	tween.start()



func fade_out_audio(tag : String) -> void:
	unsilence(tag)
	tween.interpolate_property(get_audio(tag), "volume_db", get_audio(tag).volume_db, MIN_DB, fade_time)
	tween.start()



func unsilence(tag : String) -> void:
	silenced.erase(get_audio(tag))
	update_volumes()



func silence(tag : String) -> void:
	get_audio(tag).volume_db = MIN_DB
	silenced.append(get_audio(tag))
	update_volumes()



func set_volume(bus : int, percentage : float) -> void:
	var decibals : float = percentage * abs(MIN_DB)
	decibals += MIN_DB
	
	set_volume_db(bus, decibals)



func set_volume_db(bus : int, decibals : float) -> void:
	match bus:
		Buses.MASTER: master_volume = decibals
		Buses.MUSIC: music_volume = decibals
		Buses.SFX: sfx_volume = decibals
	
	update_volumes()



func update_volumes() -> void:
	for audio in sfx_bus:
		if not audio in silenced:
			if audio is AudioStreamPlayer:
				audio.volume_db = master_volume + sfx_volume
			elif audio is AudioStreamPlayer3D:
				audio.unit_db = master_volume + sfx_volume
		
		if audio is AudioStreamPlayer:
			if audio.volume_db <= MIN_DB:
				audio.volume_db = SILENCED_DB
		elif audio is AudioStreamPlayer3D:
			if audio.unit_db <= MIN_DB:
				audio.unit_db = SILENCED_DB
	
	for audio in music_bus:
		if not audio in silenced:
			if audio is AudioStreamPlayer:
				audio.volume_db = master_volume + music_volume
			elif audio is AudioStreamPlayer3D:
				audio.unit_db = master_volume + music_volume
		
		if audio is AudioStreamPlayer:
			if audio.volume_db <= MIN_DB:
				audio.volume_db = SILENCED_DB
		elif audio is AudioStreamPlayer3D:
			if audio.unit_db <= MIN_DB:
				audio.unit_db = SILENCED_DB



# Private methods
func _ready() -> void:
	set_volume(Buses.MUSIC, Global.get_setting("music_volume"))
	set_volume(Buses.SFX, Global.get_setting("sfx_volume"))
	play_audio("ground_layer", AudioType.MUSIC, "ground")
	play_audio("ground_layer", AudioType.MUSIC, "goose")
	play_audio("ground_layer", AudioType.MUSIC, "ship")
	play_audio("ground_layer", AudioType.MUSIC, "ship_melody")
	silence("goose")
	silence("ship")
	silence("ship_melody")
	#__test2__()
	#__test__()
	
	
func __test__() -> void:
	update_volumes()
	play_audio("ground_layer", AudioType.MUSIC, "ground")
	play_audio("goose_layer", AudioType.MUSIC, "goose")
	play_audio("ship_layer", AudioType.MUSIC, "ship")
	play_audio("ship_melody_layer", AudioType.MUSIC, "ship_melody")
	
	#fade_out_audio("ground")



func __test2__() -> void:
	var test_packed : PackedScene = load("res://scenes/audio/AudioPiece3D.tscn")
	var test : AudioStreamPlayer3D = test_packed.instance()
	
	test.stream = load("res://audio/mpc_jump_sound.ogg")
	test.global_transform.origin = get_tree().get_nodes_in_group("pushes_pressure_pad")[0].global_transform.origin
	print("happened")
	
	add_child(test)
	test.play()



func _on_Tween_tween_completed(object : Object, _key) -> void:
	silence(object.tag)
	update_volumes()



func sfx_ended(sfx : AudioStreamPlayer) -> void:
	sfx_bus.erase(sfx)



func sfx_3d_ended(sfx : AudioStreamPlayer3D) -> void:
	sfx_bus.erase(sfx)
