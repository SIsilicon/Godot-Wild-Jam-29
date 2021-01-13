extends Spatial



enum AudioType { SFX, MUSIC }
enum Buses { MASTER, SFX, MUSIC }

const PATH : String = "res://audio/"
const MIN_DB : int = -40

var sfx_bus : Array = []
var music_bus : Array = []
var tags : Dictionary = {}
var audio_paths : Dictionary = {
	"jump_sound" : [ "JumpSound.ogg" ],
	"goose_honk" : [ "GooseHonk1.ogg" ],
	"goose_wing_flap" : [ "GooseWingFlap1.ogg", "GooseWingFlap2.ogg", "GooseWingFlap3.ogg", "GooseWingFlap4.ogg" ],
	"grass_footstep" : [ "GrassFootstep1.ogg", "GrassFootstep2.ogg", "GrassFootstep3.ogg", "GrassFootstep4.ogg" ],
	"ship_footstep" : [ "ShipFootstep1.ogg", "ShipFootstep2.ogg", "ShipFootstep3.ogg", "ShipFootstep4.ogg" ],
	"grass_landing" : [ "GrassLandingSound1.ogg" ],
	"ship_landing" : [ "ShipLandingSound1.ogg" ],
	"ground_layer" : [ "GroundLayer1V1.ogg" ],
	"goose_layer" : [ "GooseLayer2V1.ogg" ],
	"ship_layer" : [ "ShipLayer3V1.ogg" ],
	"ship_melody_layer" : [ "ShipMelodyLayer4V1.ogg" ]
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



func get_audio(tag : String) -> AudioStreamPlayer:
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
