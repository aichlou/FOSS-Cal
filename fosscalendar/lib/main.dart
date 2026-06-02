// import 'package:flutter/foundation.dart';
//import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'FOSS Calendar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime selectedTime = DateTime.now();
  Duration month = Duration();
  Duration lastMonth = Duration();
  int coveredWeeks = 6;
  DateTime firstDay = DateTime.fromMicrosecondsSinceEpoch(0);
  List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  Offset _offset = Offset(0, 0);
  bool showDynamicWeeks = false;

  void createEvent() {

  }

  void settings() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Settings'),
              content: Column(
                mainAxisSize: .min,
                children: [
                  Row(
                    children: [
                      Text('Show only covered Weeks in the Month-View  '),
                      Switch(value: showDynamicWeeks, onChanged: (bool value) {setDialogState(() {showDynamicWeeks = value;});})
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    renderUI();
                  },
                  child: Text('Close')
                )
              ]
            );
          }
        );
      }
    );
  }

  void renderUI() {
    setState(() {
      coveredWeeks = showDynamicWeeks ? ((month.inDays.toInt() + firstDay.weekday.toInt() - 1) / 7).ceil() : 6;
    });
  }

  @override
  void initState() {
    month = DateTime(selectedTime.year, selectedTime.month + 1).difference(DateTime(selectedTime.year, selectedTime.month)); //Funktioniert bei Dezember nicht
    debugPrint('Tage diesen Monat: ${month.inDays}');
    firstDay = DateTime(selectedTime.year, selectedTime.month);
    debugPrint('Wochentag des ersten Tages: ${firstDay.weekday}');
    lastMonth = firstDay.difference(DateTime(selectedTime.year, selectedTime.month - 1)); //ONLY WORKS WHEN LAST MONTH IS IN THE SAME YEAR
    debugPrint('Tage letzten Monat: ${lastMonth.inDays}');
    renderUI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _offset += details.delta;
              //debugPrint((sin(_offset.dx / MediaQuery.of(context).size.width * 1.571)).toString());
            });
          },
          child: Transform.translate(
            offset: Offset(MediaQuery.of(context).size.width * sin(_offset.dx / MediaQuery.of(context).size.width * 1.571), 0),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                ...List.generate(
                  coveredWeeks + 1, (i) => Column(
                    children: [
                      Row(
                        children: [
                          ...List.generate(
                            7, (j) => Row(
                              children: [
                                dayInMonth(i, j),
                                if (j < 6) const SizedBox(width: 5,)
                              ]
                            )
                          ),
                        ],
                      ),
                      if (i < coveredWeeks) const SizedBox(height: 5,),
                    ],
                  )
                ),
                //Text('Lennard'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: .min,
        children: [
          FloatingActionButton(
            onPressed: createEvent,
            tooltip: 'New Event',
            child: const Icon(Icons.add),
          ),
          SizedBox(height: 5,),
          FloatingActionButton(
            onPressed: settings,
            tooltip: 'Settings',
            child: const Icon(Icons.settings),
          ),
        ]
      ),
    );
  }

  Widget dayInMonth (int week, int weekday) {
    if (week == 0) {
      String name = weekdays[weekday];
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 2.0,
          )
        ),
        width: MediaQuery.of(context).size.width * 0.13,
        //height: MediaQuery.of(context).size.height * 0.02,
        child:  Text(name,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    week = week - 1;
    int calcDay(int input) {
      int output = input - firstDay.weekday + 2;
      if (output <= 0) {
        output = lastMonth.inDays + output;
      }
      else if (output > month.inDays) {
        output = output - month.inDays;
      }
      return output;
    }//Returns the Day of the current Month with the x-th Day which is shown
    int day = calcDay(week * 7 + weekday);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ), 
      width: MediaQuery.of(context).size.width * 0.13,
      height: MediaQuery.of(context).size.height * 0.14,
      child: Row(
        children: [
          Expanded(
            child: Text('$day',
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
            )
          )
        ],
      ),
    );
  }
}
