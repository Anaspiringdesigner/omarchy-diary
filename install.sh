#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
plugin_id="anaspiringdesigner.diary"
plugin_url="https://github.com/Anaspiringdesigner/omarchy-diary.git"
menu_file="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/extensions/omarchy-menu.jsonc"
local_install=false
[[ ${1:-} == --local ]] && local_install=true

if ! command -v omarchy >/dev/null 2>&1; then
  echo "install.sh: omarchy was not found. This installer is for Omarchy systems." >&2
  exit 1
fi

if omarchy plugin list --json 2>/dev/null | grep -q "\"id\":\"${plugin_id}\""; then
  echo "Plugin ${plugin_id} is already installed."
  omarchy plugin enable "${plugin_id}" >/dev/null 2>&1 || true
elif [[ $local_install == true ]]; then
  target="${HOME}/.config/omarchy/plugins/${plugin_id}"
  mkdir -p "${target}"
  cp -a "${repo_dir}/." "${target}/"
  omarchy-shell shell rescanPlugins >/dev/null
  omarchy plugin enable "${plugin_id}" >/dev/null 2>&1 || true
  echo "Installed ${plugin_id} from ${repo_dir}."
else
  omarchy plugin add "${plugin_url}" --enable --yes
fi

mkdir -p "$(dirname -- "${menu_file}")"
[[ -f ${menu_file} ]] || printf '{\n}\n' > "${menu_file}"

python3 - "${menu_file}" "${repo_dir}/menu.jsonc" <<'PY'
from pathlib import Path
import sys

menu_path = Path(sys.argv[1])
fragment = Path(sys.argv[2]).read_text(encoding="utf-8").strip()
text = menu_path.read_text(encoding="utf-8") if menu_path.exists() else ""

if '"diary"' in text:
    print(f"Diary menu entries already present in {menu_path}")
    raise SystemExit(0)

if not text.strip():
    text = "{\n}\n"

opening = text.find("{")
if opening == -1:
    raise SystemExit(f"{menu_path}: no opening brace found; add the entries from menu.jsonc by hand")

menu_path.write_text(
    text[: opening + 1] + "\n" + fragment + "\n" + text[opening + 1 :],
    encoding="utf-8",
)
print(f"Added Diary menu entries to {menu_path}")
PY

if command -v diary >/dev/null 2>&1; then
  echo "diary found at $(command -v diary)."
else
  cat >&2 <<'EOF'
diary was not found on PATH. Install it first:
  paru -S diary
or see https://github.com/Anaspiringdesigner/diary
EOF
fi

echo "Done. Open the Omarchy menu and choose Diary."
