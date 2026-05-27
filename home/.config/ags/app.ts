import app from "ags/gtk4/app"
import style from "./style.scss"
import Bar from "./widgets/Bar"
import Projects from "./widgets/Projects"

app.start({
  instanceName: "steep-bar",
  css: style,
  main() {
    app.get_monitors().map(Bar)
    Projects()
  },
})
