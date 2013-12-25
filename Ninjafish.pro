# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = Ninjafish

CONFIG += sailfishapp

SOURCES += src/Ninjafish.cpp

OTHER_FILES += qml/Ninjafish.qml \
    qml/cover/CoverPage.qml \
    rpm/Ninjafish.spec \
    rpm/Ninjafish.yaml \
    Ninjafish.desktop \
    qml/pages/DeviceList.qml \
    qml/pages/include.js \
    qml/pages/main.js \
    qml/pages/ninja.js \
    qml/pages/OAuth.js \
    qml/pages/request.js \
    qml/pages/settings.js \
    qml/pages/sha1.js \
    qml/pages/SubDeviceList.qml \
    qml/cover/coverimage.png \
    qml/pages/OAuth.qml \
    qml/pages/DeviceListItem.qml \
    qml/pages/HiddenDeviceList.qml \
    qml/pages/FavouriteDeviceList.qml \
    qml/pages/NamedColorPicker.qml \
    qml/cover/coverimage_black.png \
    qml/cover/coverimage_white.png
