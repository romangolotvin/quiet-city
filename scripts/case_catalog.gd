class_name CaseCatalog

const VERDICT_BAD := "Время и цвет не сходятся. Сверь записи ещё раз."

## В каждом деле волны есть на всех местах квартала — гуляешь и собираешь полный слепок дня.

const CASES := [
	{
		"id": "lost_ball",
		"difficulty": "easy",
		"order": 1,
		"title": "Дело: потерянный мяч",
		"brief": "Во дворе пропал мяч. Обойди весь квартал: волны есть везде, но важны время и место.",
		"ask": "Кто унёс мяч?",
		"key_time": "15:10",
		"correct": "children",
		"verdict_ok": "Мяч пропал со двора в 15:10 — тогда там стих смех и двор опустел. Остальные волны позже или в стороне.",
		"intake": {
			"client": "kids",
			"client_name": "Дети со двора",
			"speech": "Мы играли во дворе — и мяч вдруг пропал! Мы сами не поняли, как. Помогите найти, кто его унёс!",
		},
		"events": [
			{"id": "ball_yard", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "yard", "time": "15:10", "place": "двор", "note": "Смех стихает. Двор пустеет. Мяча на траве уже нет."},
			{"id": "ball_plaza", "kind": SoundCatalog.Kind.TALK, "place_id": "plaza", "time": "15:18", "place": "площадь", "note": "Разговор у фонтана. О дворе здесь не вспоминают."},
			{"id": "ball_bakery", "kind": SoundCatalog.Kind.TALK, "place_id": "bakery", "time": "15:22", "place": "пекарня", "note": "Тихий заказ у витрины. Мяча тут не видели."},
			{"id": "ball_park", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "park", "time": "15:28", "place": "парк", "note": "Другая компания в парке. Их мяч другой, и время позже."},
			{"id": "ball_gate", "kind": SoundCatalog.Kind.DOG, "place_id": "gate", "time": "15:40", "place": "калитка", "note": "Лай у калитки. До двора далеко."},
			{"id": "ball_porch", "kind": SoundCatalog.Kind.TALK, "place_id": "porch", "time": "15:45", "place": "крыльцо", "note": "Кто-то стоит на крыльце и курит. Спокойно."},
			{"id": "ball_house", "kind": SoundCatalog.Kind.TALK, "place_id": "house", "time": "15:50", "place": "соседний дом", "note": "За стеной ровный разговор."},
			{"id": "ball_market", "kind": SoundCatalog.Kind.FIGHT, "place_id": "market", "time": "16:00", "place": "рынок", "note": "Спор из-за сдачи. К мячу не относится."},
			{"id": "ball_alley", "kind": SoundCatalog.Kind.DOG, "place_id": "alley", "time": "16:05", "place": "переулок", "note": "Короткие вспышки в переулке. След пустой."},
			{"id": "ball_emb", "kind": SoundCatalog.Kind.TALK, "place_id": "embankment", "time": "16:12", "place": "набережная", "note": "Голоса у воды. Мяча здесь нет."},
		],
		"suspects": [
			{"id": "dog", "label": "Собака у калитки", "hint": "У калитки, 15:40", "cry": "плачет"},
			{"id": "neighbor", "label": "Прохожий с площади", "hint": "На площади, 15:18", "cry": "плачет"},
			{"id": "children", "label": "Дети со двора", "hint": "Во дворе, 15:10", "cry": "плачут"},
		],
	},
	{
		"id": "night_shout",
		"difficulty": "easy",
		"order": 2,
		"title": "Дело: ночной крик",
		"brief": "Ночью улицу разбудил крик. Собери волны по всему кварталу и найди источник.",
		"ask": "Кто кричал?",
		"key_time": "22:40",
		"correct": "quarrel",
		"verdict_ok": "Крик шёл с крыльца в 22:40. Остальное — тихие разговоры, лай после или шум в стороне.",
		"intake": {
			"client": "man",
			"client_name": "Сосед с улицы",
			"speech": "Ночью улицу разрезал крик. Я слышал и тихие голоса, и лай, и окрик. Разберитесь, кто именно кричал.",
		},
		"events": [
			{"id": "night_house", "kind": SoundCatalog.Kind.TALK, "place_id": "house", "time": "22:10", "place": "соседний дом", "note": "Говорят тихо, без крика."},
			{"id": "night_plaza", "kind": SoundCatalog.Kind.TALK, "place_id": "plaza", "time": "22:20", "place": "площадь", "note": "Пустая площадь, редкие шаги."},
			{"id": "night_bakery", "kind": SoundCatalog.Kind.TALK, "place_id": "bakery", "time": "22:25", "place": "пекарня", "note": "Ставни закрыты. Почти тишина."},
			{"id": "night_park", "kind": SoundCatalog.Kind.DOG, "place_id": "park", "time": "22:30", "place": "парк", "note": "Дальний лай в парке."},
			{"id": "night_porch", "kind": SoundCatalog.Kind.FIGHT, "place_id": "porch", "time": "22:40", "place": "крыльцо", "note": "Резкая рябь. Здесь голоса сорвались."},
			{"id": "night_gate", "kind": SoundCatalog.Kind.DOG, "place_id": "gate", "time": "22:50", "place": "калитка", "note": "Лай после крика — отклик, не начало."},
			{"id": "night_yard", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "yard", "time": "21:55", "place": "двор", "note": "Двор уже пуст к ночи. Остался только след дневного смеха в памяти волны."},
			{"id": "night_market", "kind": SoundCatalog.Kind.FIGHT, "place_id": "market", "time": "23:00", "place": "рынок", "note": "Поздний спор торговцев. Другая улица."},
			{"id": "night_alley", "kind": SoundCatalog.Kind.TALK, "place_id": "alley", "time": "22:55", "place": "переулок", "note": "Шёпот у чёрного хода."},
			{"id": "night_emb", "kind": SoundCatalog.Kind.TALK, "place_id": "embankment", "time": "23:05", "place": "набережная", "note": "Вода и тихие шаги."},
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
		"brief": "У калитки пропала сумка. Обойди квартал целиком: кража спрятана среди дневного шума.",
		"ask": "Кто унёс сумку?",
		"key_time": "19:10",
		"correct": "stranger",
		"verdict_ok": "В 19:10 у калитки собака рванула на чужие шаги — это момент кражи. Крик позже, дети раньше, остальное — фон квартала.",
		"intake": {
			"client": "girl",
			"client_name": "Девушка у калитки",
			"speech": "Я оставила сумку у калитки ненадолго… а когда вернулась — её уже не было. Вокруг было шумно. Помогите понять, кто её унёс!",
		},
		"events": [
			{"id": "bag_yard", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "yard", "time": "17:20", "place": "двор", "note": "Смех и беготня. К вечеру двор пустеет."},
			{"id": "bag_plaza", "kind": SoundCatalog.Kind.TALK, "place_id": "plaza", "time": "18:40", "place": "площадь", "note": "Вечерний разговор у фонтана."},
			{"id": "bag_bakery", "kind": SoundCatalog.Kind.TALK, "place_id": "bakery", "time": "18:55", "place": "пекарня", "note": "Последние покупатели у витрины."},
			{"id": "bag_park", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "park", "time": "19:00", "place": "парк", "note": "Редкие голоса в парке."},
			{"id": "bag_gate", "kind": SoundCatalog.Kind.DOG, "place_id": "gate", "time": "19:10", "place": "калитка", "note": "Собака рванула на чужие шаги у входа."},
			{"id": "bag_house", "kind": SoundCatalog.Kind.TALK, "place_id": "house", "time": "19:15", "place": "соседний дом", "note": "Спокойный разговор за стеной."},
			{"id": "bag_porch", "kind": SoundCatalog.Kind.FIGHT, "place_id": "porch", "time": "19:40", "place": "крыльцо", "note": "Крик: сумки уже нет. Это находка пропажи."},
			{"id": "bag_market", "kind": SoundCatalog.Kind.FIGHT, "place_id": "market", "time": "19:30", "place": "рынок", "note": "Шумный спор. До калитки далеко."},
			{"id": "bag_alley", "kind": SoundCatalog.Kind.TALK, "place_id": "alley", "time": "19:20", "place": "переулок", "note": "Тихие шаги за домами."},
			{"id": "bag_emb", "kind": SoundCatalog.Kind.TALK, "place_id": "embankment", "time": "19:50", "place": "набережная", "note": "Поздние голоса у воды."},
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
		"brief": "У пекарни треснула витрина. Волны по всему кварталу — найди удар, а не отголоски.",
		"ask": "Кто разбил окно?",
		"key_time": "18:20",
		"correct": "runner",
		"verdict_ok": "Удар был у пекарни в 18:20. Остальные места дают более ранний или более поздний шум.",
		"intake": {
			"client": "baker",
			"client_name": "Пекарь",
			"speech": "Витрина у пекарни треснула! Кто-то ударил по стеклу. Шум слышали в разных местах — найдите, кто разбил окно.",
		},
		"events": [
			{"id": "win_park", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "park", "time": "18:00", "place": "парк", "note": "Игры в парке. Витрина ещё цела."},
			{"id": "win_plaza", "kind": SoundCatalog.Kind.TALK, "place_id": "plaza", "time": "18:10", "place": "площадь", "note": "Обычный говор у фонтана."},
			{"id": "win_bakery", "kind": SoundCatalog.Kind.DOG, "place_id": "bakery", "time": "18:20", "place": "пекарня", "note": "Короткие вспышки у витрины: удар, звон, чужие шаги."},
			{"id": "win_house", "kind": SoundCatalog.Kind.TALK, "place_id": "house", "time": "18:25", "place": "соседний дом", "note": "Отголосок за стеной."},
			{"id": "win_emb", "kind": SoundCatalog.Kind.TALK, "place_id": "embankment", "time": "18:28", "place": "набережная", "note": "Голоса у воды."},
			{"id": "win_market", "kind": SoundCatalog.Kind.FIGHT, "place_id": "market", "time": "18:35", "place": "рынок", "note": "Ссора уже после звона."},
			{"id": "win_yard", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "yard", "time": "17:50", "place": "двор", "note": "Дневной смех во дворе."},
			{"id": "win_gate", "kind": SoundCatalog.Kind.DOG, "place_id": "gate", "time": "18:40", "place": "калитка", "note": "Лай после всего."},
			{"id": "win_porch", "kind": SoundCatalog.Kind.TALK, "place_id": "porch", "time": "18:15", "place": "крыльцо", "note": "Спокойный разговор на ступенях."},
			{"id": "win_alley", "kind": SoundCatalog.Kind.TALK, "place_id": "alley", "time": "18:22", "place": "переулок", "note": "Шаги за пекарней, уже после удара."},
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
		"brief": "С лотка пропал пирог. Собери волны со всех улиц квартала.",
		"ask": "Кто унёс пирог?",
		"key_time": "12:20",
		"correct": "helper",
		"verdict_ok": "Пирог унёс помощник у чёрного хода в 12:20. В 12:12 он ещё был на лотке.",
		"intake": {
			"client": "baker",
			"client_name": "Пекарь",
			"speech": "С лотка пропал свежий пирог! Волн вокруг много. Помогите выяснить, кто его унёс.",
		},
		"events": [
			{"id": "pie_bakery_kids", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "bakery", "time": "12:00", "place": "пекарня", "note": "Дети просили пирог и ушли ни с чем."},
			{"id": "pie_gate", "kind": SoundCatalog.Kind.DOG, "place_id": "gate", "time": "12:10", "place": "калитка", "note": "Лай далеко от лотка."},
			{"id": "pie_wait", "kind": SoundCatalog.Kind.TALK, "place_id": "bakery", "time": "12:12", "place": "пекарня", "note": "У лотка спокойно: пирог ещё на месте."},
			{"id": "pie_plaza", "kind": SoundCatalog.Kind.TALK, "place_id": "plaza", "time": "12:14", "place": "площадь", "note": "Разговор у фонтана. К лотку не ведёт."},
			{"id": "pie_market", "kind": SoundCatalog.Kind.FIGHT, "place_id": "market", "time": "12:18", "place": "рынок", "note": "Ссора в стороне."},
			{"id": "pie_alley", "kind": SoundCatalog.Kind.TALK, "place_id": "alley", "time": "12:20", "place": "переулок", "note": "У чёрного хода тихие шаги. После этой волны лоток пуст."},
			{"id": "pie_yard", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "yard", "time": "11:50", "place": "двор", "note": "Утренний смех во дворе."},
			{"id": "pie_park", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "park", "time": "12:05", "place": "парк", "note": "Игры в парке."},
			{"id": "pie_house", "kind": SoundCatalog.Kind.TALK, "place_id": "house", "time": "12:25", "place": "соседний дом", "note": "Обедный разговор за стеной."},
			{"id": "pie_porch", "kind": SoundCatalog.Kind.TALK, "place_id": "porch", "time": "12:15", "place": "крыльцо", "note": "Кто-то ждёт на ступенях."},
			{"id": "pie_emb", "kind": SoundCatalog.Kind.TALK, "place_id": "embankment", "time": "12:30", "place": "набережная", "note": "Голоса у воды после пропажи."},
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
		"brief": "С гвоздя у калитки пропал ключ. Волны по всему кварталу, времена почти рядом.",
		"ask": "Кто забрал ключ?",
		"key_time": "20:13",
		"correct": "stranger",
		"verdict_ok": "Ключ забрали у калитки в 20:13 — чужие шаги у гвоздя. В 20:10 он ещё висел.",
		"intake": {
			"client": "man",
			"client_name": "Жилец у калитки",
			"speech": "С гвоздя у калитки пропал ключ. Шума вокруг много — отделите, кто именно его забрал.",
		},
		"events": [
			{"id": "key_park", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "park", "time": "19:50", "place": "парк", "note": "Дети разошлись. У калитки их не было."},
			{"id": "key_seen", "kind": SoundCatalog.Kind.TALK, "place_id": "gate", "time": "20:10", "place": "калитка", "note": "Ключ ещё висит на гвозде."},
			{"id": "key_take", "kind": SoundCatalog.Kind.DOG, "place_id": "gate", "time": "20:13", "place": "калитка", "note": "Собака кидается на чужие шаги у гвоздя."},
			{"id": "key_market", "kind": SoundCatalog.Kind.FIGHT, "place_id": "market", "time": "20:14", "place": "рынок", "note": "Громкая ссора на другой улице."},
			{"id": "key_emb", "kind": SoundCatalog.Kind.TALK, "place_id": "embankment", "time": "20:16", "place": "набережная", "note": "Голоса у воды."},
			{"id": "key_house", "kind": SoundCatalog.Kind.TALK, "place_id": "house", "time": "20:18", "place": "соседний дом", "note": "Сосед уже дома."},
			{"id": "key_plaza", "kind": SoundCatalog.Kind.TALK, "place_id": "plaza", "time": "20:05", "place": "площадь", "note": "Вечерний разговор у фонтана."},
			{"id": "key_bakery", "kind": SoundCatalog.Kind.TALK, "place_id": "bakery", "time": "20:00", "place": "пекарня", "note": "Закрывают витрину."},
			{"id": "key_yard", "kind": SoundCatalog.Kind.CHILDREN, "place_id": "yard", "time": "19:40", "place": "двор", "note": "Двор пустеет."},
			{"id": "key_porch", "kind": SoundCatalog.Kind.TALK, "place_id": "porch", "time": "20:08", "place": "крыльцо", "note": "Тихий разговор на ступенях."},
			{"id": "key_alley", "kind": SoundCatalog.Kind.DOG, "place_id": "alley", "time": "20:20", "place": "переулок", "note": "Поздний лай в переулке."},
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
		{"id": "easy", "title": "Лёгкая", "blurb": "Волны по всему кварталу"},
		{"id": "medium", "title": "Средняя", "blurb": "Много шума, одна кража"},
		{"id": "hard", "title": "Сложная", "blurb": "Близкое время на всех улицах"},
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
