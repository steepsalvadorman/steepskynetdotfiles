import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import { createEffect } from "ags"
import GLib from "gi://GLib"

const HOME = GLib.get_home_dir()!
const ICONS = `${HOME}/.config/eww/icons`

type WsItem = { id: number; active: boolean; occupied: boolean }

const wsItems = createPoll<WsItem[]>(
  [1, 2, 3, 4, 5].map(id => ({ id, active: id === 1, occupied: false })),
  300,
  async () => {
    try {
      const [wsList, active] = await Promise.all([
        execAsync("hyprctl workspaces -j").then(JSON.parse),
        execAsync("hyprctl activeworkspace -j").then(JSON.parse),
      ])
      const occupied = new Set<number>((wsList as Array<{ id: number }>).map(w => w.id))
      return [1, 2, 3, 4, 5].map(id => ({
        id,
        active: id === (active as { id: number }).id,
        occupied: occupied.has(id),
      }))
    } catch {
      return [1, 2, 3, 4, 5].map(id => ({ id, active: false, occupied: false }))
    }
  },
)

function WorkspaceBox(): Gtk.Box {
  const container = new Gtk.Box({ spacing: 0 })
  container.add_css_class("ws-box")
  container.set_valign(Gtk.Align.CENTER)

  const buttons = [1, 2, 3, 4, 5].map(id => {
    const btn = new Gtk.Button()
    btn.set_css_classes(["workspace-entry", "empty"])
    const lbl = new Gtk.Label({ label: String(id) })
    btn.set_child(lbl)
    btn.connect("clicked", () => execAsync(`hyprctl dispatch workspace ${id}`))
    container.append(btn)
    return { id, btn }
  })

  createEffect(() => {
    const items = wsItems()
    for (const { id, btn } of buttons) {
      const ws = items.find(w => w.id === id)
      if (ws) {
        btn.set_css_classes([
          "workspace-entry",
          ws.active ? "current" : ws.occupied ? "occupied" : "empty",
        ])
      }
    }
  })

  return container
}

export default function Left(props: { $type?: string }) {
  return (
    <box spacing={8} halign={Gtk.Align.START} valign={Gtk.Align.CENTER}>
      {/* Logo */}
      <button
        class="logo-btn"
        valign={Gtk.Align.CENTER}
        tooltip-text="󰣇 Lanzador de apps · clic derecho: menú de sesión"
        onClicked={() => GLib.spawn_command_line_async("wofi --show drun")}
      >
        <image
          file={`${ICONS}/archlinux.svg`}
          pixel-size={20}
          valign={Gtk.Align.CENTER}
          halign={Gtk.Align.CENTER}
        />
      </button>

      {/* Workspaces */}
      {WorkspaceBox()}
    </box>
  )
}
