class_name UiFit

## Отступы под горизонтальный телефон: вырез, скругления, системные жесты.
static func margins(viewport: Viewport) -> Rect2:
	var size: Vector2 = viewport.get_visible_rect().size
	var left := 16.0
	var top := 12.0
	var right := 16.0
	var bottom := 16.0
	# DisplayServer отдаёт safe area экрана; используем только если она вписывается в окно.
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	var win: Vector2i = DisplayServer.window_get_size()
	if win.x > 0 and win.y > 0 and safe.size.x > 0 and safe.size.y > 0 \
			and safe.size.x <= win.x and safe.size.y <= win.y:
		var scale_x := size.x / float(win.x)
		var scale_y := size.y / float(win.y)
		left = maxf(float(safe.position.x) * scale_x, left)
		top = maxf(float(safe.position.y) * scale_y, top)
		right = maxf(float(win.x - safe.position.x - safe.size.x) * scale_x, right)
		bottom = maxf(float(win.y - safe.position.y - safe.size.y) * scale_y, bottom)
	if size.y <= 480.0:
		top = maxf(top, 10.0)
		bottom = maxf(bottom, 18.0)
		left = maxf(left, 20.0)
		right = maxf(right, 20.0)
	return Rect2(left, top, size.x - left - right, size.y - top - bottom)


static func is_compact(viewport: Viewport) -> bool:
	return viewport.get_visible_rect().size.y <= 520.0


static func touch_grow() -> float:
	return 18.0
