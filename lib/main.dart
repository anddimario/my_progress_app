import 'package:flutter/material.dart';
import 'package:my_progress_app/add_activity.dart';
import 'package:my_progress_app/database_helpers.dart';
import 'package:my_progress_app/see_activity.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Progress',
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
      home: HomeRoute(),
    );
  }
}

class HomeRoute extends StatefulWidget {
  @override
  HomeRouteState createState() {
    return new HomeRouteState();
  }
}

class HomeRouteState extends State<HomeRoute> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Progress'),
      ),
      body: Center(
        child: Column(children: <Widget>[
          // Add expanded to avoid overflow on layout error
          Expanded(
            child: SizedBox(
              height: 50.0,
              child: FutureBuilder<List<Map>>(
                  future: dbHelper.queryAllActivities(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      // return: show loading widget
                    }
                    if (snapshot.hasError) {
                      // return: show error widget
                    }
                    List<Map> activities = snapshot.data ?? [];
                    return ListView.builder(
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          Map activity = activities[index];
                          return new ListTile(
                            /*leading: CircleAvatar(
                              backgroundImage: AssetImage(user.profilePicture),
                            ),*/
                            trailing: Icon(
                              Icons.more,
                              color: Colors.grey,
                              size: 20.0,
                            ),
                            title: new Text(activity["title"]),
                            onTap: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => new SeeActivityRoute(),
                                  // Pass the arguments as part of the RouteSettings. The
                                  // SeeActivityRoute reads the arguments from these settings.
                                  settings: RouteSettings(
                                    arguments: activity,
                                  ),
                                ),
                              );
                            },
                          );
                        });
                  }),
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Navigate to second route when tapped.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => new AddActivityRoute()),
          );
        },
      ),
    );
  }
}
