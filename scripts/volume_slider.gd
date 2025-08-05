extends HSlider

enum Bus{
	MASTER,
	BGM,
	SFX
}

@export var bus: Bus = Bus.MASTER
@export var test_bgm: AudioStream

@onready var bus_name: StringName = "Master"
@onready var bus_index := AudioServer.get_bus_index(bus_name)

func _ready() -> void:
	bus_name = get_bus_name(bus)
	bus_index = AudioServer.get_bus_index(bus_name)
	
	value = SoundManager.get_volume(bus_index)
	value_changed.connect(func (v: float):
		SoundManager.set_volume(bus_index, v)
		Game.save_settings_data()
	)

	#SoundManager.play_bgm(test_bgm)


func get_bus_name(bus_to_switch: Bus) -> StringName:
	if bus_to_switch == Bus.MASTER:
		return "Master"
	elif bus_to_switch == Bus.BGM:
		return "BGM"
	else:
		return "SFX"
