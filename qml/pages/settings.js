//use DB for simple key value store exposed as modules.settings

function settings(LocalStorage) {
    var db = null,
            favourites, openDB = function(LocalStorage) {
                if (db !== null) return;
                db = LocalStorage.openDatabaseSync("ninjafish", "0.1", "ninjafish", 100000);

                try {
                    db.transaction(function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(key TEXT UNIQUE, value TEXT)');
                        var table = tx.executeSql("SELECT * FROM settings");
                    });
                } catch (err) {
                    console.log("Error creating table in database: " + err);
                };
            },
    setSetting = function(k, v) {
        openDB(LocalStorage);
        db.transaction(function(tx) {
            tx.executeSql('INSERT OR REPLACE INTO settings VALUES(?, ?)', [k, v]);
        });
        //console.log('executed set for ', k, v);
    },
    getSetting = function(k) {
        var res;
        openDB(LocalStorage);

        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT value FROM settings WHERE key=?;', [k]);
            res = rs.rows.item(0) ? rs.rows.item(0).value : '';
            //console.log('executed get for ', k, res);
        });
        return res;
    },
    clearSettings = function() {
        openDB(LocalStorage);
        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM settings;');
            console.log(rs); //does not do anything but wait without log ;)
        });
    };

    var ret = {
        settings: {
            clear: function() {
                ret.favourites.clear();
                ret.hiddendevices.clear();
                clearSettings();
            },

            set: function(key, value) {
                setSetting(key, value);
            },

            get: function(key) {
                return getSetting(key);
            }

        }
    };

    //create simple wrapper for json arrays (an object with id property is required)
    var jsonWrapper = function (key){

        var str = ret.settings.get(key),
                jsonArray = str ? JSON.parse(str) : [],
                                  methods = {

                                      add: function(data) {
                                          if (!data.id) {
                                              return;
                                          }
                                          methods.remove(data, true);
                                          jsonArray.push(data);
                                          methods.set();
                                      },
                                      clear: function() {
                                          jsonArray = [];
                                          methods.set();
                                      },

                                      contains: function(data) {
                                          var len = jsonArray.length;
                                          while (len--) {

                                              if (//ninja specific: check for data.data first
                                                      ((data.id && jsonArray[len].id === data.id) && (data.data && jsonArray[len].data === data.data))
                                                      //ninja specific: check shortName
                                                      || ((data.id && jsonArray[len].id === data.id) && (data.shortName && jsonArray[len].shortName === data.shortName))
                                                      //convenience: check uniqueid
                                                      || (data.uniqueid && jsonArray[len].uniqueid === data.uniqueid)
                                                      //check whole thing
                                                      || (JSON.stringify(jsonArray[len]) === JSON.stringify(data))) {
                                                          return len;
                                                      }
                                          }
                                          return -1;
                                      },

                                      get: function(item) {
                                          if(!item) {
                                            return jsonArray;
                                          }
                                          var search = methods.contains(item);
                                          if(search!== -1) {
                                            return jsonArray[search];
                                          }
                                      },
                                      remove: function(data, dontsave) {
                                          var index = methods.contains(data);
                                          if(index === -1) { return; }

                                          jsonArray.splice(index, 1);
                                          if(!dontsave) {
                                              methods.set();
                                          }
                                          return true;
                                      },
                                      set: function(data) {//overwrite or save
                                          jsonArray = data || jsonArray;
                                          ret.settings.set(key, JSON.stringify(jsonArray));
                                          return data;
                                      },
                                      toggle: function(data) {//add or remove
                                            var isadded = methods.contains(data) === -1;
                                          ((isadded ? methods.add : methods.remove)(data));
                                          return isadded;

                                      }

                                  };
        return methods;
    };

    ret.favourites = jsonWrapper('favourites');
    ret.hiddendevices = jsonWrapper('hiddendevices');

    return ret;

}
