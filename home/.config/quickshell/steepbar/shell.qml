import Quickshell
import Quickshell.Io
import "./services" as Services
import "./modules/bar" as BarModule
import "./modules/notifications" as NotifModule
import "./modules/projects" as ProjectsModule
import "./modules/launcher" as LauncherModule

ShellRoot {
    Scope {
        Variants {
            model: Quickshell.screens
            delegate: BarModule.Bar {}
        }
    }

    NotifModule.Popups {}
    LauncherModule.AppLauncher {}

    IpcHandler {
        target: "bar"
        function toggle(): void { Services.BarState.toggle() }
    }

    IpcHandler {
        target: "projects"
        function toggle(): void { Services.PopupState.toggleProjects() }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void { Services.PopupState.toggleNotifCenter() }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { Services.PopupState.toggleLauncher() }
    }

    IpcHandler {
        target: "audio"
        function toggle(): void { Services.PopupState.toggleAudio() }
    }
}

