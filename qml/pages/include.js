var modules = {};

(function() {
	Qt.include("settings.js")
    var st = settings(LocalStorage),
            cached_model,//device model
            pulley_model,
            pulley_callbacks;
    modules.settings = st.settings;
    modules.favourites = st.favourites;
    modules.hiddendevices = st.hiddendevices;

    modules.setPulley = function(model){
        var favourites,
            favcount,
            p = function(o){
                pulley_callbacks.push(o.click);
                model.append(o)
            };
        if(model) {
            pulley_model = model;
        }
        else {
            model = pulley_model;
        }
        pulley_callbacks = [];
        model.clear();

        if(mainPage.authenticated) {

            p({text:"Clear Everything", click:function(){ modules.settings.clear(); modules.auth();  }});
            p({text:'Log out', click:function(){ modules.auth(); }});

            //p({text:'Clear Favourites', click:function(){ modules.favourites.clear();modules.setPulley();  }});

            p({text:'Hidden Devices', click:function(){
                pageStack.push(Qt.resolvedUrl("HiddenDeviceList.qml"), {js:mainPage.js});
            }});


            p({text:'Favourites', click:function(){
                pageStack.push(Qt.resolvedUrl("FavouriteDeviceList.qml"), {js:mainPage.js});
            }});
            p({text:'Refresh Devices', click:function(){ modules.loadDevices(); }});
            //p({text:'Clear Hidden Devices', click:function(){ modules.hiddendevices.clear();modules.loadDevices();  }});
            //p({text:'Clear Hidden Devices', click:function(){ modules.hiddendevices.clear();modules.loadDevices();  }});


            //favourites
            favourites = modules.favourites.get();
            favcount = favourites.length;
            while(favcount--) {
                p({
                      text:favourites[favcount].shortName,
                      click:function(favcount){
                          return function(){
                              //console.log('yo, click', favcount, ' ', JSON.stringify(favourites[favcount]))
                              modules.actuate(favourites[favcount].id, favourites[favcount].data);
                              //

                              modules.loadDevices();
                          };
                      }(favcount)
                  });
            }

        } else {
            p({text:'Log in', click:function(){pageStack.push(Qt.resolvedUrl("OAuth.qml"), {js: {modules:modules}})}});
        }




    }
    modules.callPulley = function(index){ //callback access from model does not work, so we call them manually.
        pulley_callbacks[index]();
    }









	Qt.include("ninja.js")
    modules.auth = function(token) {
        if(!token) {
            console.log('yo. unauth.');
            mainPage.setAuthenticated(false);
            if(cached_model){
                cached_model.clear();
            }
            modules.settings.set('access_token',  '');
            return;
        }
		modules.ninja = ninja({
            access_token: token
        });
        mainPage.setAuthenticated(true);
	}

	modules.actuate = function(id, options) {
        modules.ninja.device(id).actuate(options, function(err, n) {
            if(err !== null) {console.log('error actuate device ' + id + ' with ' + options + ', Error: ', JSON.stringify(err));}
            else {console.log('success actuate device ' + id + ' with ' + options);}
		});
    };
    modules.loadDevices = function(model) {
        if(model){cached_model = model;}
        if(cached_model && mainPage.authenticated) {

            modules.ninja.devices(function(err, devices) {
                var deviceid,
                    device;
                cached_model.clear();

                for (deviceid in devices) {
                    device = devices[deviceid];
                    device.id = deviceid;
                    cached_model.append(device);
                }
            });
        }

	}



    //convenience
    modules.getColorUi = function (name, callback, colors) {
        if(colors === 'rgbled8'){
            colors = [
                '#000000','#FFFFFF','#FF0000','#00FF00','#0000FF','#FFFF00','#00FFFF','#FF00FF'
            ];
        } else if (colors === 'rgbled' || !colors || !colors.length){
            colors = [
                        '#000000','#FFFFFF','#FF0000','#00FF00','#0000FF','#FFFF00','#00FFFF','#FF00FF','#C0C0C0','#808080','#800000','#808000','#008000','#800080','#008080','#000080',
                        '#800000','#8B0000','#A52A2A','#B22222','#DC143C','#FF0000','#FF6347','#FF7F50','#CD5C5C','#F08080','#E9967A','#FA8072','#FFA07A','#FF4500','#FF8C00','#FFA500','#FFD700','#B8860B','#DAA520','#EEE8AA','#BDB76B','#F0E68C','#808000','#FFFF00','#9ACD32','#556B2F','#6B8E23','#7CFC00','#7FFF00','#ADFF2F','#006400','#008000','#228B22','#00FF00','#32CD32','#90EE90','#98FB98','#8FBC8F','#00FA9A','#00FF7F','#2E8B57','#66CDAA','#3CB371','#20B2AA','#2F4F4F','#008080','#008B8B','#00FFFF','#00FFFF','#E0FFFF','#00CED1','#40E0D0','#48D1CC','#AFEEEE','#7FFFD4','#B0E0E6','#5F9EA0','#4682B4','#6495ED','#00BFFF','#1E90FF','#ADD8E6','#87CEEB','#87CEFA','#191970','#000080','#00008B','#0000CD','#0000FF','#4169E1','#8A2BE2','#4B0082','#483D8B','#6A5ACD','#7B68EE','#9370DB','#8B008B','#9400D3','#9932CC','#BA55D3','#800080','#D8BFD8','#DDA0DD','#EE82EE','#FF00FF','#DA70D6','#C71585','#DB7093','#FF1493','#FF69B4','#FFB6C1','#FFC0CB','#FAEBD7','#F5F5DC','#FFE4C4','#FFEBCD','#F5DEB3','#FFF8DC','#FFFACD','#FAFAD2','#FFFFE0','#8B4513','#A0522D','#D2691E','#CD853F','#F4A460','#DEB887','#D2B48C','#BC8F8F','#FFE4B5','#FFDEAD','#FFDAB9','#FFE4E1','#FFF0F5','#FAF0E6','#FDF5E6','#FFEFD5','#FFF5EE','#F5FFFA','#708090','#778899','#B0C4DE','#E6E6FA','#FFFAF0','#F0F8FF','#F8F8FF','#F0FFF0','#FFFFF0','#F0FFFF','#FFFAFA','#000000','#696969','#808080','#A9A9A9','#C0C0C0','#D3D3D3','#DCDCDC','#F5F5F5','#FFFFFF'
            ];
        }
            var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog",{"name": name});
            dialog.colors = colors;
            dialog.accepted.connect(function() {
                callback(dialog.color);
            });
            return;
    }
}());
