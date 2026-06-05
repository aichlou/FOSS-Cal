// import 'package:flutter/foundation.dart';
//import 'dart:typed_data';

import 'package:flutter/gestures.dart';
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
  bool showDynamicWeeks = false;
  int calWeeks = 0;
  String? dayLabel = '3';
  List<String> monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  double spaceUnit = 4.0;
  final PageController _pageController = PageController(initialPage: 1);
  bool greyOutDays = true;

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
                      Flexible(child: Text('Show only covered Weeks in the Month-View  ')),
                      Switch(value: showDynamicWeeks, onChanged: (bool value) {setDialogState(() {showDynamicWeeks = value;});})
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(child: Text("Explicitly gray out days that do not belong to the month   ")),
                      Switch(value: greyOutDays, onChanged: (bool value) {setDialogState(() {greyOutDays = value;});})
                    ],
                  ),
                  Row(
                    children: [
                      Text('Weekday Label Length  '),
                      Flexible(child:
                        DropdownMenu<String>(
                          label: Text('Weekday Label Length'),
                          initialSelection: dayLabel,
                          onSelected: (value) {
                            setDialogState(() => dayLabel = value);
                          },
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                              value: '1',
                              label: '1',
                            ),
                            DropdownMenuEntry(
                              value: '2',
                              label: '2',
                            ),
                            DropdownMenuEntry(
                              value: '3',
                              label: '3',
                            ),
                            DropdownMenuEntry(
                              value: '!day',
                              label: 'Without "day"',
                            ),
                            DropdownMenuEntry(
                              value: 'all',
                              label: 'All',
                            )
                          ],
                          
                        )
                      ),
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
    weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    switch (dayLabel) {
      case '1': case '2': case '3':
        weekdays = weekdays.map((e) => e.substring(0, int.parse(dayLabel ?? '0'))).toList();   //['m', 't', 'w', 't', 'f', 's', 's'];
        break;
      case '!day':
        weekdays = weekdays.map((e) => e.substring(0, e.length - 3)).toList();
        break;
    }
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
    calWeeks= (firstDay.difference(DateTime(firstDay.year)).inDays / 7).floor() + 1;
    renderUI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    spaceUnit = ( MediaQuery.of(context).size.width + 1750 ) / 750;
    debugPrint(MediaQuery.of(context).size.width.toString());
    debugPrint(MediaQuery.of(context).size.height.toString());
    debugPrint(spaceUnit.toString());
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Icon(Icons.menu, size: 24),
            SizedBox(width: 15,), //This should Allign with the Days
            Text(monthNames[firstDay.month - 1]),
          ],
        )
      ),
      body:
        SafeArea(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                if (index == 0) {
                  firstDay = DateTime(firstDay.year, firstDay.month - 1);
                } else if (index == 2) {
                  firstDay = DateTime(firstDay.year, firstDay.month + 1);
                }
                _pageController.jumpToPage(1);
              });
            },
            children: [
              Container(),
              monthView(coveredWeeks, lastMonth, month),
              Container(),
            ],
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
          SizedBox(height: spaceUnit * 3,),
          FloatingActionButton(
            onPressed: settings,
            tooltip: 'Settings',
            child: const Icon(Icons.settings),
          ),
        ]
      ),
    );
  }

  Widget monthView (int coveredWeeks, Duration lastMonth, Duration month) {
    return Column(
      children: [
        Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 14 * spaceUnit,
                ),
                ...List.generate(
                  7, (j) => Row(
                    children: [
                      weekdayInMonth(j),
                      if (j < 6) SizedBox(width: spaceUnit,)
                    ]
                  )
                ),
                SizedBox(height: spaceUnit),
              ],
            ),
          ],
        ),
        ...List.generate(
          coveredWeeks, (i) => Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: spaceUnit * 3),
                        calWekInMonth(i, calWeeks),
                        SizedBox(width: spaceUnit * 3),
                        ...List.generate(
                          7, (j) => Row(
                            children: [
                              dayInMonth(i, j, lastMonth, month, firstDay),
                              SizedBox(width: spaceUnit,)
                            ]
                          )
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: spaceUnit),
              ], 
            ),  
          ),
        ), 
      ], 
    );
  }

  Widget calWekInMonth (int instance, int calWeeks) {
    String calWeek = (calWeeks + instance).toString();
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      width: 8 * spaceUnit,
      height: 30,
      child: Text(calWeek),
    );
  }

  Widget weekdayInMonth(int weekday) {
    String name = weekdays[weekday];
    return Container(
      alignment: .center,
      width: (MediaQuery.of(context).size.width - 14 * spaceUnit - 8 * spaceUnit) / 7,
      //height: MediaQuery.of(context).size.height * 0.02,
      child:  Text(
        name,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        )
      ), 
    );
  }

  Widget dayInMonth (int week, int weekday, Duration lastMonth, Duration month, DateTime firstDay) {
    bool thisMonth = true;
    int calcDay(int input) {
      int output = input - firstDay.weekday + 2;
      if (output <= 0) {
        output = lastMonth.inDays + output;
        thisMonth = false;
      }
      else if (output > month.inDays) {
        output = output - month.inDays;
        thisMonth = false;
      }
      return output;
    }//Returns the Day of the current Month with the x-th Day which is shown
    int day = calcDay(week * 7 + weekday);
    return Container(
        decoration: BoxDecoration(
        color: !thisMonth && greyOutDays ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ), 
      alignment: Alignment.topCenter,
      width: (MediaQuery.of(context).size.width - 14 * spaceUnit - 8 * spaceUnit) / 7,
      //height: MediaQuery.of(context).size.height * 0.14, 
      //child: Row(
        //children: [
          //Expanded(
            child: Text('$day',
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
              textAlign: .center,
              style: TextStyle(
                color: thisMonth ? Colors.black: Colors.grey[600],
              ),
            )
          //)
        //],
      //), 
    );
  }
}