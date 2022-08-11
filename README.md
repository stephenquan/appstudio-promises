# appstudio-qml-requests
Implements Requests singleton QML component.

It wraps AppStudio's NetworkRequest with a JavaScript promise.

 - Requests.request(url, options)

In the following example we use Requests.request() with JavaScript promise
chaining to issue two consective NetworkRequest together. We also see that
whilst the request is running we temporarily disabled the Button with
`enabled = false` and restore it with `enable = true` at the end of
the promise chain or when an exception has occured.

```qml
Button {
    text: qsTr("Query")
    onClicked: {
        enabled = false;
        Requests.request(
                    "https://www.arcgis.com/sharing/rest",
                    {
                        "method": "GET",
                        "body": {
                            "f": "pjson"
                        }
                    }
                    )
        .then( function (restRequest) {
            console.log(JSON.stringify(restRequest.response));
            // qml: {"currentVersion":"10.2"}
            return Requests.request(
                        "https://www.arcgis.com/sharing/rest/info",
                        {
                            "method": "POST",
                            "body": {
                                "f": "pjson"
                            }
                        } )
        } )
        .then( function (selfRequest) {
            enabled = true;
            console.log(JSON.stringify(selfRequest.response));
            // qml: {"owningSystemUrl":"https://www.arcgis.com","authInfo":{"tokenServicesUrl":"https://www.arcgis.com/sharing/rest/generateToken","isTokenBasedSecurity":true}}
        } )
        .catch( function (err) {
            enabled = false;
            console.error(err.message, err.stack);
            throw err;
        } )
        ;
    }
}
```

To use Requests singleton QML component in your project consider cloning this rep directly in your project:

    git clone https://github.com/stephenquan/appstudio-qml-requests.git

or adding it as a submodule:

    git submodule add https://github.com/stephenquan/appstudio-qml-requests appstudio-qml-requests
    git submodule update
