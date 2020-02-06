import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_progress_app/database_helpers.dart';
import 'package:my_progress_app/main.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class AddActivityRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Activity"),
      ),
      // https://api.flutter.dev/flutter/widgets/Column-class.html
      body: Column(
        children: <Widget>[
          AddActivityForm(),
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
class AddActivityForm extends StatefulWidget {
  @override
  AddActivityFormState createState() {
    return AddActivityFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class AddActivityFormState extends State<AddActivityForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<AddActivityFormState>.
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

  @override
  Widget build(BuildContext context) {
    final format = DateFormat("yyyy-MM-dd HH:mm");
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
          Text("Schedule a date(${format.pattern})"),
          DateTimeField(
            format: format,
            onShowPicker: (context, currentValue) async {
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
                _scheduleTimestamp = date.millisecondsSinceEpoch;
                return DateTimeField.combine(date, time);
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
                _save(title, goal, _scheduleTimestamp);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => new HomeRoute()),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  // save activity
  _save(title, goal, schedule) async {
    Activity activity = Activity();
    activity.title = title;
    activity.schedule = schedule;
    activity.goal = goal;
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.insert(activity);
  }
}
