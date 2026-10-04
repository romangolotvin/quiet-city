extends AudioStreamPlayer

## Тихий lounge-jazz: свинг, walking bass, мягкие септаккорды и соло.

const MIX := 22050.0
const BPM := 96.0
const BEAT := 60.0 / BPM

var _playback: AudioStreamGeneratorPlayback
var _time := 0.0
var _enabled := true

# ii–V–I–VI в C: Dm7, G7, Cmaj7, A7
var _chords: Array = [
	[146.83, 174.61, 220.00, 261.63], # Dm7
	[98.00, 123.47, 146.83, 174.61], # G7
	[130.81, 164.81, 196.00, 246.94], # Cmaj7
	[110.00, 138.59, 164.81, 196.00], # A7
]

var _bass: Array = [
	146.83, 174.61, 220.00, 261.63, # Dm walking
	98.00, 123.47, 146.83, 185.00, # G walking
	130.81, 164.81, 196.00, 246.94, # C walking
	110.00, 138.59, 164.81, 123.47, # A walking
]

var _horn: Array = [
	440.00, 523.25, 493.88, 440.00,
	392.00, 349.23, 392.00, 440.00,
	523.25, 587.33, 523.25, 493.88,
	440.00, 415.30, 440.00, 349.23,
	392.00, 440.00, 493.88, 523.25,
	587.33, 523.25, 466.16, 440.00,
	392.00, 349.23, 329.63, 349.23,
	392.00, 440.00, 415.30, 392.00,
]


func _ready() -> void:
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = MIX
	gen.buffer_length = 0.5
	stream = gen
	volume_db = -8.0
	play()
	_playback = get_stream_playback()
	if AppSettings:
		set_music_enabled(AppSettings.music_enabled)


func set_music_enabled(enabled: bool) -> void:
	_enabled = enabled
	stream_paused = not enabled
	volume_db = -8.0 if enabled else -80.0


func _process(_delta: float) -> void:
	if _playback == null or not _enabled:
		return
	var frames := _playback.get_frames_available()
	for _i in frames:
		_time += 1.0 / MIX
		var sample := _jazz_sample(_time)
		_playback.push_frame(Vector2(sample, sample))


func _jazz_sample(t: float) -> float:
	var beat_pos := t / BEAT
	var bar := int(beat_pos / 4.0) % _chords.size()
	var beat_in_bar := fmod(beat_pos, 4.0)
	var eighth := fmod(beat_pos * 2.0, 1.0)

	# Swing: длинная первая восьмая, короткая вторая.
	var swing_env := 1.0
	if eighth < 0.66:
		swing_env = sin((eighth / 0.66) * PI)
	else:
		swing_env = sin(((eighth - 0.66) / 0.34) * PI) * 0.85

	var chord: Array = _chords[bar]
	var chord_tone := 0.0
	for freq in chord:
		chord_tone += _soft_tone(float(freq), t) * 0.018
	# Лёгкий акцент на 2 и 4.
	var comp := 1.0
	if int(beat_in_bar) == 1 or int(beat_in_bar) == 3:
		comp = 1.25
	chord_tone *= comp * (0.55 + 0.45 * swing_env)

	var bass_i := (int(beat_pos) % _bass.size() + _bass.size()) % _bass.size()
	var bass_local := fmod(beat_pos, 1.0)
	var bass_env := exp(-bass_local * 3.2)
	var bass := _soft_tone(float(_bass[bass_i]), t) * 0.07 * bass_env
	bass += _soft_tone(float(_bass[bass_i]) * 0.5, t) * 0.03 * bass_env

	var horn_step := int(beat_pos * 2.0) % _horn.size()
	var horn_local := fmod(beat_pos * 2.0, 1.0)
	# Свинговая длительность ноты.
	var horn_len := 0.62 if fmod(float(horn_step), 2.0) < 0.5 else 0.38
	var horn_env := 0.0
	if horn_local < horn_len:
		horn_env = sin((horn_local / horn_len) * PI)
	var horn := _brassy(_horn[horn_step], t) * 0.045 * horn_env

	# Мягкая тарелка / щётки на каждой восьмой.
	var brush := (randf() * 2.0 - 1.0) * 0.008 * swing_env
	brush *= exp(-eighth * 4.0)

	var room := 0.72 + 0.28 * sin(t * 0.22)
	var mix := (bass + chord_tone + horn + brush) * room
	return clampf(mix, -1.0, 1.0)


func _soft_tone(freq: float, t: float) -> float:
	# Мягкий «рояль/контрабас»: синус + чуть второй гармоники.
	return sin(TAU * freq * t) * 0.85 + sin(TAU * freq * 2.0 * t) * 0.15


func _brassy(freq: float, t: float) -> float:
	# Тёплый саксофонный тембр: нечётные гармоники и лёгкое вибрато.
	var vib := freq * (1.0 + 0.004 * sin(TAU * 5.2 * t))
	var s := sin(TAU * vib * t)
	s += 0.35 * sin(TAU * vib * 2.0 * t)
	s += 0.18 * sin(TAU * vib * 3.0 * t)
	s += 0.08 * sin(TAU * vib * 5.0 * t)
	return s * 0.7
