class_name CaseCatalog

const VERDICT_BAD := "Время и цвет не сходятся. Сверь записи ещё раз."

const CASES := [
	{
		"id": "lost_ball",
		"difficulty": "easy",
		"order": 1,
		"title": "Дело: потерянный мяч",
		"brief": "Во дворе пропал мяч. Два знака, два времени — сравни, где мяч ещё могли унести.",
		"ask": "Кто унёс мяч?",
		"key_time": "15:10",
		"correct": "children",
		"verdict_ok": "Дети. В 15:10 зелёная волна: они ушли со двора и забрали мяч. Собака залаяла позже и у калитки, не во дворе.",
		"intake": {
			"client": "kids",
			"client_name": "Дети со двора",
			"speech": "Дяденька, помогите! Мы играли во дворе, и мяч куда-то пропал. Кто-то его унёс — мы сами не видели. Пожалуйста, найдите, кто это сделал!",
		},
		"events": [
			{
				"id": "ball_kids",
				"kind": SoundCatalog.Kind.CHILDREN,
				"place_id": "yard",
				"time": "15:10",
				"place": "двор",
				"note": "Смех стихает. Дети собираются и уходят, мяч уносят с собой."
			},
			{
				"id": "ball_dog",
				"kind": SoundCatalog.Kind.DOG,
				"place_id": "gate",
				"time": "15:40",
				"place": "калитка",
				"note": "Жёлтые вспышки далеко от двора. Собака лает у калитки, мяча там нет."
			},
		],
		"suspects": [
			{"id": "dog", "label": "Собака у калитки", "hint": "Жёлтые вспышки в 15:40"},
			{"id": "children", "label": "Дети со двора", "hint": "Зелёная волна в 15:10"},
		],
	},
	{
		"id": "night_shout",
		"difficulty": "easy",
		"order": 2,
		"title": "Дело: ночной крик",
		"brief": "Ночью улицу разбудил крик. Один звук был тихим, другой — резким.",
		"ask": "Кто кричал?",
		"key_time": "22:40",
		"correct": "quarrel",
		"verdict_ok": "Ссора на крыльце. Красная рябь в 22:40 — это крик. Синяя волна в 22:10 была спокойным разговором.",
		"intake": {
			"client": "man",
			"client_name": "Сосед с улицы",
			"speech": "Ночью улицу разрезал крик. Я сам не уверен, кто это был — слышал и тихий разговор, и резкий окрик. Разберитесь, пожалуйста, кто кричал.",
		},
		"events": [
			{
				"id": "night_talk",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "house",
				"time": "22:10",
				"place": "соседний дом",
				"note": "Ровная синяя пульсация. Говорят тихо, без крика."
			},
			{
				"id": "night_fight",
				"kind": SoundCatalog.Kind.FIGHT,
				"place_id": "porch",
				"time": "22:40",
				"place": "крыльцо",
				"note": "Красная рябь бьёт от крыльца. Здесь сорвались на крик."
			},
		],
		"suspects": [
			{"id": "neighbor", "label": "Сосед за дверью", "hint": "Синяя пульсация в 22:10"},
			{"id": "quarrel", "label": "Ссора на крыльце", "hint": "Красная рябь в 22:40"},
		],
	},
	{
		"id": "stolen_bag",
		"difficulty": "medium",
		"order": 3,
		"title": "Дело: пропавшая сумка",
		"brief": "Вечером у калитки пропала сумка. Хозяйка заметила это не сразу. Запиши все волны и отдели кражу от крика.",
		"ask": "Кто унёс сумку?",
		"key_time": "19:10",
		"correct": "stranger",
		"verdict_ok": "Незнакомец у калитки. В 19:10 собака лаяла на чужие шаги — это момент кражи. Дети давно ушли, сосед говорил дома, а крик в 19:40 — уже обнаружение пропажи.",
		"intake": {
			"client": "girl",
			"client_name": "Девушка у калитки",
			"speech": "Я оставила сумку у калитки ненадолго… а когда вернулась — её уже не было. Я не сразу заметила. Помогите понять, кто её унёс!",
		},
		"events": [
			{
				"id": "bag_kids",
				"kind": SoundCatalog.Kind.CHILDREN,
				"place_id": "yard",
				"time": "17:20",
				"place": "двор",
				"note": "Смех и беготня. К вечеру зелёная волна стихла — дети ушли засветло."
			},
			{
				"id": "bag_dog",
				"kind": SoundCatalog.Kind.DOG,
				"place_id": "gate",
				"time": "19:10",
				"place": "калитка",
				"note": "Жёлтые вспышки: собака рванула на чужие шаги. Сумка ещё могла стоять у входа."
			},
			{
				"id": "bag_talk",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "house",
				"time": "19:15",
				"place": "соседний дом",
				"note": "Синяя пульсация. Спокойный разговор за стеной: сосед никуда не выходил."
			},
			{
				"id": "bag_fight",
				"kind": SoundCatalog.Kind.FIGHT,
				"place_id": "porch",
				"time": "19:40",
				"place": "крыльцо",
				"note": "Красная рябь и крик: сумки уже нет. Это находка пропажи, не кража."
			},
		],
		"suspects": [
			{"id": "children", "label": "Дети со двора", "hint": "Зелёная волна в 17:20"},
			{"id": "neighbor", "label": "Сосед из тихого дома", "hint": "Синяя пульсация в 19:15"},
			{"id": "stranger", "label": "Незнакомец у калитки", "hint": "Жёлтые вспышки в 19:10"},
		],
	},
	{
		"id": "broken_window",
		"difficulty": "medium",
		"order": 4,
		"title": "Дело: разбитое окно",
		"brief": "У пекарни треснула витрина. Шум был в разных местах — смотри, где и когда звенело стекло.",
		"ask": "Кто разбил окно?",
		"key_time": "18:20",
		"correct": "runner",
		"verdict_ok": "Прохожий у витрины. В 18:20 жёлтые вспышки прямо у пекарни — удар и звон. Дети были в парке раньше, сосед говорил дома, а красная ссора на рынке началась уже после.",
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
				"note": "Зелёная волна далеко от пекарни. Дети играют, витрина ещё цела."
			},
			{
				"id": "win_dog",
				"kind": SoundCatalog.Kind.DOG,
				"place_id": "bakery",
				"time": "18:20",
				"place": "пекарня",
				"note": "Короткие жёлтые вспышки у витрины: удар, звон стекла, чужие шаги."
			},
			{
				"id": "win_talk",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "house",
				"time": "18:25",
				"place": "соседний дом",
				"note": "Синий разговор за стеной. Сюда звон только донёсся, сосед не выходил."
			},
			{
				"id": "win_fight",
				"kind": SoundCatalog.Kind.FIGHT,
				"place_id": "market",
				"time": "18:35",
				"place": "рынок",
				"note": "Красная ссора уже после звона. Спорят о битом окне, а не бьют его."
			},
		],
		"suspects": [
			{"id": "children", "label": "Дети из парка", "hint": "Зелёная волна в 18:00"},
			{"id": "neighbor", "label": "Сосед", "hint": "Синяя пульсация в 18:25"},
			{"id": "runner", "label": "Прохожий у витрины", "hint": "Жёлтые вспышки в 18:20"},
		],
	},
	{
		"id": "stolen_pie",
		"difficulty": "hard",
		"order": 5,
		"title": "Дело: пропавший пирог",
		"brief": "С лотка пекарни пропал пирог. Волны идут почти подряд. Запомни, в какой момент пирог ещё был на месте.",
		"ask": "Кто унёс пирог?",
		"key_time": "12:20",
		"correct": "helper",
		"verdict_ok": "Помощник у чёрного хода. В 12:12 пирог ещё на лотке. В 12:20 тихая синяя волна в переулке — его унесли без крика. Дети ушли раньше, собака была у калитки, красная ссора гремела на рынке.",
		"intake": {
			"client": "baker",
			"client_name": "Пекарь",
			"speech": "С лотка пропал свежий пирог! Я на минуту отвернулся — и его уже нет. Волны вокруг путаные. Помогите выяснить, кто его унёс.",
		},
		"events": [
			{
				"id": "pie_kids",
				"kind": SoundCatalog.Kind.CHILDREN,
				"place_id": "bakery",
				"time": "12:00",
				"place": "пекарня",
				"note": "Дети просили пирог и ушли ни с чем. Зелёная волна стихла."
			},
			{
				"id": "pie_dog",
				"kind": SoundCatalog.Kind.DOG,
				"place_id": "gate",
				"time": "12:10",
				"place": "калитка",
				"note": "Жёлтый лай далеко от лотка. Собака до пекарни не дошла."
			},
			{
				"id": "pie_baker",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "bakery",
				"time": "12:12",
				"place": "пекарня",
				"note": "Пекарь спокойно говорит: пирог ещё стоит на лотке."
			},
			{
				"id": "pie_fight",
				"kind": SoundCatalog.Kind.FIGHT,
				"place_id": "market",
				"time": "12:18",
				"place": "рынок",
				"note": "Красная ссора на рынке, в стороне от пекарни."
			},
			{
				"id": "pie_helper",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "alley",
				"time": "12:20",
				"place": "переулок",
				"note": "У чёрного хода тихие шаги. После этой синей волны лоток пуст."
			},
		],
		"suspects": [
			{"id": "children", "label": "Дети", "hint": "Зелёная волна в 12:00"},
			{"id": "dog", "label": "Собака", "hint": "Жёлтые вспышки в 12:10"},
			{"id": "helper", "label": "Помощник у чёрного хода", "hint": "Синяя пульсация в 12:20"},
		],
	},
	{
		"id": "missing_key",
		"difficulty": "hard",
		"order": 6,
		"title": "Дело: пропавший ключ",
		"brief": "С гвоздя у калитки пропал ключ. Времена близкие: отдели момент пропажи от шума на других улицах.",
		"ask": "Кто забрал ключ?",
		"key_time": "20:13",
		"correct": "stranger",
		"verdict_ok": "Незнакомец у калитки. В 20:10 ключ ещё висел. В 20:13 жёлтые вспышки — чужие шаги прямо у гвоздя. Дети были в парке раньше, красная ссора гремела на рынке, сосед в 20:18 уже говорил дома.",
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
				"note": "Жёлтые вспышки: собака кидается на чужие шаги прямо у гвоздя."
			},
			{
				"id": "key_fight",
				"kind": SoundCatalog.Kind.FIGHT,
				"place_id": "market",
				"time": "20:14",
				"place": "рынок",
				"note": "Красная ссора на рынке. Громко, но это другая улица."
			},
			{
				"id": "key_home",
				"kind": SoundCatalog.Kind.TALK,
				"place_id": "house",
				"time": "20:18",
				"place": "соседний дом",
				"note": "Сосед уже дома. Синяя волна за стеной, ключа при нём нет."
			},
		],
		"suspects": [
			{"id": "children", "label": "Дети из парка", "hint": "Зелёная волна в 19:50"},
			{"id": "neighbor", "label": "Сосед", "hint": "Синяя пульсация в 20:18"},
			{"id": "stranger", "label": "Незнакомец у калитки", "hint": "Жёлтые вспышки в 20:13"},
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
		{"id": "easy", "title": "Лёгкая", "blurb": "Два знака, явный цвет"},
		{"id": "medium", "title": "Средняя", "blurb": "Четыре места и ложный крик"},
		{"id": "hard", "title": "Сложная", "blurb": "Близкое время, похожие волны"},
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
