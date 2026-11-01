import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// A small IPC bridge between the Omarchy shell and the `diary` CLI.
//
// The menu extension installed by install.sh calls:
//
//   omarchy-shell diary newEntry
//   omarchy-shell diary editMonth
//   omarchy-shell diary openPdf
//   omarchy-shell diary buildPdf
//   omarchy-shell diary listMonths
//
// Each method launches the CLI with the diary environment variables that were
// present when omarchy-shell started, so DIARY_DIR, DIARY_TEMPLATE,
// DIARY_EDITOR, DIARY_TECTONIC, and DIARY_NO_OPEN keep working from the menu.
Item {
  id: root

  // Injected by omarchy-shell.
  property var shell: null

  readonly property var diaryEnvironment: {
    var env = {}
    var names = [
      "DIARY_DIR",
      "DIARY_TEMPLATE",
      "DIARY_EDITOR",
      "DIARY_TECTONIC",
      "DIARY_NO_OPEN"
    ]
    for (var i = 0; i < names.length; i++) {
      var value = Quickshell.env(names[i])
      if (value !== undefined && value !== null && String(value) !== "")
        env[names[i]] = String(value)
    }
    return env
  }

  function run(command) {
    Quickshell.execDetached({
      command: ["bash", "-lc", command],
      environment: root.diaryEnvironment,
      clearEnvironment: false
    })
  }

  // Open a terminal and start a new entry in $DIARY_EDITOR.
  function newEntry() {
    root.run("omarchy-launch-floating-terminal-with-presentation diary")
  }

  // Open a terminal and edit this month's entries.md, rebuilding the PDF.
  function editMonth() {
    root.run("omarchy-launch-floating-terminal-with-presentation diary edit")
  }

  // Build the current month if needed and open the PDF.
  function openPdf() {
    root.run("diary open")
  }

  // Rebuild the current month's PDF without opening it.
  function buildPdf() {
    root.run("diary build")
  }

  // Show the month list in a terminal and wait for a key before closing.
  function listMonths() {
    root.run("omarchy-launch-floating-terminal-with-presentation \"diary list; printf '\\nPress any key to close.'; read -n 1\"")
  }

  // Used by install.sh to check that the plugin is loaded.
  function status() {
    return "ok"
  }

  IpcHandler {
    target: "diary"

    function newEntry(): string { root.newEntry(); return "ok" }
    function editMonth(): string { root.editMonth(); return "ok" }
    function openPdf(): string { root.openPdf(); return "ok" }
    function buildPdf(): string { root.buildPdf(); return "ok" }
    function listMonths(): string { root.listMonths(); return "ok" }
    function status(): string { return root.status() }
  }
}
