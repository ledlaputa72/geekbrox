# LocaleManager.gd - Loads game_translations.csv and applies language via TranslationServer.
# Add new keys and locale columns in assets/translations/game_translations.csv.

extends Node

signal locale_changed(locale_code: String)

const TRANSLATIONS_PATH := "res://assets/translations/game_translations.csv"
const DEFAULT_LOCALE := "en"
const SUPPORTED_LOCALES := ["en", "ko", "ja"]

func _ready() -> void:
	_load_translations()
	var locale_to_use := DEFAULT_LOCALE
	if SettingsManager.get("locale") != null:
		locale_to_use = SettingsManager.locale
	if locale_to_use in SUPPORTED_LOCALES:
		TranslationServer.set_locale(locale_to_use)
	else:
		TranslationServer.set_locale(DEFAULT_LOCALE)
	print("[LocaleManager] Locale: ", TranslationServer.get_locale())

func _load_translations() -> void:
	# NOTE: Avoid FileAccess.get_csv_line() here. In some editor environments it can
	# trigger "Unicode parsing error ... ASCII/Latin-1" spam when CSV contains
	# non-ASCII (ko/ja). We decode as UTF-8 text and parse CSV ourselves.
	var text := FileAccess.get_file_as_string(TRANSLATIONS_PATH)
	if text.is_empty():
		push_error("[LocaleManager] Missing: " + TRANSLATIONS_PATH)
		return
	var lines := text.split("\n", false)
	if lines.is_empty():
		return
	var header := _parse_csv_line(lines[0])
	if header.size() < 2:
		return
	# header: keys, en, ko, ja (or similar)
	var locale_columns: PackedStringArray = []
	for i in range(1, header.size()):
		locale_columns.append(header[i].strip_edges())
	for li in range(1, lines.size()):
		var line := _parse_csv_line(lines[li])
		if line.size() < 2:
			continue
		var key := line[0].strip_edges()
		if key.is_empty():
			continue
		for i in range(1, min(line.size(), locale_columns.size() + 1)):
			var locale := locale_columns[i - 1]
			var msg := line[i].strip_edges() if i < line.size() else ""
			if msg.is_empty():
				continue
			_add_message_to_locale(locale, key, msg)
	# Register each locale's Translation with TranslationServer
	for locale in _translations:
		var trans := Translation.new()
		trans.locale = locale
		for k in _translations[locale]:
			trans.add_message(StringName(k), _translations[locale][k])
		TranslationServer.add_translation(trans)
	var locs := ", ".join(SUPPORTED_LOCALES)
	print("[LocaleManager] Loaded %d keys for locales: %s" % [_key_count(), locs])

var _translations: Dictionary = {}  # locale -> { key -> string }

func _parse_csv_line(line: String) -> PackedStringArray:
	# Minimal CSV parser supporting quoted fields and escaped quotes.
	# Good enough for game_translations.csv (key,en,ko,ja).
	var out: Array[String] = []
	var cur := ""
	var in_quotes := false
	var i := 0
	while i < line.length():
		var ch := line[i]
		if ch == "\"":
			if in_quotes and i + 1 < line.length() and line[i + 1] == "\"":
				cur += "\""
				i += 2
				continue
			in_quotes = not in_quotes
			i += 1
			continue
		if ch == "," and not in_quotes:
			out.append(cur)
			cur = ""
			i += 1
			continue
		cur += ch
		i += 1
	out.append(cur)
	return PackedStringArray(out)

func _add_message_to_locale(locale: String, key: String, msg: String) -> void:
	if not _translations.has(locale):
		_translations[locale] = {}
	_translations[locale][key] = msg

func _key_count() -> int:
	if _translations.has(DEFAULT_LOCALE):
		return _translations[DEFAULT_LOCALE].size()
	return 0

func set_locale(locale_code: String) -> void:
	if locale_code not in SUPPORTED_LOCALES:
		locale_code = DEFAULT_LOCALE
	SettingsManager.locale = locale_code
	SettingsManager.save()
	TranslationServer.set_locale(locale_code)
	locale_changed.emit(locale_code)
	print("[LocaleManager] Set locale: ", locale_code)

func get_current_locale() -> String:
	return TranslationServer.get_locale()

func get_supported_locales() -> PackedStringArray:
	return PackedStringArray(SUPPORTED_LOCALES)

func get_locale_display_name(locale_code: String) -> String:
	match locale_code:
		"en": return "English"
		"ko": return "한국어"
		"ja": return "日本語"
	return locale_code
