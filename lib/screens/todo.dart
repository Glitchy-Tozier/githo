import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleShortcut.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlan_model.dart';
import 'package:githo/screens/habitList.dart';
import 'package:githo/screens/singlelHabitDisplay.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  late Future<List<HabitPlan>> _habitPlan;

  @override
  void initState() {
    super.initState();
    _updateHabitPlan();
  }

  void _updateHabitPlan() {
    setState(() {
      _habitPlan = DatabaseHelper.instance.getActiveHabitPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _habitPlan,
        builder: (context, AsyncSnapshot<List<HabitPlan>> snapshot) {
          List<Widget> returnWidgets = [];
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (snapshot.data!.length == 0) {
                double screenHeight = MediaQuery.of(context).size.height;
                return Container(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.25,
                    right: StyleData.screenPaddingValue,
                    left: StyleData.screenPaddingValue,
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Heading1("No challenges are active."),
                      Text(
                          "Click on the settings-Icon to add and/or activate a challenge"),
                    ],
                  ),
                );
              } else {
                HabitPlan habitPlan = snapshot.data![0];
                return Column(
                  children: <Widget>[
                    HeadingButton(
                      text: habitPlan.goal,
                      onPressedFunc: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SingleHabitDisplay(
                              updateFunction: _updateHabitPlan,
                              habitPlan: habitPlan,
                            ),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Icon(Icons.done),
                      ),
                    ),
                  ],
                );
              }
            } else if (snapshot.hasError) {
              // If something went wrong with the database
              returnWidgets.add(
                Center(
                  child: Text("There was an error connecting to the database."),
                ),
              );
              returnWidgets.add(
                Text(snapshot.error.toString()),
              );
              print(snapshot.error);
            }
          } else {
            // While loading, do this:
            returnWidgets.add(
              Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Column(
            children: returnWidgets,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: StyleData.floatingActionButtonPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () {
                //Navigator.pushNamed(context, "/habitList");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HabitList(
                      updateFunction: _updateHabitPlan,
                    ),
                  ),
                );
              },
              tooltip: "Go to settings",
              child: Icon(Icons.settings),
              backgroundColor: Colors.orange,
              heroTag: null, //"settingsHero",
            ),
            FloatingActionButton(
              onPressed: () {
                print(DateTime.now());
              },
              tooltip: "Mark challenge as done",
              child: Icon(Icons.done),
              heroTag: null,
            ),
          ],
        ),
      ),
    );
  }
}
