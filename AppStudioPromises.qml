import QtQuick 2.12
import ArcGIS.AppFramework 1.0

Item {
    function userAbort() {
        internal.userAbortTime = Date.now();
    }

    QtObject {
        id: internal
        property double userAbortTime: 0
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

    function invoke(promiseComponent, props) {
        return new Promise(function (resolve, reject) {
            let _props = props ?? { };
            _props.resolve = resolve;
            _props.reject = reject;
            _props.userAbortTime = Qt.binding(() => internal.userAbortTime);

            try {
                promiseComponent.createObject(null, _props);
            } catch (err) {
                reject(err);
            }
        } );
    }

    function networkRequest(properties) {
        return invoke(networkRequestComponent, properties);
    }

    NetworkRequestPromiseComponent {
        id: networkRequestComponent
    }
}
