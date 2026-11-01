# Omarchy Diary

A small Omarchy shell plugin and native menu extension for the
[`diary`](https://github.com/Anaspiringdesigner/diary) CLI: write a new entry, edit
this month, open the PDF, rebuild it, or list your months without leaving the
Omarchy menu.

![A page from a sample diary month](preview.png)

## What it installs

- **`anaspiringdesigner.diary`** — a `service` plugin that exposes a `diary` IPC
  target to the Omarchy shell.
- **Six menu entries** under **Diary** in the native Omarchy menu.

The plugin does not contain a second copy of the diary. It calls the `diary`
command already on your `PATH`, so your journal stays in one place.

## Requirements

- Omarchy 4 (the Quickshell shell with the plugin system)
- [`diary`](https://github.com/Anaspiringdesigner/diary) — install it from the AUR:

  ```sh
  paru -S diary
  ```

## Install

From a clone of this repository:

```sh
git clone https://github.com/Anaspiringdesigner/omarchy-diary.git
cd omarchy-diary
./install.sh
```

The installer runs:

```sh
omarchy plugin add https://github.com/Anaspiringdesigner/omarchy-diary.git --enable --yes
```

and then adds the Diary entries to
`~/.config/omarchy/extensions/omarchy-menu.jsonc` without touching your other
entries. Existing menu customizations are preserved.

To install from the working tree instead of GitHub (useful while developing):

```sh
./install.sh --local
```

## Use

Open the Omarchy menu and choose **Diary**:

| Entry | What it does |
| --- | --- |
| New Entry | Opens a terminal and starts `diary` in your editor |
| Edit This Month | Opens this month's `entries.md`, then rebuilds the PDF |
| Open This Month's PDF | Builds the PDF if needed and opens it |
| Rebuild PDF | Rebuilds this month's PDF |
| List Months | Shows the month list with entry counts and PDF status |

The same actions are available over shell IPC:

```sh
omarchy-shell diary newEntry
omarchy-shell diary editMonth
omarchy-shell diary openPdf
omarchy-shell diary buildPdf
omarchy-shell diary listMonths
omarchy-shell diary status
```

This is handy for keybindings. For example, in
`~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER", "D", "diary new entry", "omarchy-shell diary newEntry")
```

## Configuration

The plugin passes the diary environment variables it inherits from the shell
process straight through:

| Variable | Purpose |
| --- | --- |
| `DIARY_DIR` | Diary root (default `~/Documents/diary`) |
| `DIARY_TEMPLATE` | LaTeX template path |
| `DIARY_TECTONIC` | Specific Tectonic binary |
| `DIARY_EDITOR` | Editor for entries |
| `DIARY_NO_OPEN` | Set to `1` to never launch the PDF viewer |

Set them in your session environment (for example in `~/.config/uwsm/env` or
your shell profile) and restart the shell with `omarchy restart shell`.

## Manual installation

If you prefer to do it by hand:

1. Clone the repository into the plugin directory:

   ```sh
   git clone https://github.com/Anaspiringdesigner/omarchy-diary.git \
     ~/.config/omarchy/plugins/anaspiringdesigner.diary
   ```

2. Reload and enable the plugin:

   ```sh
   omarchy-shell shell rescanPlugins
   omarchy plugin enable anaspiringdesigner.diary
   ```

3. Add the contents of [`menu.jsonc`](menu.jsonc) to
   `~/.config/omarchy/extensions/omarchy-menu.jsonc` (inside the outer
   braces), or run `./install.sh` to merge them automatically.

## Uninstall

```sh
omarchy plugin remove anaspiringdesigner.diary --yes
```

Then delete the `"diary"` and `"diary.*"` entries from
`~/.config/omarchy/extensions/omarchy-menu.jsonc`.

## License

MIT. See [LICENSE](LICENSE).
