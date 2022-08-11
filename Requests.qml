pragma Singleton
import QtQuick 2.12
import ArcGIS.AppFramework 1.0

Item {
    QtObject {
        id: internal
        property int requestSequence: 0
    }

    // url
    // A string representing the URL to send the request to.
    //
    // options
    // A dictionary containing additional properties.
    //
    //   options.method
    //   The HTTP request method to use such as "GET", "POST", "PUT", "DELETE" (default: "GET")
    //
    //   options.responseType
    //   A string which specifies what type of data the response contains.
    //
    //   "" An empty responseType string is the same as "text", the default type.
    //   "json" The response is a JavaScript object created by parsing the contains of the received data as JSON.
    //   "text" The response is a text string.
    //
    //   options.user
    //   The user used for authentication.
    //
    //   options.password
    //   The password used for authentication.
    //
    //   options.realm
    //   The realm used for authentication.
    //
    //   options.ignoreSslErrors
    //   Can be used to indicate the errors are not fatal and that the connection should proceed. (default: false)
    //
    //   options.body
    //   If body is a dictionary it will be used to encode query parameters (GET) or encode form data (POST) as per application/x-www-form-urlencoded or multipart/form-data.
    //   File attachments can be used if their values are prefixed with the uploadPrefix
    //   e.g. { "file": "@picture1.jpg" }
    //
    //   options.uploadPrefix
    //   Indicates the string prefix in options.body for uploading attachments. (default: "@")
    //
    //   options.responsePath
    //   If set, indicates that instead of providing the responses in the response property to download it to an external file.
    //
    //   options.headers
    //   This is a JavaScript optional that define HTTP headers for the request, e.g. "Content-Type".
    //
    //   options.timeout
    //   This indicates whether the network request will be automatically aborted if a threshold time limit is reached.
    //   The units is milliseconds.

    function request(url, options) {
        return new Promise(function (resolve, reject) {
            let _parent = options["parent"] || null;
            let networkRequest = networkRequestComponent.createObject(
                    _parent,
                    { url, options, resolve, reject } );
            networkRequest.run();
        } );
    }

    Component {
        id: networkRequestComponent

        NetworkRequest {
            id: _networkRequest
            property int id: 0
            property var options: null
            property var resolve: null
            property var reject: null
            property var responseJson: null

            onReadyStateChanged: {
                if (readyState !== NetworkRequest.ReadyStateComplete) {
                    return;
                }

                if (errorCode !== 0) {
                    reject(new Error(qsTr("Network Error %1: %2").arg(errorCode).arg(errorText)));
                    Qt.callLater(destroy);
                    return;
                }

                if (status !== 200) {
                    reject(new Error(qsTr("Http Status %1: %2").arg(status).arg(statusText)));
                    Qt.callLater(destroy);
                    return;
                }

                responseJson = null;
                try {
                    responseJson = JSON.parse(responseText);
                } catch (err) {
                    reject(err);
                    Qt.callLater(destroy);
                    return;
                }

                if (responseJson["error"]) {
                    let error = responseJson["error"];
                    if (error["code"] && error["messageCode"] && error["message"]) {
                        reject(new Error(qsTr("Portal Error %1: %2: %3").arg(error["code"]).arg(error["messageCode"]).arg(error["message"])));
                        Qt.callLater(destroy);
                        return;
                    }
                    if (error["code"] && error["message"]) {
                        reject(new Error(qsTr("Portal Error %1: %2").arg(error["code"]).arg(error["message"])));
                        Qt.callLater(destroy);
                        return;
                    }
                }

                let obj = {
                    method: method,
                    url: url,
                    options: options,
                    response: responseJson,
                    responseText: responseText;
                };

                resolve(obj);

                Qt.callLater(destroy);
            }

            function init() {
                id = ++internal.requestSequence;

                let keys = [
                        "method",
                        "url",
                        "timeout",
                        "user", "password", "realm",
                        "uploadPrefix",
                        "responseType",
                        "responsePath",
                        "ignoreSslErrors",
                        "followRedirects"
                    ];
                for (let key of keys) {
                    if (key in options) {
                        _networkRequest[key] = options[key];
                    }
                }

                if (options["headers"]) {
                    headers.json = options["headers"];
                }
            }

            function run() {
                init();

                if (options["body"]) {
                    send(options["body"]);
                } else {
                    send();
                }
            }
        }
    }
}
