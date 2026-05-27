import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import Left from "./Left"
import Center from "./Center"
import Right from "./Right"

const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

export default function Bar(monitor: Gdk.Monitor) {
  return (
    <window
      name="bar"
      application={app}
      gdkmonitor={monitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      layer={Astal.Layer.TOP}
      marginTop={4}
      marginLeft={13}
      marginRight={13}
      visible={true}
    >
      <centerbox class="bar">
        <Left $type="start" />
        <Center $type="center" />
        <Right $type="end" />
      </centerbox>
    </window>
  )
}
