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
                text: 'Clear Favourites'
                onClicked: {
                    js.modules.favourites.clear();
                    favouritedevicelistmodel.clear();

                    js.modules.loadDevices();
                    js.modules.setPulley();

                }
            }

        }

        header: PageHeader {
            title: 'Favourites'
        }

        model: ListModel {
            id: favouritedevicelistmodel

        }
        delegate: DeviceListItem {
            visible: isfavourite
            property bool isfavourite: true
        }

    }




    Component.onCompleted: {
        var dev = js.modules.favourites.get(),
            subdevname;

        for( subdevname in dev) {

                favouritedevicelistmodel.append(dev[subdevname]);
            }
        }
}





