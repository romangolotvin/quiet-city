class_name MapLayout

const PLACES := {
	"plaza": {
		"name": "Площадь",
		"pos": Vector2(0, 0),
		"idle": "Фонтан на площади. Отсюда расходятся улицы.",
		"art": "plaza",
	},
	"bakery": {
		"name": "Пекарня",
		"pos": Vector2(512, -256),
		"idle": "Полосатый навес и витрина. Внутри тепло и тихо.",
		"art": "bakery",
	},
	"yard": {
		"name": "Двор",
		"pos": Vector2(512, 256),
		"idle": "Качели и трава. Мяч не лежит на виду.",
		"art": "yard",
	},
	"gate": {
		"name": "Калитка",
		"pos": Vector2(-512, 256),
		"idle": "Деревянная калитка. На гвозде у столба пусто.",
		"art": "gate",
	},
	"porch": {
		"name": "Крыльцо",
		"pos": Vector2(256, -512),
		"idle": "Ступени и дверь. На крыльце никого нет.",
		"art": "porch",
	},
	"house": {
		"name": "Соседний дом",
		"pos": Vector2(256, 512),
		"idle": "Синие ставни закрыты. Из-за стены не слышно слов.",
		"art": "house",
	},
	"park": {
		"name": "Парк",
		"pos": Vector2(-512, -512),
		"idle": "Деревья и дорожки. Скамейки пустые.",
		"art": "park",
	},
	"market": {
		"name": "Рынок",
		"pos": Vector2(-256, -512),
		"idle": "Ряды лотков. Сейчас торговцы молчат.",
		"art": "market",
	},
	"alley": {
		"name": "Переулок",
		"pos": Vector2(-768, 0),
		"idle": "Узкий проход за домами. Чёрный ход пекарни выходит сюда.",
		"art": "alley",
	},
	"embankment": {
		"name": "Набережная",
		"pos": Vector2(0, 768),
		"idle": "Мост через яркую воду. По камням никто не идёт.",
		"art": "embankment",
	},
}


static func ids() -> Array[String]:
	var list: Array[String] = []
	for id in PLACES:
		list.append(str(id))
	return list


static func place(id: String) -> Dictionary:
	return PLACES[id]


static func pos_of(id: String) -> Vector2:
	return PLACES[id]["pos"]


## Границы сетки камеры по точкам города (в клетках GRID_SIZE).
static func grid_bounds() -> Rect2i:
	var min_x := 999
	var max_x := -999
	var min_y := 999
	var max_y := -999
	for id in PLACES:
		var p: Vector2 = PLACES[id]["pos"]
		var gx := int(round(p.x / 256.0))
		var gy := int(round(p.y / 256.0))
		min_x = mini(min_x, gx)
		max_x = maxi(max_x, gx)
		min_y = mini(min_y, gy)
		max_y = maxi(max_y, gy)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


static func in_city(grid: Vector2i) -> bool:
	return grid_bounds().has_point(grid)
