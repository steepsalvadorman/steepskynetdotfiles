import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../services" as Services

PanelWindow {
    id: launcher
    WlrLayershell.namespace: "quickshell:popups"
    exclusiveZone: 0
    color: "transparent"
    implicitWidth: 640
    implicitHeight: 520
    visible: Services.PopupState.launcherVisible || closingTimer.running

    focusable: true

    property var allApps: []
    property var filteredApps: []
    property string searchQuery: ""
    property int currentIndex: 0
    property int columns: 4

    property string activeCategory: "all"
    property var categoriesList: [
        { label: "Todo", id: "all", icon: "󰀻" },
        { label: "Internet", id: "network", icon: "󰖩" },
        { label: "Desarrollo", id: "development", icon: "󰘦" },
        { label: "Juegos", id: "game", icon: "󰊗" },
        { label: "Sistema", id: "system", icon: "󰓅" }
    ]

    Timer {
        id: closingTimer
        interval: 200
        running: false
    }

    Connections {
        target: Services.PopupState
        function onLauncherVisibleChanged() {
            if (!Services.PopupState.launcherVisible) {
                closingTimer.restart();
            }
        }
    }

    // Run the app indexer when the launcher becomes visible
    onVisibleChanged: {
        if (visible) {
            appsProc.running = true;
            searchInput.text = "";
            searchQuery = "";
            activeCategory = "all";
            currentIndex = 0;
            searchInput.forceActiveFocus();
        }
    }

    Process {
        id: appsProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/steepbar/scripts/get_apps.py"]
        stdout: StdioCollector { id: appsOut }
        onExited: {
            try {
                launcher.allApps = JSON.parse(appsOut.text);
                launcher.filterApps();
            } catch(e) {
                console.log("Error parsing apps list:", e);
            }
        }
    }

    function filterApps() {
        var query = searchQuery.toLowerCase();
        filteredApps = allApps.filter(function(app) {
            // Category filter check
            var matchesCategory = activeCategory === "all" || (app.categories && app.categories.includes(activeCategory));
            if (!matchesCategory) return false;

            if (query === "") return true;
            return app.name.toLowerCase().includes(query) || 
                   (app.comment && app.comment.toLowerCase().includes(query)) ||
                   app.exec.toLowerCase().includes(query);
        });
        // Clamp current index
        if (currentIndex >= filteredApps.length) {
            currentIndex = Math.max(0, filteredApps.length - 1);
        }
    }

    function moveCurrentIndex(delta) {
        var next = currentIndex + delta;
        if (next >= 0 && next < filteredApps.length) {
            currentIndex = next;
            // Ensure the selected item is visible (scroll grid if necessary)
            var row = Math.floor(currentIndex / columns);
            gridFlickable.ensureVisible(row);
        }
    }

    function launchSelected() {
        if (filteredApps.length > 0 && currentIndex >= 0 && currentIndex < filteredApps.length) {
            var execCmd = filteredApps[currentIndex].exec;
            Quickshell.execDetached(["bash", "-c", execCmd]);
            Services.PopupState.launcherVisible = false;
        }
    }

    // Outer Drop Shadow Simulation (Skeuomorphic Glow & Depth)
    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        radius: 24
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 1.0; color: Services.Colors.cardBg }
        }
        border.width: 1
        border.color: Services.Colors.glassBorder

        scale: Services.PopupState.launcherVisible ? 1.0 : 0.95
        opacity: Services.PopupState.launcherVisible ? 1.0 : 0.0
        transform: Scale { origin.x: width / 2; origin.y: height / 2 }

        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 180 } }

        // Skeuomorphic glossy reflection overlay
        Rectangle {
            anchors.fill: parent
            radius: 24
            clip: true
            color: "transparent"

            // Diagonal glossy reflection
            Rectangle {
                width: parent.width * 1.5
                height: 180
                rotation: -15
                x: -50
                y: -100
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.25) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
                }
            }
        }

        // Inner Bevel Highlight (Skeuomorphic Relief)
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 23
            color: "transparent"
            border.width: 1.5
            border.color: Services.Colors.innerBevel // Crisp highlight edge
        }

        // Main Content Layout
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // Header: Recessed Skeuomorphic Search Bar
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 14
                // Concave recessed gradient (darker at top, pure white at bottom)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.darker(Services.Colors.cardBg, 1.08) }
                    GradientStop { position: 1.0; color: "#ffffff" }
                }
                border.width: 1
                border.color: Services.Colors.glassBorder

                // Inner top shadow line for recessed depth
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 2.5
                    radius: 14
                    color: Qt.rgba(0.05, 0.1, 0.2, 0.08)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 10

                    Text {
                        text: "󰍉"
                        font.pixelSize: 18
                        color: Services.Colors.subtext
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        font.family: Services.Colors.uiFont
                        font.pixelSize: 14
                        color: Services.Colors.fg
                        selectByMouse: true

                        Text {
                            text: "Buscar aplicación..."
                            font: parent.font
                            color: Services.Colors.subtext
                            visible: parent.text.length === 0
                        }

                        onTextChanged: {
                            launcher.searchQuery = text;
                            launcher.currentIndex = 0;
                            launcher.filterApps();
                        }

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Down) {
                                event.accepted = true;
                                launcher.moveCurrentIndex(launcher.columns);
                            } else if (event.key === Qt.Key_Up) {
                                event.accepted = true;
                                launcher.moveCurrentIndex(-launcher.columns);
                            } else if (event.key === Qt.Key_Left) {
                                event.accepted = true;
                                launcher.moveCurrentIndex(-1);
                            } else if (event.key === Qt.Key_Right) {
                                event.accepted = true;
                                launcher.moveCurrentIndex(1);
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                event.accepted = true;
                                launcher.launchSelected();
                            } else if (event.key === Qt.Key_Escape) {
                                event.accepted = true;
                                Services.PopupState.launcherVisible = false;
                            }
                        }
                    }
                }
            }

            // Category Filter Tabs Bar (Aero Glass Style)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Layout.topMargin: 4
                Layout.bottomMargin: 4

                Repeater {
                    model: launcher.categoriesList
                    delegate: Item {
                        id: catDelegate
                        implicitWidth: catRow.implicitWidth + 24
                        implicitHeight: 28

                        readonly property bool isActive: launcher.activeCategory === modelData.id
                        property bool hovered: false

                        HoverHandler { onHoveredChanged: catDelegate.hovered = hovered }
                        TapHandler {
                            onTapped: {
                                launcher.activeCategory = modelData.id;
                                launcher.currentIndex = 0;
                                launcher.filterApps();
                            }
                        }

                        // Tab glass background
                        Rectangle {
                            anchors.fill: parent
                            radius: 14
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: catDelegate.isActive ? "#ffffff" : catDelegate.hovered ? Qt.rgba(1,1,1,0.5) : "transparent" }
                                GradientStop { position: 1.0; color: catDelegate.isActive ? Services.Colors.cardBg : catDelegate.hovered ? Qt.rgba(255,255,255,0.15) : "transparent" }
                            }
                            border.width: (catDelegate.isActive || catDelegate.hovered) ? 1 : 0
                            border.color: catDelegate.isActive ? Services.Colors.accent2 : Qt.rgba(255,255,255,0.4)
                            Behavior on border.width { NumberAnimation { duration: 100 } }

                            // Glossy Reflection overlay (curved upper shine)
                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                clip: true
                                color: "transparent"
                                visible: catDelegate.isActive || catDelegate.hovered
                                Rectangle {
                                    width: parent.width * 1.5
                                    height: parent.height / 1.8
                                    rotation: -3
                                    x: -5
                                    y: -2
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.40) }
                                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
                                    }
                                }
                            }

                            // LED glow line under active tab
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: catDelegate.isActive ? 24 : 0
                                height: 2
                                radius: 1
                                color: Services.Colors.accent2
                                Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            }
                        }

                        RowLayout {
                            id: catRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: modelData.icon
                                font.pixelSize: 13
                                color: catDelegate.isActive ? Services.Colors.accent : Services.Colors.fg
                            }

                            Text {
                                text: modelData.label
                                font.family: Services.Colors.uiFont
                                font.pixelSize: 11
                                font.weight: catDelegate.isActive ? Font.Bold : Font.Medium
                                color: catDelegate.isActive ? Services.Colors.fg : Services.Colors.subtext
                            }
                        }
                    }
                }
            }

            // Body: Apps Grid View with Scroll
            Flickable {
                id: gridFlickable
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: appsGrid.implicitHeight
                clip: true

                function ensureVisible(row) {
                    var itemHeight = 110;
                    var viewHeight = height;
                    var targetY = row * itemHeight;
                    if (targetY < contentY) {
                        contentY = targetY;
                    } else if (targetY + itemHeight > contentY + viewHeight) {
                        contentY = targetY + itemHeight - viewHeight;
                    }
                }

                GridLayout {
                    id: appsGrid
                    width: parent.width
                    columns: launcher.columns
                    columnSpacing: 16
                    rowSpacing: 16

                    Repeater {
                        model: launcher.filteredApps

                        delegate: Item {
                            id: appItem
                            implicitWidth: (appsGrid.width - (launcher.columns - 1) * appsGrid.columnSpacing) / launcher.columns
                            implicitHeight: 96

                            readonly property bool isCurrent: launcher.currentIndex === index
                            property bool hovered: false

                            HoverHandler {
                                onHoveredChanged: appItem.hovered = hovered
                            }

                            TapHandler {
                                onTapped: {
                                    launcher.currentIndex = index;
                                    launcher.launchSelected();
                                }
                            }

                            // 3D Shadow Layer for Skeuomorphic Button
                            Rectangle {
                                anchors.fill: parent
                                anchors.topMargin: (appItem.isCurrent || appItem.hovered) ? 3 : 2
                                radius: 16
                                color: "transparent"
                                border.width: 1
                                border.color: Qt.rgba(0.08, 0.15, 0.27, 0.12)
                            }

                            // Skeuomorphic Button Base
                            Rectangle {
                                anchors.fill: parent
                                anchors.bottomMargin: (appItem.isCurrent || appItem.hovered) ? 1 : 3
                                anchors.topMargin: (appItem.isCurrent || appItem.hovered) ? 2 : 0
                                radius: 16
                                scale: (appItem.isCurrent || appItem.hovered) ? 1.03 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                                // Raised linear gradient
                                gradient: Gradient {
                                    GradientStop { 
                                        position: 0.0 
                                        color: appItem.isCurrent ? Qt.rgba(Services.Colors.accent.r, Services.Colors.accent.g, Services.Colors.accent.b, 0.08) : appItem.hovered ? Qt.rgba(Services.Colors.accent.r, Services.Colors.accent.g, Services.Colors.accent.b, 0.08) : "#ffffff" 
                                    }
                                    GradientStop { 
                                        position: 1.0 
                                        color: appItem.isCurrent ? Qt.rgba(Services.Colors.accent.r, Services.Colors.accent.g, Services.Colors.accent.b, 0.08) : appItem.hovered ? Qt.rgba(Services.Colors.accent.r, Services.Colors.accent.g, Services.Colors.accent.b, 0.08) : Services.Colors.cardBg 
                                    }
                                }
                                border.width: 1
                                border.color: (appItem.isCurrent || appItem.hovered) ? Services.Colors.accent2 : Services.Colors.glassBorder

                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                // Soft backlighting glow on hover/active
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 16
                                    color: "transparent"
                                    border.width: 1.5
                                    border.color: (appItem.isCurrent || appItem.hovered) ? Services.Colors.accent2 : "transparent"
                                    opacity: (appItem.isCurrent || appItem.hovered) ? 0.8 : 0.0
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }

                                // Inner highlights
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    radius: 15
                                    color: "transparent"
                                    border.width: 1
                                    border.color: Services.Colors.innerBevel
                                }

                                // Glossy overlay reflection on button
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 15
                                    clip: true
                                    color: "transparent"
                                    Rectangle {
                                        width: parent.width * 1.5
                                        height: 40
                                        rotation: -10
                                        x: -10
                                        y: -20
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.35) }
                                            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
                                        }
                                    }
                                }

                                // Interactive Glowing LED strip at the bottom
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: (appItem.isCurrent || appItem.hovered) ? 36 : 0
                                    height: 3
                                    radius: 1.5
                                    color: Services.Colors.accent2
                                    Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                                }

                                // Soft backlight glow bubble behind the app icon
                                Rectangle {
                                    anchors.centerIn: appIcon
                                    width: 48
                                    height: 48
                                    radius: 24
                                    color: Services.Colors.accent2
                                    opacity: (appItem.isCurrent || appItem.hovered) ? 0.15 : 0.0
                                    scale: (appItem.isCurrent || appItem.hovered) ? 1.0 : 0.7
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 4

                                    // Application Icon
                                    Image {
                                        id: appIcon
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        source: Quickshell.iconPath(modelData.icon) || Quickshell.iconPath("system-run")
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    // Application Name
                                    Text {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.name
                                        font.family: Services.Colors.uiFont
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: appItem.isCurrent ? Services.Colors.fg : Services.Colors.subtext
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Footer: Skeuomorphic status & hints
            RowLayout {
                Layout.fillWidth: true
                height: 24

                Text {
                    text: searchQuery.length > 0 ? "Resultados: " + launcher.filteredApps.length : "Busca entre tus aplicaciones"
                    font.family: Services.Colors.uiFont
                    font.pixelSize: 10
                    color: Services.Colors.subtext
                }

                Item { Layout.fillWidth: true }

                // Small shortcut buttons (pill relief)
                Rectangle {
                    implicitWidth: 100
                    implicitHeight: 18
                    radius: 999
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#ffffff" }
                        GradientStop { position: 1.0; color: Services.Colors.cardBg }
                    }
                    border.width: 1
                    border.color: Services.Colors.glassBorder

                    Text {
                        anchors.centerIn: parent
                        text: "ESC para cerrar"
                        font.family: Services.Colors.uiFont
                        font.pixelSize: 9
                        font.bold: true
                        color: Services.Colors.subtext
                    }
                }

                Rectangle {
                    implicitWidth: 100
                    implicitHeight: 18
                    radius: 999
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#ffffff" }
                        GradientStop { position: 1.0; color: Services.Colors.cardBg }
                    }
                    border.width: 1
                    border.color: Services.Colors.glassBorder

                    Text {
                        anchors.centerIn: parent
                        text: "ENTER para abrir"
                        font.family: Services.Colors.uiFont
                        font.pixelSize: 9
                        font.bold: true
                        color: Services.Colors.subtext
                    }
                }
            }
        }
    }
}
