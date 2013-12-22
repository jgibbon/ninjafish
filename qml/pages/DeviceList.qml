import QtQuick 2.0
import Sailfish.Silica 1.0

import QtQuick.LocalStorage 2.0

import "include.js" as Js
Page {
    id: mainPage
    property bool authenticated: false
    property var js: Js
    function setAuthenticated(a) {
        authenticated = !!a;
        Js.modules.setPulley(pulldownModel);
    }
    ListModel {
        id: devicesModel
    }
    ListModel {
        id: pulldownModel
    }
    SilicaListView {
        id: listView
        anchors.fill: parent
        model: devicesModel
        PullDownMenu {

            id:optionspulley


            Repeater {
                id:pulleyrepeater
                model: pulldownModel
                MenuItem {
                    text: model.text ? model.text : ''
                    onClicked: {
                        Js.modules.callPulley(index);

                    }
                }
            }
        }
        header: PageHeader { title: "Ninjafish" }
        Row {
            width: parent.width
            visible: !authenticated
            Label {

                height: mainPage.height
                width: mainPage.width
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: 'Please log in. Pull down to do that.'

            }

        }
        delegate: DeviceListItem {}
        //VerticalScrollDecorator {}


        Component.onCompleted: {
            var access_token = Js.modules.settings.get('access_token');
            if(access_token) {
                Js.modules.auth(access_token);
            }
            //if no token exists yet, loadDevices just gets the model for later
            Js.modules.loadDevices(devicesModel);

            Js.modules.setPulley(pulldownModel);
        }
    }
}





