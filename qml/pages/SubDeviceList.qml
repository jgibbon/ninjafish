import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: mainPage
    property var device: {
        'default_name': '',
                'tags':'view is empty'
    }
    property var js
    property bool authenticated: true

    SilicaListView {
        id:listView
        anchors.fill: parent
        header: PageHeader {
            title: device.shortName
            SectionHeader {
                height:Theme.itemSizeBig
                text: device.tags
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                anchors.bottom: parent.bottom

            }
        }

        //id:subdevicelist
        model: ListModel {
            id: subdevicelistmodel

        }
        delegate: DeviceListItem {

        }

    }




    Component.onCompleted: {
        if(device.has_subdevice_count){
            var subs = [],
                    subdevname = '',
                    dev = device.subDevices;
            //subdevicelistmodel.clear()
            for(subdevname in dev) {
                if(dev[subdevname].type === 'actuator') {
                    dev[subdevname].id = subdevname;
                    subdevicelistmodel.append(dev[subdevname])
                }
            }
        }
    }
}





