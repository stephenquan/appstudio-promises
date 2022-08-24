# appstudio-promises
Implements Promises wrapper for AppStudio QML components

It wraps AppStudio's NetworkRequest with a JavaScript promise.

In the following example we combine NetworkRequestPromiseComponent with
the Qt5 QML Promise library https://github.com/stephenquan/qt5-qml-promises
to implement async function with await as generate function with yield
to iterate results from an ArcGIS Online Search.

```qml
import "appstudio-promises"
import "qt5-qml-promises"

Page {
    Button {
        text: qsTr("Search")
        onClicked: {
            qmlPromises.asyncToGenerator( function * () {
                let portalUrl = "https://www.arcgis.com";
                let q = "type:native application";
                let start = 1;
                let num = 100;
                while (start >= 1) {
                    let search = yield qmlPromises.invoke(networkRequestComponent, {
                        "url": `${portalUrl}/sharing/rest/search`,
                        "body": {
                            "q": q,
                            "start": start ?? 1,
                            "num": num ?? 10,
                            "f": "pjson",
                        }
                    } );
                    let results = search.response.results;
                    let nextStart = search.response.nextStart;
                    console.log("start:", start, "nextStart: ", nextStart, "results: ", results.length);
                    if (nextStart === -1) { break; }
                    start = nextStart;
                }
            } )();
        }
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
