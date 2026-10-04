extends AudioStreamPlayer

## Тихий lounge-piano: мягкие аккорды, тихий бас, почти без «диджейского» блеска.

const MIX := 22050.0
const BPM := 72.0
const BEAT := 60.0 / BPM

var _playback: AudioStreamGeneratorPlayback
var _time := 0.0
var _enabled := true
var _noise := 0.0

# Спокойный оборот Am7 – D7 – Gmaj7 – Cmaj7
var _chords: Array = [
	[110.00, 130.81, 164.81, 196.00], # Am7
	[146.83, 185.00, 220.00, 293.66], # D7
	[98.00, 123.47, 146.83, 196.00], # Gmaj7
	[130.81, 164.81, 196.00, 246.94], # Cmaj7
]

var _bass: Array = [
	110.00, 130.81, 164.81, 146.83,
	146.83, 185.00, 220.00, 164.81,
	98.00, 123.47, 146.83, 130.81,
	130.81, 164.81, 196.00, 123.47,
]

# Редкая фортепианная мелодия (не соло-сакс).
var _melody: Array = [
	0.0, 392.00, 0.0, 349.23,
	329.63, 0.0, 349.23, 392.00,
	440.00, 0.0, 392.00, 349.23,
	329.63, 293.66, 0.0, 261.63,
	0.0, 0.0, 329.63, 349.23,
	392.00, 0.0, 440.00, 0.0,
	392.00, 349.23, 329.63, 0.0,
	293.66, 0.0, 261.63, 0.0,
]


func _ready() -> void:
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = MIX
	gen.buffer_length = 0.5
	stream = gen
	volume_db = -10.0
	play()
	_playback = get_stream_playback()
	if AppSettings:
		set_music_enabled(AppSettings.music_enabled)


func set_music_enabled(enabled: bool) -> void:
	_enabled = enabled
	stream_paused = not enabled
	volume_db = -10.0 if enabled else -80.0


func _process(_delta: float) -> void:
	if _playback == null or not _enabled:
		return
	var frames := _playback.get_frames_available()
	for _i in frames:
		_time += 1.0 / MIX
		var sample := _lounge_sample(_time)
		_playback.push_frame(Vector2(sample, sample))


func _lounge_sample(t: float) -> float:
	var beat_pos := t / BEAT
	var bar := int(beat_pos / 4.0) % _chords.size()
	var beat_in_bar := fmod(beat_pos, 4.0)
	var beat_local := fmod(beat_pos, 1.0)

	var chord: Array = _chords[bar]
	var chord_env := exp(-beat_local * 1.8) * (0.55 + 0.45 * (1.0 if int(beat_in_bar) % 2 == 0 else 0.75))
	var chord_tone := 0.0
	for freq in chord:
		chord_tone += _piano(float(freq), t) * 0.022
	chord_tone *= chord_env

	var bass_i := (int(beat_pos) % _bass.size() + _bass.size()) % _bass.size()
	var bass_env := exp(-beat_local * 2.4)
	var bass := _piano(float(_bass[bass_i]) * 0.5, t) * 0.055 * bass_env
	bass += _piano(float(_bass[bass_i]), t) * 0.028 * bass_env

	var mel_i := int(beat_pos) % _melody.size()
	var mel_f := float(_melody[mel_i])
	var melody := 0.0
	if mel_f > 1.0:
		var mel_env := exp(-beat_local * 2.0)
		melody = _piano(mel_f, t) * 0.03 * mel_env

	# Тихие щётки только на 2 и 4.
	var brush := 0.0
	if int(beat_in_bar) == 1 or int(beat_in_bar) == 3:
		_noise = _noise * 0.96 + (randf() * 2.0 - 1.0) * 0.04
		brush = _noise * 0.012 * exp(-beat_local * 5.0)

	var breath := 0.88 + 0.12 * sin(t * 0.15)
	return clampf((bass + chord_tone + melody + brush) * breath, -1.0, 1.0)


func _piano(freq: float, t: float) -> float:
	# Мягкий рояль: основная + слабые гармоники, без «медного» блеска.
	var det := 1.0 + 0.0015 * sin(t * 0.7)
	var f := freq * det
	var s := sin(TAU * f * t)
	s += 0.22 * sin(TAU * f * 2.0 * t)
	s += 0.08 * sin(TAU * f * 3.0 * t)
	s += 0.03 * sin(TAU * f * 4.0 * t)
	return s * 0.75
