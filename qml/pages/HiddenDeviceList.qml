import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: mainPage
    property var device: {
        'default_name': '',
    }
    property var js
    property bool authenticated: true

    SilicaListView {
        id:listView
        anchors.fill: parent


        PullDownMenu {

            id:optionspulley
            MenuItem {
                text: 'Un-Hide all'
                onClicked: {
                    js.modules.hiddendevices.clear();
                    hiddendevicelistmodel.clear();
                    js.modules.loadDevices();
                    PageStack.pop();
                }
            }

        }

        header: PageHeader {
            title: 'Hidden Devices'
        }

        model: ListModel {
            id: hiddendevicelistmodel

        }
        delegate: DeviceListItem {
            visible: isHidden
        }

    }




    Component.onCompleted: {
        var dev = js.modules.hiddendevices.get(),
            subdevname;
        for( subdevname in dev) {
                hiddendevicelistmodel.append(dev[subdevname]);
            }
        }
}





