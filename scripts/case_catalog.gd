class_name CaseCatalog

const VERDICT_BAD := "Время и цвет не сходятся. Сверь записи ещё раз."

const CASES := [
	{
		"id": "lost_ball",
		"difficulty": "easy",
		"order": 1,
		"title": "Дело: потерянный мяч",
		"brief": "Во дворе пропал мяч. Волны в разных местах — сравни время и место, не только цвет.",
		"ask": "Кто унёс мяч?",
		"key_time": "15:10",
		"correct": "children",
		"verdict_ok": "Дети сами унесли мяч в 15:10, уходя со двора. Собака у калитки лаяла позже. Разговор на площади к мячу не относится.",
		"intake": {
			"client": "kids",
			"client_name": "Дети со двора",
			"speech": "Мы играли во дворе — и мяч вдруг пропал! Мы сами не поняли, как. Помогите найти, кто его унёс!",
		},
		"events": [
			{
				"id": "ball_kids",
				"kind": SoundCatalog.Kind.CHILDREN,
				"place_id": "yard",
				"time": "15:10",
				"place": "двор",
				"note": "Смех стихает. Компания собирается и уходит. Мяч мог уйти вместе с ними."
			},
			{
				"id": "ball_talk",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "plaza",
				"time": "15:25",
				"place": "площадь",
				"note": "Спокойный разговор у фонтана. О мяче здесь не говорят."
			},
			{
				"id": "ball_dog",
				"kind": SoundCatalog.Kind.DOG,
				"place_id": "gate",
				"time": "15:40",
				"place": "калитка",
				"note": "Лай далеко от двора. У калитки мяча не видно."
			},
		],
		"suspects": [
			{"id": "dog", "label": "Собака у калитки", "hint": "У калитки, 15:40", "cry": "плачет"},
			{"id": "neighbor", "label": "Прохожий с площади", "hint": "На площади, 15:25", "cry": "плачет"},
			{"id": "children", "label": "Дети со двора", "hint": "Во дворе, 15:10", "cry": "плачут"},
		],
	},
	{
		"id": "night_shout",
		"difficulty": "easy",
		"order": 2,
		"title": "Дело: ночной крик",
		"brief": "Ночью улицу разбудил крик. Несколько волн подряд — отдели резкий крик от шума вокруг.",
		"ask": "Кто кричал?",
		"key_time": "22:40",
		"correct": "quarrel",
		"verdict_ok": "Крик шёл с крыльца в 22:40. В доме говорили тихо раньше, а собака у калитки лаяла уже после.",
		"intake": {
			"client": "man",
			"client_name": "Сосед с улицы",
			"speech": "Ночью улицу разрезал крик. Я слышал и тихие голоса, и лай, и окрик. Разберитесь, кто именно кричал.",
		},
		"events": [
			{
				"id": "night_talk",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "house",
				"time": "22:10",
				"place": "соседний дом",
				"note": "Ровная пульсация. Говорят тихо, без крика."
			},
			{
				"id": "night_fight",
				"kind": SoundCatalog.Kind.FIGHT,
				"place_id": "porch",
				"time": "22:40",
				"place": "крыльцо",
				"note": "Резкая рябь от крыльца. Здесь голоса сорвались."
			},
			{
				"id": "night_dog",
				"kind": SoundCatalog.Kind.DOG,
				"place_id": "gate",
				"time": "22:50",
				"place": "калитка",
				"note": "Лай после крика. Собака отозвалась на шум, а не начала его."
			},
		],
		"suspects": [
			{"id": "neighbor", "label": "Сосед за дверью", "hint": "В доме, 22:10", "cry": "плачет"},
			{"id": "dog", "label": "Собака у калитки", "hint": "У калитки, 22:50", "cry": "плачет"},
			{"id": "quarrel", "label": "Двое с крыльца", "hint": "На крыльце, 22:40", "cry": "плачут"},
		],
	},
	{
		"id": "stolen_bag",
		"difficulty": "medium",
		"order": 3,
		"title": "Дело: пропавшая сумка",
		"brief": "Вечером у калитки пропала сумка. Хозяйка заметила это не сразу. Отдели момент кражи от позднего крика.",
		"ask": "Кто унёс сумку?",
		"key_time": "19:10",
		"correct": "stranger",
		"verdict_ok": "Сумку унёс незнакомец у калитки в 19:10 — тогда собака рванула на чужие шаги. Дети ушли раньше, сосед был дома, крик в 19:40 — уже обнаружение пропажи, а на рынке шумели мимоходом.",
		"intake": {
			"client": "girl",
			"client_name": "Девушка у калитки",
			"speech": "Я оставила сумку у калитки ненадолго… а когда вернулась — её уже не было. Я не сразу заметила. Вокруг было шумно. Помогите понять, кто её унёс!",
		},
		"events": [
			{
				"id": "bag_kids",
				"kind": SoundCatalog.Kind.CHILDREN,
				"place_id": "yard",
				"time": "17:20",
				"place": "двор",
				"note": "Смех и беготня. К вечеру двор пустеет."
			},
			{
				"id": "bag_dog",
				"kind": SoundCatalog.Kind.DOG,
				"place_id": "gate",
				"time": "19:10",
				"place": "калитка",
				"note": "Собака рванула на чужие шаги у входа. Сумка ещё могла стоять рядом."
			},
			{
				"id": "bag_talk",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "house",
				"time": "19:15",
				"place": "соседний дом",
				"note": "Спокойный разговор за стеной. Отсюда никто не выходил."
			},
			{
				"id": "bag_market",
				"kind": SoundCatalog.Kind.FIGHT,
				"place_id": "market",
				"time": "19:30",
				"place": "рынок",
				"note": "Шумный спор на рынке. До калитки далеко."
			},
			{
				"id": "bag_fight",
				"kind": SoundCatalog.Kind.FIGHT,
				"place_id": "porch",
				"time": "19:40",
				"place": "крыльцо",
				"note": "Крик: сумки уже нет. Это находка пропажи, не кража."
			},
		],
		"suspects": [
			{"id": "children", "label": "Дети со двора", "hint": "Во дворе, 17:20", "cry": "плачут"},
			{"id": "neighbor", "label": "Сосед из тихого дома", "hint": "В доме, 19:15", "cry": "плачет"},
			{"id": "quarrel", "label": "Спорщики с рынка", "hint": "На рынке, 19:30", "cry": "плачут"},
			{"id": "stranger", "label": "Незнакомец у калитки", "hint": "У калитки, 19:10", "cry": "плачет"},
		],
	},
	{
		"id": "broken_window",
		"difficulty": "medium",
		"order": 4,
		"title": "Дело: разбитое окно",
		"brief": "У пекарни треснула витрина. Шум был в разных местах — найди удар по стеклу, а не отголоски.",
		"ask": "Кто разбил окно?",
		"key_time": "18:20",
		"correct": "runner",
		"verdict_ok": "Удар был у пекарни в 18:20 — чужие шаги и звон стекла. Дети были в парке раньше, сосед говорил дома, на рынке заспорили уже после, а на набережной шумели мимо.",
		"intake": {
			"client": "baker",
			"client_name": "Пекарь",
			"speech": "Витрина у пекарни треснула! Кто-то ударил по стеклу. Шум слышали в разных местах — найдите, кто разбил окно.",
		},
		"events": [
			{
				"id": "win_kids",
				"kind": SoundCatalog.Kind.CHILDREN,
				"place_id": "park",
				"time": "18:00",
				"place": "парк",
				"note": "Игры в парке. До пекарни далеко, витрина ещё цела."
			},
			{
				"id": "win_dog",
				"kind": SoundCatalog.Kind.DOG,
				"place_id": "bakery",
				"time": "18:20",
				"place": "пекарня",
				"note": "Короткие вспышки у витрины: удар, звон, чужие шаги."
			},
			{
				"id": "win_talk",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "house",
				"time": "18:25",
				"place": "соседний дом",
				"note": "Разговор за стеной. Сюда только донёсся отголосок."
			},
			{
				"id": "win_emb",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "embankment",
				"time": "18:28",
				"place": "набережная",
				"note": "Голоса у воды. К витрине это не относится."
			},
			{
				"id": "win_fight",
				"kind": SoundCatalog.Kind.FIGHT,
				"place_id": "market",
				"time": "18:35",
				"place": "рынок",
				"note": "Ссора уже после звона. Спорят о битом окне, а не бьют его."
			},
		],
		"suspects": [
			{"id": "children", "label": "Дети из парка", "hint": "В парке, 18:00", "cry": "плачут"},
			{"id": "neighbor", "label": "Сосед", "hint": "В доме, 18:25", "cry": "плачет"},
			{"id": "quarrel", "label": "Спорщики с рынка", "hint": "На рынке, 18:35", "cry": "плачут"},
			{"id": "runner", "label": "Прохожий у витрины", "hint": "У пекарни, 18:20", "cry": "плачет"},
		],
	},
	{
		"id": "stolen_pie",
		"difficulty": "hard",
		"order": 5,
		"title": "Дело: пропавший пирог",
		"brief": "С лотка пекарни пропал пирог. Волны идут почти подряд. Найди момент, когда пирог ещё был и когда лоток опустел.",
		"ask": "Кто унёс пирог?",
		"key_time": "12:20",
		"correct": "helper",
		"verdict_ok": "Пирог унёс помощник у чёрного хода в 12:20 — тихие шаги в переулке. В 12:12 пирог ещё был на лотке. Дети ушли раньше, собака лаяла у калитки, на рынке шумели, а на площади говорили мимоходом.",
		"intake": {
			"client": "baker",
			"client_name": "Пекарь",
			"speech": "С лотка пропал свежий пирог! Я на минуту отвернулся — и его уже нет. Волн вокруг много. Помогите выяснить, кто его унёс.",
		},
		"events": [
			{
				"id": "pie_kids",
				"kind": SoundCatalog.Kind.CHILDREN,
				"place_id": "bakery",
				"time": "12:00",
				"place": "пекарня",
				"note": "Дети просили пирог и ушли ни с чем."
			},
			{
				"id": "pie_dog",
				"kind": SoundCatalog.Kind.DOG,
				"place_id": "gate",
				"time": "12:10",
				"place": "калитка",
				"note": "Лай далеко от лотка. До пекарни собака не дошла."
			},
			{
				"id": "pie_baker",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "bakery",
				"time": "12:12",
				"place": "пекарня",
				"note": "Пекарь говорит спокойно: пирог ещё стоит на лотке."
			},
			{
				"id": "pie_plaza",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "plaza",
				"time": "12:16",
				"place": "площадь",
				"note": "Разговор у фонтана. К лотку это не ведёт."
			},
			{
				"id": "pie_fight",
				"kind": SoundCatalog.Kind.FIGHT,
				"place_id": "market",
				"time": "12:18",
				"place": "рынок",
				"note": "Ссора на рынке, в стороне от пекарни."
			},
			{
				"id": "pie_helper",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "alley",
				"time": "12:20",
				"place": "переулок",
				"note": "У чёрного хода тихие шаги. После этой волны лоток пуст."
			},
		],
		"suspects": [
			{"id": "children", "label": "Дети у витрины", "hint": "У пекарни, 12:00", "cry": "плачут"},
			{"id": "dog", "label": "Собака у калитки", "hint": "У калитки, 12:10", "cry": "плачет"},
			{"id": "quarrel", "label": "Спорщики с рынка", "hint": "На рынке, 12:18", "cry": "плачут"},
			{"id": "helper", "label": "Помощник у чёрного хода", "hint": "В переулке, 12:20", "cry": "плачет"},
		],
	},
	{
		"id": "missing_key",
		"difficulty": "hard",
		"order": 6,
		"title": "Дело: пропавший ключ",
		"brief": "С гвоздя у калитки пропал ключ. Времена почти совпадают — отдели момент пропажи от шума на других улицах.",
		"ask": "Кто забрал ключ?",
		"key_time": "20:13",
		"correct": "stranger",
		"verdict_ok": "Ключ забрал незнакомец у калитки в 20:13 — чужие шаги прямо у гвоздя. В 20:10 ключ ещё висел. Дети были в парке раньше, на рынке шумели, сосед в 20:18 уже говорил дома, а на набережной шли мимо.",
		"intake": {
			"client": "man",
			"client_name": "Жилец у калитки",
			"speech": "С гвоздя у калитки пропал ключ. Он точно висел ещё недавно. Шума вокруг много — отделите, кто именно его забрал.",
		},
		"events": [
			{
				"id": "key_kids",
				"kind": SoundCatalog.Kind.CHILDREN,
				"place_id": "park",
				"time": "19:50",
				"place": "парк",
				"note": "Дети играли и разошлись. У калитки их не было."
			},
			{
				"id": "key_seen",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "gate",
				"time": "20:10",
				"place": "калитка",
				"note": "Спокойный разговор у столба: ключ ещё висит на гвозде."
			},
			{
				"id": "key_dog",
				"kind": SoundCatalog.Kind.DOG,
				"place_id": "gate",
				"time": "20:13",
				"place": "калитка",
				"note": "Собака кидается на чужие шаги прямо у гвоздя."
			},
			{
				"id": "key_fight",
				"kind": SoundCatalog.Kind.FIGHT,
				"place_id": "market",
				"time": "20:14",
				"place": "рынок",
				"note": "Громкая ссора на рынке. Это другая улица."
			},
			{
				"id": "key_emb",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "embankment",
				"time": "20:16",
				"place": "набережная",
				"note": "Голоса у воды. К гвоздю у калитки не ведут."
			},
			{
				"id": "key_home",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "house",
				"time": "20:18",
				"place": "соседний дом",
				"note": "Сосед уже дома. Ключа при нём нет."
			},
		],
		"suspects": [
			{"id": "children", "label": "Дети из парка", "hint": "В парке, 19:50", "cry": "плачут"},
			{"id": "neighbor", "label": "Сосед", "hint": "В доме, 20:18", "cry": "плачет"},
			{"id": "quarrel", "label": "Спорщики с рынка", "hint": "На рынке, 20:14", "cry": "плачут"},
			{"id": "stranger", "label": "Незнакомец у калитки", "hint": "У калитки, 20:13", "cry": "плачет"},
		],
	},
]


static func by_id(id: String) -> Dictionary:
	for case_data in CASES:
		if str(case_data["id"]) == id:
			return case_data
	return CASES[0]


static func difficulties() -> Array[Dictionary]:
	return [
		{"id": "easy", "title": "Лёгкая", "blurb": "Три знака, ложный след"},
		{"id": "medium", "title": "Средняя", "blurb": "Пять волн и путаница"},
		{"id": "hard", "title": "Сложная", "blurb": "Близкое время, много шума"},
	]


static func cases_for(diff: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for case_data in CASES:
		if str(case_data["difficulty"]) == diff:
			list.append(case_data)
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["order"]) < int(b["order"])
	)
	return list
