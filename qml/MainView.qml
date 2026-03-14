import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 800
    height: 600

    // TODO: Build your QML UI here.
    //
    // The C++ backend is available as "yourModule" (set via setContextProperty).
    // Call Q_INVOKABLE methods directly:
    //   var result = yourModule.hello()
    //
    // For complex data, methods return JSON strings — parse with JSON.parse():
    //   var items = JSON.parse(yourModule.listItems())

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        Text {
            text: "YourModule UI Plugin"
            font.pixelSize: 24
            font.bold: true
            color: "#212121"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: yourModule ? yourModule.hello() : "Loading..."
            font.pixelSize: 16
            color: "#757575"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "Edit qml/MainView.qml to build your UI"
            font.pixelSize: 14
            color: "#9e9e9e"
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
