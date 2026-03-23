# Game translations (다국어)

All in-game text is driven by `game_translations.csv`. The game supports **English (en)**, **Korean (ko)**, and **Japanese (ja)**.

## File format

- **Path:** `assets/translations/game_translations.csv`
- **Encoding:** UTF-8
- **Columns:** `keys`, `en`, `ko`, `ja` (first row is header)
- **Rows:** One row per phrase. First column = key (e.g. `lobby.past_dreams`), next columns = translation per locale.

Example:

```csv
keys,en,ko,ja
lobby.past_dreams,Past Dreams,지난 꿈들,過去の夢
lobby.start_explore,Start Dream Exploration,꿈 탐험 시작,夢探検を開始
```

## Adding a new key

1. Open `game_translations.csv`.
2. Add a new row: `your.key,English text,한국어 텍스트,日本語テキスト`
3. In script use: `tr("your.key")`

## Adding a new language

1. Add a new column to the CSV, e.g. `zh` for Chinese.
2. In `scripts/autoloads/LocaleManager.gd`:
   - Add the code to `SUPPORTED_LOCALES`, e.g. `"zh"`.
   - In `get_locale_display_name()` add a case for the new code.
3. Fill the new column in the CSV for all rows.

## Changing language in-game

- **Settings screen:** Use the language buttons (English / 한국어 / 日本語).
- **Code:** `LocaleManager.set_locale("ko")` then UI that uses `tr()` will show the new language after refresh (e.g. via `locale_changed` signal).

## Key naming

- `lobby.*` – Main lobby
- `character.*` – Character / stats / equipment
- `combat.*` – Combat UI
- `shop.*` – Shop
- `common.*` – Buttons, confirmations
- `settings.*` – Settings screen
