class_name UpdateConfig

## Локальная версия этой сборки. Поднимай при каждом релизе.
const APP_VERSION := "1.1.7"

## Файл version.json в интернете. Замени на свой URL (GitHub raw / сайт).
## Формат: { "version": "1.1.1", "notes": "...", "windows": "https://...", "android": "https://..." }
const MANIFEST_URL := "https://raw.githubusercontent.com/romangolotvin/quiet-city/main/updates/version.json"

## Локальный эталон в проекте (для сравнения и как пример).
const LOCAL_MANIFEST := "res://updates/version.json"
