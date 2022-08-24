# appstudio-promises
Implements Promises wrapper for AppStudio QML components

It wraps AppStudio's NetworkRequest with a JavaScript promise.

In the following example we combine NetworkRequestPromiseComponent with
the Qt5 QML Promise library https://github.com/stephenquan/qt5-qml-promises
to implement async function with await as generate function with yield
to iterate results from an ArcGIS Online Search.

```qml
import "qt5-qml-promises"
import "appstudio-promises"

Page {
    id: page
    
    Button {
        text: qsTr("Search")
        onClicked: {
            qmlPromises.userAbort();
            qmlPromises.asyncToGenerator( function * () {
                let start = 1;
                while (start >= 1) {
                    let search = yield qmlPromises.invoke(networkRequestComponent, {
                        "url": `https://www.arcgis.com/sharing/rest/search`,
                        "body": {
                            "q": "type:native application",
                            "start": start,
                            "num": 100,
                            "f": "pjson"
                        }
                    } );
                    console.log("start:", start, "results: ", search.response.results.length, "nextStart: ", search.response.nextStart);
                    if (search.response.nextStart === -1) { break; }
                    start = search.response.nextStart;
                }
            } )();
        }
    }
    
    QMLPromises {
        id: qmlPromises
        owner: page
    }
    
    NetworkRequestPromiseComponent {
        id: networkRequestComponent
    }
}
```

To use AppStudioPromises in your project consider cloning this rep directly in your project:

    git clone https://github.com/stephenquan/appstudio-promises.git

or adding it as a submodule:

    git submodule add https://github.com/stephenquan/appstudio-promises.git appstudio-promises
    git submodule update
