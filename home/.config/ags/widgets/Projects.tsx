import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import Gio from "gi://Gio"

const HOME = GLib.get_home_dir()!
const PROJECTS_DIR = `${HOME}/Documentos/programacion`

const LANG_ICONS: Record<string, string> = {
  Python: "󰌠",
  rust:   "󱘗",
  readme: "󰈙",
}
const LANG_LABELS: Record<string, string> = {
  Python: "Python",
  rust:   "Rust",
  readme: "Docs",
}

function listSubdirs(path: string): string[] {
  const dirs: string[] = []
  try {
    const en = Gio.File.new_for_path(path).enumerate_children(
      "standard::name,standard::type",
      Gio.FileQueryInfoFlags.NONE,
      null,
    )
    let info: Gio.FileInfo | null
    while ((info = en.next_file(null)) !== null) {
      if (info.get_file_type() === Gio.FileType.DIRECTORY)
        dirs.push(info.get_name())
    }
  } catch (_) {}
  return dirs.sort()
}

function exists(path: string): boolean {
  return Gio.File.new_for_path(path).query_exists(null)
}

function makeProjectButton(name: string, projPath: string): Gtk.Button {
  const btn = new Gtk.Button()
  btn.add_css_class("project-btn")

  const lbl = new Gtk.Label({ label: `  ${name}`, halign: Gtk.Align.START })
  lbl.add_css_class("project-name")
  btn.set_child(lbl)

  btn.connect("clicked", () => {
    GLib.spawn_command_line_async(`code "${projPath}"`)
    app.toggle_window("projects")
  })

  return btn
}

function buildContent(): Gtk.Box {
  const root = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 0 })
  root.add_css_class("projects-popup")

  const header = new Gtk.Label({ label: " Proyectos", halign: Gtk.Align.START })
  header.add_css_class("projects-header")
  root.append(header)

  for (const lang of listSubdirs(PROJECTS_DIR)) {
    const langPath = `${PROJECTS_DIR}/${lang}`
    const icon  = LANG_ICONS[lang]  ?? "󰉋"
    const label = LANG_LABELS[lang] ?? lang

    const section = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 2 })
    section.add_css_class("projects-section")

    const langLabel = new Gtk.Label({ label: `${icon}  ${label}`, halign: Gtk.Align.START })
    langLabel.add_css_class("projects-lang")
    section.append(langLabel)

    const projects = exists(`${langPath}/.git`)
      ? [{ name: lang, path: langPath }]
      : listSubdirs(langPath).map(p => ({ name: p, path: `${langPath}/${p}` }))

    for (const { name, path } of projects)
      section.append(makeProjectButton(name, path))

    root.append(section)
  }

  return root
}

const { TOP, RIGHT } = Astal.WindowAnchor

export default function Projects() {
  return (
    <window
      name="projects"
      application={app}
      namespace="projects-popup"
      anchor={TOP | RIGHT}
      layer={Astal.Layer.OVERLAY}
      marginTop={62}
      marginRight={585}
      visible={false}
    >
      {buildContent()}
    </window>
  )
}
