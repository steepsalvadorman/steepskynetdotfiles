import app from "ags/gtk4/app"
import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { createSubprocess, execAsync } from "ags/process"
import { createEffect } from "ags"
import GLib from "gi://GLib"

const HOME = GLib.get_home_dir()!
const SCRIPTS = `${HOME}/.config/eww/scripts`
const ICONS = `${HOME}/.config/eww/icons`

// ─── Polls ───────────────────────────────────────────────
const cpu     = createPoll("0", 3000, `${SCRIPTS}/sysinfo --cpu`)
const cpuTemp = createPoll("0", 5000, `${SCRIPTS}/sysinfo --cputemp`)
const ram     = createPoll("0", 3000, `${SCRIPTS}/sysinfo --ram`)
const gpu     = createPoll("0", 3000, `${SCRIPTS}/sysinfo --gpu`)
const gpuTemp = createPoll("0", 5000, `${SCRIPTS}/sysinfo --gputemp`)

const vol   = createPoll("50",    2000, `${SCRIPTS}/volume --get`)
const muted = createPoll("false", 2000, `${SCRIPTS}/volume --muted`)

const dockerCount = createPoll("0",       5000, `${SCRIPTS}/docker_status --count`)
const dockerIcon  = createPoll("󰡨",       5000, `${SCRIPTS}/docker_status --icon`)
const dockerColor = createPoll("#504945", 5000, `${SCRIPTS}/docker_status --color`)

const obsIcon   = createPoll("󰐸",       3000, `${SCRIPTS}/obs_status --icon`)
const obsColor  = createPoll("#9499ad", 3000, `${SCRIPTS}/obs_status --color`)
const obsActive = createPoll("false",   3000, `${SCRIPTS}/obs_status --active`)
const obsStatus = createPoll("inactivo",3000, `${SCRIPTS}/obs_status --status`)

const notifCount = createPoll("0",       5000, `${SCRIPTS}/alerts --count`)
const notifColor = createPoll("#504945", 5000, `${SCRIPTS}/alerts --color`)

const cava = createSubprocess(
  "<span color='#c0bbb4'>▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁</span>",
  `${SCRIPTS}/cava`,
)

// ─── Volume widget (imperative — needs EventControllerMotion) ────────────────
function VolumeWidget() {
  const pill = new Gtk.Box({ spacing: 6 })
  pill.add_css_class("vol-pill")
  pill.set_valign(Gtk.Align.CENTER)

  const iconBtn = new Gtk.Button()
  iconBtn.add_css_class("vol-icon")
  const icon = new Gtk.Image({ pixel_size: 20, valign: Gtk.Align.CENTER })
  iconBtn.set_child(icon)
  iconBtn.connect("clicked", () => execAsync(`${SCRIPTS}/volume --toggle`))

  const revealer = new Gtk.Revealer({
    transition_type: Gtk.RevealerTransitionType.SLIDE_LEFT,
    reveal_child: false,
    transition_duration: 250,
  })

  const scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
  scale.add_css_class("vol-slider")
  scale.set_draw_value(false)
  scale.set_size_request(80, -1)

  let dragging = false
  const gc = new Gtk.GestureClick()
  gc.connect("pressed", () => { dragging = true })
  gc.connect("released", () => {
    dragging = false
    execAsync(`wpctl set-volume @DEFAULT_AUDIO_SINK@ ${Math.round(scale.get_value())}%`)
  })
  scale.add_controller(gc)

  revealer.set_child(scale)
  pill.append(iconBtn)
  pill.append(revealer)

  const mc = new Gtk.EventControllerMotion()
  mc.connect("enter", () => revealer.set_reveal_child(true))
  mc.connect("leave", () => revealer.set_reveal_child(false))
  pill.add_controller(mc)

  createEffect(() => {
    const isMuted = muted() === "true"
    const v = parseInt(vol())
    const iconFile = isMuted       ? `${ICONS}/vol-muted.svg`
                   : v < 30        ? `${ICONS}/vol-low.svg`
                   : v < 70        ? `${ICONS}/vol-mid.svg`
                                   : `${ICONS}/vol-high.svg`
    icon.set_from_file(iconFile)
    if (!dragging) scale.set_value(v)
  })

  return pill
}

// ─── Right section ───────────────────────────────────────
export default function Right(props: { $type?: string }) {
  return (
    <box spacing={6} halign={Gtk.Align.END} valign={Gtk.Align.CENTER}>

      {/* Docker */}
      <button class="icon-pill" valign={Gtk.Align.CENTER}
        tooltip-text={dockerCount(n => `󰡨 Docker · ${n} contenedores activos`)}
        onClicked={() => GLib.spawn_command_line_async("kitty --title 'LazyDocker TUI' sh -c 'lazydocker'")}>
        <box spacing={5} valign={Gtk.Align.CENTER}>
          <label class="icon-label" label={dockerIcon} css={dockerColor(c => `color: ${c};`)} valign={Gtk.Align.CENTER} />
          <label class="icon-count" label={dockerCount} css={dockerColor(c => `color: ${c};`)} valign={Gtk.Align.CENTER} />
        </box>
      </button>

      {/* Btop */}
      <button class="icon-pill" valign={Gtk.Align.CENTER}
        tooltip-text=" Btop · monitor del sistema"
        onClicked={() => GLib.spawn_command_line_async("kitty --title 'Btop Monitor' sh -c 'btop'")}>
        <image file={`${ICONS}/btop.svg`} pixel-size={16} valign={Gtk.Align.CENTER} />
      </button>

      {/* Projects */}
      <button class="icon-pill projects-btn" valign={Gtk.Align.CENTER}
        tooltip-text="󰘦 Proyectos · Documentos/programacion"
        onClicked={() => app.toggle_window("projects")}>
        <box spacing={5} valign={Gtk.Align.CENTER}>
          <label class="icon-label" label="󰘦" valign={Gtk.Align.CENTER} />
          <label class="projects-pill-label" label="Dev" valign={Gtk.Align.CENTER} />
        </box>
      </button>

      {/* OBS */}
      <button class="icon-pill" valign={Gtk.Align.CENTER}
        tooltip-text={obsStatus(s => `󰐸 OBS Studio · ${s}`)}
        onClicked={() => GLib.spawn_command_line_async("obs")}>
        <overlay>
          <label class="icon-label"
            label={obsIcon}
            css={obsColor(c => `color: ${c};`)}
            valign={Gtk.Align.CENTER}
            halign={Gtk.Align.CENTER}
          />
          <label class="obs-badge"
            label="⬤"
            visible={obsActive(a => a === "true")}
            halign={Gtk.Align.END}
            valign={Gtk.Align.START}
          />
        </overlay>
      </button>

      {/* Sysinfo */}
      <box class="sys-pill" spacing={12}>
        <box spacing={4}>
          <image file={`${ICONS}/cpu.svg`}  pixel-size={15} />
          <label class="sys-val" label={cpu(v => `${v}%`)} />
        </box>
        <box spacing={4}>
          <image file={`${ICONS}/temp.svg`} pixel-size={13} />
          <label class="sys-temp" label={cpuTemp(v => `${v}°`)} />
        </box>
        <box spacing={4}>
          <image file={`${ICONS}/ram.svg`}  pixel-size={15} />
          <label class="sys-val" label={ram(v => `${v}%`)} />
        </box>
        <box spacing={4}>
          <image file={`${ICONS}/gpu.svg`}  pixel-size={15} />
          <label class="sys-val" label={gpu(v => `${v}%`)} />
        </box>
        <box spacing={4}>
          <image file={`${ICONS}/temp-gpu.svg`} pixel-size={13} />
          <label class="sys-temp gpu-temp" label={gpuTemp(v => `${v}°`)} />
        </box>
      </box>

      {/* CAVA */}
      <box class="cava-pill" valign={Gtk.Align.CENTER} halign={Gtk.Align.CENTER}>
        <label class="cava-led-label" use-markup label={cava}
          halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER} />
      </box>

      {/* Volume */}
      {VolumeWidget()}

      {/* Alerts */}
      <button class="alerts-pill" valign={Gtk.Align.CENTER}
        tooltip-text={notifCount(n => `󰂚 Notificaciones · ${n} pendientes`)}
        onClicked={() => execAsync("swaync-client -t")}>
        <box spacing={5} valign={Gtk.Align.CENTER}>
          <label class="alerts-icon" label="󰂚"
            css={notifColor(c => `color: ${c};`)} />
          <label class="alerts-count" label={notifCount}
            css={notifColor(c => `color: ${c};`)}
            visible={notifCount(n => n !== "0")} />
        </box>
      </button>
    </box>
  )
}
