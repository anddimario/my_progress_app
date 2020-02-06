import 'package:flutter/material.dart';
import 'package:my_progress_app/database_helpers.dart';
import 'package:my_progress_app/main.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class SeeActivityRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("See Activity"), actions: <Widget>[
        // action button
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            DeleteButton deleteButton = new DeleteButton(context);
            deleteButton.removeActivity();
          },
        ),
      ]),
      // https://api.flutter.dev/flutter/widgets/Column-class.html
      body: Column(
        children: <Widget>[
          SeeActivityForm(),
          /*
          RaisedButton(
            onPressed: () {
              // Navigate back to first route when tapped.
              Navigator.pop(context);
            },
            child: Text('Go back!'),
          ),*/
        ],
      ),
    );
  }
}

// Create a Form widget.
class SeeActivityForm extends StatefulWidget {
  @override
  SeeActivityFormState createState() {
    return SeeActivityFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class SeeActivityFormState extends State<SeeActivityForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<SeeActivityFormState>.
  final _formKey = GlobalKey<FormState>();

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final _titleController = TextEditingController();
  final _goalController = TextEditingController();
  int _scheduleTimestamp;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _titleController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  // get activity
  _getActivity(int id) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    Activity activity = await helper.queryActivity(id);
    return activity;
  }

  // update activity
  _update(id, title, goal, schedule) async {
    Activity activity = Activity();
    activity.id = id;
    activity.title = title;
    activity.schedule = schedule;
    activity.goal = goal;
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.update(activity);
  }

  @override
  Widget build(BuildContext context) {
    final Map activity = ModalRoute.of(context).settings.arguments;
    final format = DateFormat("yyyy-MM-dd HH:mm");

    DateTime actualSchedule = DateTime.fromMillisecondsSinceEpoch(activity["schedule"]);


    _getActivity(activity["_id"]).then((activity) {
      _titleController.text = activity.title;
      _goalController.text = activity.goal;
      _scheduleTimestamp = activity.schedule;
    });
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(hintText: "Title"),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text in title';
              }
              return null;
            },
            controller: _titleController,
          ),
          TextFormField(
            decoration: InputDecoration(hintText: "Goal"),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text in goal';
              }
              return null;
            },
            controller: _goalController,
          ),
          Text("Actual scheduler: ${actualSchedule}"),
          Text("Schedule a new date(${format.pattern})"),
          DateTimeField(
            format: format,
            onShowPicker: (context, currentValue) async {
              if (actualSchedule != null) {
                currentValue = actualSchedule;
              }
              final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100));
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );
                DateTime combinedDate = DateTimeField.combine(date, time);
                _scheduleTimestamp = combinedDate.millisecondsSinceEpoch;
                return combinedDate;
              } else {
                return currentValue;
              }
            },
          ),
          RaisedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false
              // otherwise.
              if (_formKey.currentState.validate()) {
                String title = _titleController.text;
                String goal = _goalController.text;
                // If the form is valid, display a Snackbar.
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Processing Data')));
                _update(activity["_id"], title, goal, _scheduleTimestamp);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => new HomeRoute()),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}

// Delete button widget

class DeleteButton {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  BuildContext context;

  _delete(id) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.delete(id);
  }

  DeleteButton(BuildContext context) {
    this.context = context;
  }

  removeActivity() {
    final Map activity = ModalRoute.of(context).settings.arguments;

    _delete(activity["_id"]);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new HomeRoute()),
    );
  }
}
