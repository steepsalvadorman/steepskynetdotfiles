import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import GLib from "gi://GLib"
import Pango from "gi://Pango"

const HOME = GLib.get_home_dir()!
const SCRIPTS = `${HOME}/.config/eww/scripts`
const ICONS = `${HOME}/.config/eww/icons`

const clock     = createPoll("00:00", 5000,  "date '+%H:%M'")
const clockDate = createPoll("---",   60000, "date '+%a %d %b'")

const songTitle  = createPoll("Sin reproducción", 2000, `${SCRIPTS}/music --title`)
const songArtist = createPoll("",  2000, `${SCRIPTS}/music --artist`)
const songStatus = createPoll("",  2000, `${SCRIPTS}/music --status`)
const songCover  = createPoll("",  2000, `${SCRIPTS}/music --cover`)

export default function Center(props: { $type?: string }) {
  return (
    <box spacing={8} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
      {/* Clock */}
      <box class="clock-pill" spacing={6} valign={Gtk.Align.CENTER}
        tooltip-text={clockDate}>
        <label class="clock-time" label={clock} valign={Gtk.Align.CENTER} />
        <label class="clock-sep"  label="·" valign={Gtk.Align.CENTER} />
        <label class="clock-date" label={clockDate} valign={Gtk.Align.CENTER} />
      </box>

      {/* Music */}
      <box class="music-pill" spacing={10} valign={Gtk.Align.CENTER}>
        {/* Cover */}
        <box
          class="music-cover"
          valign={Gtk.Align.CENTER}
          css={songCover(p =>
            p
              ? `background-image: url('${p}'); background-size: cover; background-position: center;`
              : `background-image: url('file://${ICONS}/music-placeholder.svg'); background-size: cover; background-position: center;`
          )}
        />

        {/* Metadata */}
        <box
          class="music-text-box"
          orientation={Gtk.Orientation.VERTICAL}
         
          spacing={0}
          valign={Gtk.Align.CENTER}
          hexpand
        >
          <label class="music-title"  label={songTitle}  max-width-chars={22} ellipsize={Pango.EllipsizeMode.END} halign={Gtk.Align.START} />
          <label class="music-artist" label={songArtist(a => a || "Desconocido")} max-width-chars={18} ellipsize={Pango.EllipsizeMode.END} halign={Gtk.Align.START} />
        </box>

        {/* Controls */}
        <box class="music-controls" spacing={12} valign={Gtk.Align.CENTER} halign={Gtk.Align.END}>
          <button class="music-btn prev" tooltip-text="󰒮 Retroceder 5s"
            onClicked={() => execAsync("playerctl -p chromium position 5-")}>
            <image file={`${ICONS}/music-prev.svg`} pixel-size={14} />
          </button>

          <button
            class={songStatus(s => s === "󰏤" ? "music-btn play" : "music-btn pause")}
            tooltip-text={songStatus(s => s === "󰏤" ? "󰐊 Reproducir" : "󰏤 Pausar")}
            onClicked={() => execAsync(`${SCRIPTS}/music --toggle`)}>
            <image
              file={songStatus(s =>
                s === "󰏤"  ? `${ICONS}/music-play.svg`
                : s        ? `${ICONS}/music-pause.svg`
                           : `${ICONS}/music-play.svg`
              )}
              pixel-size={14}
            />
          </button>

          <button class="music-btn next" tooltip-text="󰒭 Avanzar 5s"
            onClicked={() => execAsync("playerctl -p chromium position 5+")}>
            <image file={`${ICONS}/music-next.svg`} pixel-size={14} />
          </button>
        </box>
      </box>
    </box>
  )
}
