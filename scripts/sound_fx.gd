extends Node

## Короткие procedural SFX по kind волны.

var _player: AudioStreamPlayer
var _gen: AudioStreamGenerator
var _playback: AudioStreamGeneratorPlayback
var _busy := false


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	_player.volume_db = -6.0
	add_child(_player)
	_gen = AudioStreamGenerator.new()
	_gen.mix_rate = 22050.0
	_gen.buffer_length = 0.35
	_player.stream = _gen


func play_kind(kind: SoundCatalog.Kind) -> void:
	if _busy:
		return
	_busy = true
	_player.play()
	_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback
	if _playback == null:
		_busy = false
		return
	match kind:
		SoundCatalog.Kind.FIGHT:
			_fill_noise_burst(0.22, 380.0, 0.55)
		SoundCatalog.Kind.CHILDREN:
			_fill_melody([523.0, 659.0, 784.0], 0.08, 0.35)
		SoundCatalog.Kind.DOG:
			_fill_bark()
		SoundCatalog.Kind.TALK:
			_fill_talk()
		_:
			_fill_noise_burst(0.15, 220.0, 0.3)
	get_tree().create_timer(0.4).timeout.connect(func() -> void:
		_busy = false
		if _player.playing:
			_player.stop()
	)


func _push(s: float) -> void:
	if _playback == null:
		return
	_playback.push_frame(Vector2(s, s))


func _fill_noise_burst(sec: float, base_f: float, amp: float) -> void:
	var n := int(sec * _gen.mix_rate)
	for i in n:
		var t := float(i) / _gen.mix_rate
		var env := 1.0 - t / sec
		var s := sin(TAU * base_f * t) * 0.35 + (randf() * 2.0 - 1.0) * 0.45
		_push(s * amp * env)


func _fill_melody(freqs: Array, note_sec: float, amp: float) -> void:
	for f in freqs:
		var n := int(note_sec * _gen.mix_rate)
		for i in n:
			var t := float(i) / _gen.mix_rate
			var env := sin(PI * t / note_sec)
			_push(sin(TAU * float(f) * t) * amp * env * 0.5)


func _fill_bark() -> void:
	var n := int(0.18 * _gen.mix_rate)
	for i in n:
		var t := float(i) / _gen.mix_rate
		var env := exp(-t * 14.0)
		var s := sin(TAU * 180.0 * t) * 0.5 + sin(TAU * 90.0 * t) * 0.35
		s += (randf() * 2.0 - 1.0) * 0.2
		_push(s * env)


func _fill_talk() -> void:
	var n := int(0.28 * _gen.mix_rate)
	for i in n:
		var t := float(i) / _gen.mix_rate
		var f := 160.0 + sin(t * 28.0) * 40.0
		var env := 0.55 + 0.45 * sin(t * 40.0)
		_push(sin(TAU * f * t) * 0.22 * env)
