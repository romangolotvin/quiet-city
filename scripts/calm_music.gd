extends AudioStreamPlayer

const MIX := 22050.0
const STEP := 0.95

var _playback: AudioStreamGeneratorPlayback
var _time := 0.0
var _enabled := true

var _melody: Array[float] = [
	440.0, 523.25, 659.25, 587.33,
	523.25, 440.0, 392.0, 329.63,
	392.0, 440.0, 523.25, 493.88,
]


func _ready() -> void:
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = MIX
	gen.buffer_length = 0.5
	stream = gen
	volume_db = -9.0
	play()
	_playback = get_stream_playback()
	if AppSettings:
		set_music_enabled(AppSettings.music_enabled)


func set_music_enabled(enabled: bool) -> void:
	_enabled = enabled
	stream_paused = not enabled
	volume_db = -9.0 if enabled else -80.0


func _process(_delta: float) -> void:
	if _playback == null or not _enabled:
		return
	var frames := _playback.get_frames_available()
	for _i in frames:
		_time += 1.0 / MIX
		var breath := 0.75 + 0.25 * sin(_time * 0.35)
		var pad := sin(TAU * 220.0 * _time) * 0.045
		pad += sin(TAU * 329.63 * _time) * 0.035
		pad += sin(TAU * 261.63 * _time) * 0.03
		var local := fmod(_time, STEP) / STEP
		var env := sin(local * PI)
		var note_i := int(_time / STEP) % _melody.size()
		var tone := sin(TAU * _melody[note_i] * _time) * 0.055 * env
		var sample := clampf((pad * breath + tone) * 0.9, -1.0, 1.0)
		_playback.push_frame(Vector2(sample, sample))
