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
	"goose_wing_flap" : [ "goose_wing_flap_1.ogg", "goose_wing_flap_2.ogg", "goose_wing_flap_3.ogg", "goose_wing_flap_4.ogg" ],
	"grass_footstep" : [ "mpc_grass_footstep_1.ogg", "mpc_grass_footstep_2.ogg", "mpc_grass_footstep_3.ogg", "mpc_grass_footstep_4.ogg" ],
	"ship_footstep" : [ "mpc_ship_footstep_1.ogg", "mpc_ship_footstep_2.ogg", "mpc_ship_footstep_3.ogg", "mpc_ship_footstep_4.ogg" ],
	"grass_landing" : [ "mpc_grass_landing_sound_1.ogg" ],
	"ship_landing" : [ "mpc_ship_landing_sound.ogg" ],
	"ground_layer" : [ "music_groundwalking_layer1_v1.ogg" ],
	"goose_layer" : [ "music_gooseflight_layer2_v1.ogg" ],
	"ship_layer" : [ "music_onship_layer3_v1.ogg" ],
	"ship_melody_layer" : [ "music_onship_melody_layer4_v1.ogg" ]
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
	
	return audio



func play_3d_audio(audio_name : String, audio_position : Vector3, audio_type : int, tag : String = "") -> AudioStreamPlayer3D:
	var audio_packed : PackedScene = load("res://scenes/audio/AudioPiece3D.tscn")
	var audio : AudioStreamPlayer3D = audio_packed.instance()
	
	var tracks : Array = audio_paths[audio_name]
	var track : String = tracks[rand_range(0, len(tracks))]
	
	audio.stream = load(PATH + track)
	audio.translation = audio_position
	
	match audio_type:
		AudioType.SFX:
			audio.stream.loop = false
			audio.connect("ended", self, "sfx_3d_ended")
			sfx_bus.append(audio)
		
		AudioType.MUSIC:
			music_bus.append(audio)
	
	
	if not tag in tags.keys() && tag != "":
		tags[tag] = audio
		audio.tag = tag
	
	add_child(audio)
	audio.play()
	
	return audio



func get_audio(tag : String) -> Node:
	return tags[tag]



func end_audio(tag : String) -> void:
	get_audio(tag).end()



func fade_in_audio(tag : String) -> void:
	tween.interpolate_property(get_audio(tag), "volume_db", MIN_DB, MAX_DB, fade_time)
	tween.start()



func fade_out_audio(tag : String) -> void:
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
	decibals -= MIN_DB
	
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
			audio.volume_db = master_volume - sfx_volume
		
		if audio.volume_db <= MIN_DB:
			audio.volume_db = SILENCED_DB
	
	for audio in music_bus:
		if not audio in silenced:
			audio.volume_db = master_volume - music_volume
		
		if audio.volume_db <= MIN_DB:
			audio.volume_db = SILENCED_DB



# Private methods
func _ready() -> void: __test__()
func __test__() -> void:
	play_audio("ground_layer", AudioType.MUSIC, "ground")
	play_audio("goose_layer", AudioType.MUSIC, "goose")
	play_audio("ship_layer", AudioType.MUSIC, "ship")
	play_audio("ship_melody_layer", AudioType.MUSIC, "ship_melody")
	
	fade_out_audio("ground")



func _on_Tween_tween_completed(object : Object, _key) -> void:
	silence(object.tag)
	update_volumes()



func sfx_ended(sfx : AudioStreamPlayer) -> void:
	sfx_bus.erase(sfx)



func sfx_3d_ended(sfx : AudioStreamPlayer3D) -> void:
	sfx_bus.erase(sfx)
