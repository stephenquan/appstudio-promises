# appstudio-promises
Implements Promises wrapper for AppStudio QML components

It wraps AppStudio's NetworkRequest with a JavaScript promise.

 - appStudioPromises.networkRequest(properties)

In the following example we use AppStudioPromises.networkRequest() with
JavaScript promise chaining to issue two consective NetworkRequest together.
We also see that whilst the request is running we temporarily disabled the
Button with `enabled = false` and restore it with `enable = true` at the end
of the promise chain or when an exception has occured.

```qml
import "appstudio-promises"

Page {
    Button {
        text: qsTr("Query")
        onClicked: {
            enabled = false;
            appStudioPromises.networkRequest(
                    {
                        "url": "https://www.arcgis.com/sharing/rest",
                        "method": "GET",
                        "body": {
                            "f": "pjson"
                        }
                    } )
            .then( function (restRequest) {
                console.log(JSON.stringify(restRequest.response));
                // qml: {"currentVersion":"10.2"}
                return appStudioPromises.networkRequest(
                        {
                            "url": "https://www.arcgis.com/sharing/rest/info",
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
    
    AppStudioPromises {
        id: appStudioPromises
    }
}
```

To use AppStudioPromises in your project consider cloning this rep directly in your project:

    git clone https://github.com/stephenquan/appstudio-promises.git

or adding it as a submodule:

    git submodule add https://github.com/stephenquan/appstudio-promises.git appstudio-promises
    git submodule update
