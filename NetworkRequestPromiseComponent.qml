import QtQuick 2.12
import ArcGIS.AppFramework 1.0

Component {
    id: networkRequestComponent

    NetworkRequest {
        id: _networkRequest

        property var options: null

        property var context
        property var resolve: null
        property var reject: null
        property bool contextAborting: context ? context.aborting : null

        property var body
        property var responseJson: null

        onReadyStateChanged: {
            if (readyState !== NetworkRequest.ReadyStateComplete) {
                return;
            }

            if (context && context.aborted) {
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
                responseText: responseText
            };

            resolve(obj);

            Qt.callLater(destroy);
        }

        onContextAbortingChanged: {
            if (contextAborting) {
                if (readyState === NetworkRequest.ReadyStateProcessing
                        || readyState === NetworkRequest.ReadyStateSending)
                {
                    abort();
                    //userAborted = true;
                    //reject(new Error("User Abort"));
                    context.finishAbort(reject);
                    Qt.callLater(destroy);
                }
            }
        }

        Component.onCompleted: {
            if (options && options["headers"]) {
                headers.json = options["headers"];
            }

            if (body) {
                send(body);
            } else {
                send();
            }
        }
    }
}
