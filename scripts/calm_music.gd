extends AudioStreamPlayer

## Бодрый lounge: ярче темп, мажорные аккорды, живая мелодия — без мрачности.

const MIX := 22050.0
const BPM := 108.0
const BEAT := 60.0 / BPM

var _playback: AudioStreamGeneratorPlayback
var _time := 0.0
var _enabled := true
var _noise := 0.0

# Весёлый оборот C – G – Am – F (I–V–vi–IV)
var _chords: Array = [
	[130.81, 164.81, 196.00, 261.63], # Cmaj
	[98.00, 123.47, 146.83, 196.00], # G
	[110.00, 130.81, 164.81, 220.00], # Am
	[87.31, 130.81, 174.61, 220.00], # F
]

var _bass: Array = [
	130.81, 130.81, 164.81, 196.00,
	98.00, 98.00, 123.47, 146.83,
	110.00, 110.00, 130.81, 164.81,
	87.31, 87.31, 130.81, 174.61,
]

# Бодрая фортепианная мелодия — больше нот, выше регистр.
var _melody: Array = [
	523.25, 587.33, 659.25, 587.33,
	523.25, 0.0, 392.00, 440.00,
	493.88, 523.25, 587.33, 0.0,
	659.25, 587.33, 523.25, 440.00,
	392.00, 440.00, 493.88, 523.25,
	0.0, 587.33, 659.25, 698.46,
	659.25, 587.33, 523.25, 0.0,
	440.00, 493.88, 523.25, 392.00,
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
		var sample := _lounge_sample(_time)
		_playback.push_frame(Vector2(sample, sample))


func _lounge_sample(t: float) -> float:
	var beat_pos := t / BEAT
	var bar := int(beat_pos / 4.0) % _chords.size()
	var beat_in_bar := fmod(beat_pos, 4.0)
	var beat_local := fmod(beat_pos, 1.0)

	var chord: Array = _chords[bar]
	var chord_env := exp(-beat_local * 2.2) * (0.7 + 0.3 * (1.0 if int(beat_in_bar) % 2 == 0 else 0.85))
	var chord_tone := 0.0
	for freq in chord:
		chord_tone += _piano(float(freq), t) * 0.026
	chord_tone *= chord_env

	var bass_i := (int(beat_pos) % _bass.size() + _bass.size()) % _bass.size()
	var bass_env := exp(-beat_local * 2.8)
	var bass := _piano(float(_bass[bass_i]) * 0.5, t) * 0.06 * bass_env
	bass += _piano(float(_bass[bass_i]), t) * 0.032 * bass_env

	var mel_i := int(beat_pos) % _melody.size()
	var mel_f := float(_melody[mel_i])
	var melody := 0.0
	if mel_f > 1.0:
		var mel_env := exp(-beat_local * 2.4)
		melody = _piano(mel_f, t) * 0.038 * mel_env

	# Лёгкий хай-хэт на каждой доле + щётки на 2 и 4.
	var brush := 0.0
	_noise = _noise * 0.94 + (randf() * 2.0 - 1.0) * 0.06
	if beat_local < 0.12:
		brush = _noise * 0.01 * exp(-beat_local * 14.0)
	if int(beat_in_bar) == 1 or int(beat_in_bar) == 3:
		brush += _noise * 0.016 * exp(-beat_local * 5.0)

	var breath := 0.9 + 0.1 * sin(t * 0.22)
	return clampf((bass + chord_tone + melody + brush) * breath, -1.0, 1.0)


func _piano(freq: float, t: float) -> float:
	var det := 1.0 + 0.0018 * sin(t * 0.9)
	var f := freq * det
	var s := sin(TAU * f * t)
	s += 0.28 * sin(TAU * f * 2.0 * t)
	s += 0.1 * sin(TAU * f * 3.0 * t)
	s += 0.04 * sin(TAU * f * 4.0 * t)
	return s * 0.75
