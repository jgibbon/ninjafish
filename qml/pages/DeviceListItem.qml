import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
            id: devicelistitem
            visible: authenticated && !isHidden
            width: listView.width
            height: visible && devicelistitem.menuOpened ? menurowbackground.height + devicerow.height : devicerow.height

            RemorseItem {
				id: remorse
            }
            property bool menuOpened: false
            property bool isHidden: false


            property bool iscolor: ((model.device_type === 'rgbled' || model.device_type === 'rgbled8') && model.last_data.DA )
            property bool istemperature: model.device_type === 'temperature'
            property bool ishumidity: model.device_type === 'humidity'
            property bool isfavourite: mainPage.js.modules.favourites.contains({uniqueid:model.id+model.shortName}) !== -1

            BackgroundItem {
                id:devicerowbackground
                onClicked: {

                    devicelistitem.menuOpened = false;
                    if(model.has_subdevice_count) {
                        pageStack.push(Qt.resolvedUrl("SubDeviceList.qml"), {device:model, js:mainPage.js});
                        return;
                    }
                    if(model.device_type === 'rgbled' || model.device_type === 'rgbled8') {

                        mainPage.js.modules.getColorUi(model.shortName, function(color){
                            rgbindicator.color = color;
                            mainPage.js.modules.actuate(model.id, (color + '').replace('#', ''));
                        }, model.device_type);
                    } else if(model.type === 'actuator' && model.data && mainPage.device){//this happens on subdevice pages
                        mainPage.js.modules.actuate(mainPage.device.id, model.data);
                    }
                }
                onPressAndHold: { //toggle menu
                    devicelistitem.menuOpened = !devicelistitem.menuOpened
                }
                Row {
                    height: devicelistitem.visible ? Theme.itemSizeSmall:0
                    id:devicerow
                    width: listView.width
                    Label { width: Theme.paddingSmall }//there has to be a better way
                    Label {
                        text: model.shortName ? model.shortName : model.default_name
                        color: isfavourite ? Theme.highlightColor : Theme.primaryColor
                        //color: devicerowbackground.highlighted ? Theme.highlightColor : Theme.primaryColor
                        anchors.verticalCenter: parent.verticalCenter
                        //anchors.left: parent.left
                        width: mainPage.width - Theme.itemSizeSmall - Theme.paddingLarge
                    }

                    //for rgb device
                    GlassItem {
                        id: rgbindicator
                        color: devicelistitem.iscolor && model.last_data ? '#'+model.last_data.DA : 'transparent';
                        anchors.verticalCenter: parent.verticalCenter
                        //anchors.right: parent.right
                        cache: false
                        visible: devicelistitem.iscolor

                    }

                    //for temperature/humidity
                    Label {
                        id: temperatureindicator
                        width:Theme.itemSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.secondaryColor
                        visible: devicelistitem.istemperature || devicelistitem.ishumidity
                        text: model.last_data? model.last_data.DA + (devicelistitem.istemperature? ('°' + model.unit[0].toUpperCase()):'')+ ' ':''

                        horizontalAlignment: Text.AlignRight
                    }


                    //                GlassItem {
                    //                    property bool hassubdevicecount: (model.has_subdevice_count > 0 )
                    //                    color: Theme.primaryColor
                    //                    falloffRadius: 0.04
                    //                    radius: 0.01
                    //                    cache: false
                    //                    visible: hassubdevicecount
                    //                }
                }

            }
            BackgroundItem {
                onClicked: {
                    devicelistitem.menuOpened = false
                }
                id:menurowbackground
                anchors.top: devicerowbackground.bottom
                height: menurow.height * 1.2
                visible: devicelistitem.menuOpened
                Rectangle {
                         id: rectangle
                         color: '#000000'
                         border.color: "white"
                         anchors.fill: parent
                         opacity: 0.1
                }
                Row {
                    id:menurow
                    width: listView.width
                    Switch {
                        visible: devicelistitem.iscolor || model.category == "rf" || devicelistitem.isfavourite//later on just use the same list for sub pages
                        GlassItem {
                            visible: iscolor && isfavourite
                            color: iscolor && isfavourite ? '#'+mainPage.js.modules.favourites.get({uniqueid:model.id+model.shortName}).data :  Theme.primaryColor
                        }
                        Component.onCompleted: { //read favourite state
                            checked = devicelistitem.isfavourite;
                        }
                        onClicked: {
                            if(checked && iscolor) {
                                mainPage.js.modules.getColorUi(model.shortName, function(color){
                                    mainPage.js.modules.favourites.add({uniqueid:model.id+model.shortName,id:model.id,shortName:model.shortName+' '+color,data:(color + '').replace('#', '')});
                                   devicelistitem.isfavourite = true;

                                    mainPage.js.modules.setPulley();
                                }, model.device_type);

                            } else if(checked && model.data) { //subpage
                                mainPage.js.modules.favourites.add({uniqueid:model.id+model.shortName,id:device.id,shortName:model.shortName,data:model.data});
                                devicelistitem.isfavourite = checked;
                            } else if(!checked && model.data) {  //favourite view
                                mainPage.js.modules.favourites.remove({id:model.id, data:model.data});
                                devicelistitem.isfavourite = checked;
                            } else {
                                //nothing useful to do for the other ones i know
                                checked = false;

                                devicelistitem.isfavourite = checked;
                                mainPage.js.modules.favourites.remove({uniqueid:model.id+model.shortName});
                                //Js.modules.favourites.toggle({id:model.id,shortName:model.shortName});
                            }
                            mainPage.js.modules.setPulley();

                            devicelistitem.menuOpened = false
                        }

                        icon.width: Theme.iconSizeSmall
                        icon.height: Theme.iconSizeSmall
                        icon.source: checked?"image://theme/icon-m-favorite-selected":"image://theme/icon-m-favorite"
//                        Text {
//                            color: Theme.primaryColor
//                            text: iscolor && isfavourite ? mainPage.js.modules.favourites.get({uniqueid:model.id+model.shortName+model.data}).data :  '' //'favourite'
//                            font.pixelSize: Theme.fontSizeTiny
//                            width: parent.width
//                            horizontalAlignment: Text.AlignHCenter
//                        }
                    }
                    Switch {
                        Component.onCompleted: { //read hidden state
                            checked = devicelistitem.isHidden;
                        }
                        onClicked: {
                            checked = !checked;
                            remorse.execute(devicelistitem, (checked?"Un-hiding ":"Hiding ")+"'"+model.shortName+"'", function() {
                                checked = devicelistitem.isHidden = mainPage.js.modules.hiddendevices.toggle({id:model.id,shortName:model.shortName});
                                js.modules.loadDevices();
                            }, 2000);
                        }
                        icon.width: Theme.iconSizeSmall
                        icon.height: Theme.iconSizeSmall
                        icon.source: "image://theme/icon-m-dismiss"

//                        Text {
//                            color: Theme.primaryColor
//                            text: 'hidden'
//                            font.pixelSize: Theme.fontSizeTiny
//                            width: parent.width
//                            horizontalAlignment: Text.AlignHCenter
//                        }
                    }
//                    Label {
//                        text: 'yo'+model.shortName;

//                        horizontalAlignment: Text.AlignRight
//                    }
                }
            }

            Component.onCompleted: {

                isHidden = mainPage.js.modules.hiddendevices.contains({id:model.id,shortName:model.shortName}) !== -1
            }

        }
