import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roam_flutter/roam_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  // MyHomePage({Key? key, required this.title}) : super(key: key); // null safe

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _platformVersion = 'Unknown';
  String myLocation = 'Unknown';

  //Native to Flutter Channel
  static const platform = const MethodChannel("myChannel");

  @override
  void initState() {
    platform.setMethodCallHandler(nativeMethodCallHandler); //Native to Flutter Channel
    super.initState();
    initPlatformState();
    Roam.initialize(publishKey: "2baef3375364175971978b5f1c8999de521375af0e8099820886b7d1a94470fd");
  }

  //Native to Flutter Channel
  Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "location":
        print(methodCall.arguments);
        setState(() {
          myLocation = methodCall.arguments;
        });
        break;
      default:
        return "Nothing";
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Roam.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion!;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SelectableText('Running on: $_platformVersion\n'),
            SelectableText(
              'Received Location:\n $myLocation\n',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
                child: Text('Request Location Permissions'),
                onPressed: () async {
                  try {
                    await Permission.locationAlways.request();
                  } on PlatformException {
                    print('Error getting location permissions');
                  }
                }),
            ElevatedButton(
                child: Text('Get Current Location'),
                onPressed: () async {
                  setState(() {
                    myLocation = "fetching location..";
                  });
                  try {
                    await Roam.getCurrentLocation(
                      accuracy: 100,
                      callBack: ({location}) {
                        setState(() {
                          myLocation = location!;
                        });
                        print(location);
                      },
                    );
                  } on PlatformException {
                    print('Get Current Location Error');
                  }
                }),
            ElevatedButton(
                child: Text('Create User'),
                onPressed: () async {
                  try {
                    await Roam.createUser(
                        description: 'kip',
                        callBack: ({user}) {
                          print(user);
                          //TODO: write a new record in firestore: /roam_users/user.data.id
                        });
                  } on PlatformException {
                    print('Create User Error');
                  }
                }),
            ElevatedButton(
                child: Text('Update Current Location'),
                onPressed: () async {
                  try {
                    await Roam.updateCurrentLocation(accuracy: 100);
                  } on PlatformException {
                    print('Update Current Location Error');
                  }
                }),
            ElevatedButton(
                child: Text('Start timed tracking'),
                onPressed: () async {
                  try {
                    Map<String, dynamic> fitnessTracking = {
                          "showsBackgroundLocationIndicator": true,
                          "allowBackgroundLocationUpdates": true,
                          "desiredAccuracy": "kCLLocationAccuracyBest",
                          "timeInterval": 1
                        };
                    Roam.startTracking(
                        trackingMode: "custom",
                        customMethods: fitnessTracking);
                  } on PlatformException {
                    print('Start tracking error');
                  }
                }),
            ElevatedButton(
                child: Text('Stop tracking'),
                onPressed: () async {
                  try {
                    await Roam.stopTracking();
                  } on PlatformException {
                    print('Stop tracking error');
                  }
                }),
          ],
        ),
      ),
    );
  }
}
