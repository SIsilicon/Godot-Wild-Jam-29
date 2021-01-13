extends Spatial



enum AudioType { SFX, MUSIC }
enum Buses { MASTER, SFX, MUSIC }

const PATH : String = "res://audio/"
const MIN_DB : int = -40

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
			sfx_bus.append(audio)
		
		AudioType.MUSIC:
			if not tag in tags.keys() && tag != "":
				tags[tag] = audio
			music_bus.append(audio)
	
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
			sfx_bus.append(audio)
		
		AudioType.MUSIC:
			if not tag in tags.keys() && tag != "":
				tags[tag] = audio
			music_bus.append(audio)
	
	add_child(audio)
	audio.play()
	
	return audio



func get_audio(tag : String) -> Node:
	return tags[tag]



func set_volume(bus : int, percentage : float) -> void:
	var decibals : float = percentage * abs(MIN_DB)
	decibals -= MIN_DB
	
	set_volume_db(bus, decibals)



func set_volume_db(bus : int, decibals : float) -> void:
	match bus:
		Buses.MASTER:
			set_volume_db(Buses.SFX, decibals)
			set_volume_db(Buses.MUSIC, decibals)
		
		Buses.SFX:
			for audio in sfx_bus:
				audio.volume_db = decibals
		
		Buses.MUSIC:
			for audio in music_bus:
				audio.volume_db = decibals



# Private methods

func __test__() -> void:
	play_audio("ground_layer", AudioType.MUSIC, "ground layer WOOH!")
	play_audio("goose_layer", AudioType.MUSIC)
	play_audio("ship_layer", AudioType.MUSIC)
	play_audio("ship_melody_layer", AudioType.MUSIC)
	print(tags)
	while true:
		play_audio("grass_footstep", AudioType.SFX)
		yield(get_tree().create_timer(1), "timeout")
