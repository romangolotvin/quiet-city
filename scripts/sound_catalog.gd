class_name SoundCatalog

enum Kind { FIGHT, CHILDREN, DOG, TALK }

const COLORS := {
	Kind.FIGHT: Color(0.92, 0.22, 0.25),
	Kind.CHILDREN: Color(0.22, 0.78, 0.38),
	Kind.DOG: Color(0.98, 0.82, 0.18),
	Kind.TALK: Color(0.22, 0.48, 0.95),
}

const WAVE_NAMES := {
	Kind.FIGHT: "Красная рябь",
	Kind.CHILDREN: "Зелёная волна",
	Kind.DOG: "Жёлтые вспышки",
	Kind.TALK: "Синяя пульсация",
}

const TITLES := {
	Kind.FIGHT: "Ссора",
	Kind.CHILDREN: "Дети",
	Kind.DOG: "Собака",
	Kind.TALK: "Разговор",
}


static func color(kind: Kind) -> Color:
	return COLORS[kind]


static func wave_name(kind: Kind) -> String:
	return WAVE_NAMES[kind]


static func title(kind: Kind) -> String:
	return TITLES[kind]


static func description(kind: Kind) -> String:
	match kind:
		Kind.FIGHT:
			return "Резкие красные всплески. Крик, спор, удары голоса о стены дома."
		Kind.CHILDREN:
			return "Мягкая зелёная волна. Смех, беготня, игра во дворе."
		Kind.DOG:
			return "Короткие жёлтые вспышки. Лай, когти по камню, шаги по переулку."
		Kind.TALK:
			return "Ровная синяя пульсация. Спокойный разговор за закрытой дверью."
		_:
			return ""


static func all_kinds() -> Array[Kind]:
	return [Kind.FIGHT, Kind.CHILDREN, Kind.DOG, Kind.TALK]
