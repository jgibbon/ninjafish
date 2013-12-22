/****************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the QtDeclarative module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions
** contained in the Technology Preview License Agreement accompanying
** this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights.  These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
**
**
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/
import QtQuick 2.0
import Sailfish.Silica 1.0
import "request.js" as OAuthLogic

Page{
    id: mainPage
    function beginAuthentication(){
        step = 1;
        stepOne();
    }
    property var js
    signal authenticationCompleted;
    property bool authorized: false
    SilicaWebView{
        id: webItem
        //url: "about:blank"
        onNavigationRequested: {
            //this url is hard coded.
            console.log('vav rq', request.url);
            var code = (/https:\/\/velox.duckdns.org\/ninja\?code=([^&]*)&expires_in=([^&]*)&scope=(.*)/).exec(request.url)
            if(code !== null){

                var opts = {
                    url:'https://api.ninja.is/oauth/access_token',
                    method: 'POST',
                    json:true,
                    body: {
                        client_id:   82630,
                        client_secret: 'iYAHxEGJO3z/ksPvONgpQhwV/UxEcXGpYaUzh05ySMU=',
                        code: code[1],
                        grant_type: 'authorization_code'
                    }
                };
                OAuthLogic.request(opts, function(e, r, b) {
                    if(e){}

                    console.log('access_token ', e,r, JSON.stringify(b));
                    if(b.access_token){
                        console.log('TOKEN HERE', b.access_token);
                        js.modules.settings.set('access_token',  b.access_token);



                        var Js = js;






                        Js.modules.auth(b.access_token);
                        Js.modules.loadDevices();
                        pageStack.pop();
                    }
                });
            }



        }
        anchors.fill: parent;
        Component.onCompleted: {
            console.log('completed');

            webItem.url = "https://api.ninja.is/oauth/authorize?client_id=82630&redirect_uri=https://velox.duckdns.org/ninja&scope=all&response_type=code";
            console.log('completed');

            //beginAuthentication()
        }
    }
}
