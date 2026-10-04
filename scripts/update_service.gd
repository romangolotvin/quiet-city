extends Node

signal status(text: String)
signal update_available(info: Dictionary)
signal up_to_date
signal update_failed(text: String)
signal download_progress(loaded: int, total: int)
signal update_ready

var latest: Dictionary = {}
var busy := false

var _http: HTTPRequest
var _mode := ""
var _download_path := ""


func _ready() -> void:
	_http = HTTPRequest.new()
	_http.timeout = 25.0
	_http.use_threads = true
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)


func current_version() -> String:
	return UpdateConfig.APP_VERSION


func platform_key() -> String:
	if OS.get_name() == "Android":
		return "android"
	return "windows"


func check_for_updates(silent := false) -> void:
	if busy:
		return
	busy = true
	_mode = "manifest"
	_http.timeout = 25.0
	_http.download_file = ""
	if not silent:
		status.emit("Проверяю обновления…")
	var url := _manifest_url()
	if url.is_empty():
		busy = false
		update_failed.emit("Не задан адрес обновлений.")
		return
	var err := _http.request(url)
	if err != OK:
		busy = false
		update_failed.emit("Не удалось начать проверку.")


func start_update() -> void:
	if busy:
		return
	if latest.is_empty():
		check_for_updates(false)
		return
	var key := platform_key()
	if not latest.has(key) or str(latest[key]).is_empty():
		update_failed.emit("Нет ссылки на сборку для этой платформы.")
		return
	var url := str(latest[key])
	if OS.has_feature("editor"):
		update_failed.emit("Обновление ставится только из собранной игры, не из редактора.")
		return

	busy = true
	_mode = "download"
	DirAccess.make_dir_recursive_absolute("user://updates")
	if OS.get_name() == "Android":
		_download_path = "user://updates/QuietCity.apk"
	else:
		_download_path = "user://updates/QuietCity-update.zip"
	_http.download_file = ProjectSettings.globalize_path(_download_path)
	_http.timeout = 0.0 # без лимита — APK/zip большие
	status.emit("Скачиваю обновление…")
	var err := _http.request(url)
	if err != OK:
		busy = false
		_http.download_file = ""
		_http.timeout = 25.0
		update_failed.emit("Не удалось начать загрузку.")


func is_newer(remote: String, local: String) -> bool:
	var a := _parse_version(remote)
	var b := _parse_version(local)
	for i in 3:
		if a[i] > b[i]:
			return true
		if a[i] < b[i]:
			return false
	return false


func _manifest_error_text(result: int, response_code: int) -> String:
	if response_code == 404:
		return "Файл обновлений ещё не выложен в интернет (404)."
	if response_code == 403:
		return "Доступ к серверу обновлений запрещён (403)."
	match result:
		HTTPRequest.RESULT_CANT_RESOLVE:
			return "Не удалось найти сервер обновлений (DNS)."
		HTTPRequest.RESULT_CANT_CONNECT:
			return "Нет доступа в интернет у приложения. Переустанови APK."
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "Ошибка защищённого соединения (TLS)."
		HTTPRequest.RESULT_TIMEOUT:
			return "Сервер обновлений не ответил вовремя."
		HTTPRequest.RESULT_SUCCESS:
			pass
		_:
			return "Нет интернета или сервер недоступен (%s)." % result
	return "Сервер обновлений ответил ошибкой (%s)." % response_code


func _manifest_url() -> String:
	var cfg := ConfigFile.new()
	if cfg.load("user://update_override.cfg") == OK:
		var custom := str(cfg.get_value("update", "manifest_url", ""))
		if not custom.is_empty():
			return custom
	return UpdateConfig.MANIFEST_URL


func _parse_version(text: String) -> Array[int]:
	var parts := text.strip_edges().split(".")
	var out: Array[int] = [0, 0, 0]
	for i in mini(parts.size(), 3):
		out[i] = int(parts[i])
	return out


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_http.download_file = ""
	_http.timeout = 25.0
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		busy = false
		if _mode == "download":
			update_failed.emit("Ошибка загрузки обновления.")
		else:
			update_failed.emit(_manifest_error_text(result, response_code))
		_mode = ""
		return

	if _mode == "manifest":
		_handle_manifest(body)
	elif _mode == "download":
		_handle_download_done()
	_mode = ""


func _handle_manifest(body: PackedByteArray) -> void:
	busy = false
	var text := body.get_string_from_utf8()
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY or not data.has("version"):
		update_failed.emit("Неверный файл обновлений.")
		return
	latest = data
	var remote := str(data["version"])
	if is_newer(remote, current_version()):
		status.emit("Доступна версия %s" % remote)
		update_available.emit(data)
	else:
		status.emit("У тебя последняя версия (%s)." % current_version())
		up_to_date.emit()


func _handle_download_done() -> void:
	busy = false
	status.emit("Готовлю установку…")
	if OS.get_name() == "Android":
		if not _install_android_apk():
			update_failed.emit("Не удалось открыть установку. Разреши установку из этого приложения в настройках Android и нажми обновление снова.")
			return
		update_ready.emit()
		status.emit("Подтверди установку в окне Android.")
		return
	if not _apply_windows_update():
		update_failed.emit("Не удалось подготовить установку обновления.")
		return
	update_ready.emit()
	status.emit("Игра перезапустится для обновления.")
	get_tree().create_timer(0.35).timeout.connect(func() -> void:
		get_tree().quit()
	)


func _install_android_apk() -> bool:
	if not FileAccess.file_exists(_download_path):
		return false
	var absolute := ProjectSettings.globalize_path(_download_path)
	var android_runtime = Engine.get_singleton("AndroidRuntime")
	if android_runtime == null:
		# Запасной путь: открыть локальный файл (на новых Android может не сработать).
		OS.shell_open(absolute)
		return true

	var activity = android_runtime.getActivity()
	if activity == null:
		return false

	var Intent = JavaClassWrapper.wrap("android.content.Intent")
	var Uri = JavaClassWrapper.wrap("android.net.Uri")
	var File = JavaClassWrapper.wrap("java.io.File")
	var FileProvider = JavaClassWrapper.wrap("androidx.core.content.FileProvider")
	var Settings = JavaClassWrapper.wrap("android.provider.Settings")
	var BuildVersion = JavaClassWrapper.wrap("android.os.Build$VERSION")

	# Android 8+: нужно разрешение «Установка неизвестных приложений».
	if int(BuildVersion.SDK_INT) >= 26:
		var pm = activity.getPackageManager()
		if pm != null and not bool(pm.canRequestPackageInstalls()):
			var settings_intent = Intent.Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
			settings_intent.setData(Uri.parse("package:%s" % activity.getPackageName()))
			activity.startActivity(settings_intent)
			status.emit("Разреши установку из «Тихий город», затем снова нажми «Обновить».")
			return true

	var file = File.File(absolute)
	if not bool(file.exists()):
		return false

	var authority := "%s.fileprovider" % activity.getPackageName()
	var uri = FileProvider.getUriForFile(activity, authority, file)
	var intent = Intent.Intent(Intent.ACTION_VIEW)
	intent.setDataAndType(uri, "application/vnd.android.package-archive")
	intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
	intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

	var install := func() -> void:
		activity.startActivity(intent)

	activity.runOnUiThread(android_runtime.createRunnableFromGodotCallable(install))
	return true


func _apply_windows_update() -> bool:
	var zip_path := ProjectSettings.globalize_path(_download_path)
	if not FileAccess.file_exists(_download_path):
		return false
	var exe_path := OS.get_executable_path()
	var exe_dir := exe_path.get_base_dir()
	var stage := exe_dir.path_join("_update_stage")
	var bat_path := exe_dir.path_join("_apply_update.bat")
	var exe_name := exe_path.get_file()

	var bat := PackedStringArray()
	bat.append("@echo off")
	bat.append("setlocal")
	bat.append("cd /d \"%~dp0\"")
	bat.append("timeout /t 2 /nobreak >nul")
	bat.append("if exist \"%s\" rmdir /s /q \"%s\"" % [stage, stage])
	bat.append("mkdir \"%s\"" % stage)
	bat.append("powershell -NoProfile -Command \"Expand-Archive -LiteralPath '%s' -DestinationPath '%s' -Force\"" % [zip_path.replace("'", "''"), stage.replace("'", "''")])
	bat.append("if errorlevel 1 goto fail")
	bat.append("xcopy /e /y /q \"%s\\*\" \".\\\" >nul" % stage)
	bat.append("if exist \"%s\" rmdir /s /q \"%s\"" % [stage, stage])
	bat.append("start \"\" \"%s\"" % exe_name)
	bat.append("del \"%~f0\"")
	bat.append("exit /b 0")
	bat.append(":fail")
	bat.append("echo Update failed > \"_update_error.txt\"")
	bat.append("start \"\" \"%s\"" % exe_name)
	bat.append("del \"%~f0\"")
	bat.append("exit /b 1")

	var f := FileAccess.open(bat_path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string("\r\n".join(bat))
	f.close()

	var pid := OS.create_process("cmd.exe", ["/C", bat_path])
	return pid > 0


func _process(_delta: float) -> void:
	if _mode != "download" or not busy:
		return
	var body_size := _http.get_body_size()
	var downloaded := _http.get_downloaded_bytes()
	if body_size > 0:
		download_progress.emit(downloaded, body_size)
