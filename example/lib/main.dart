import 'dart:math';

import 'package:flutter/material.dart';
import 'package:horizontal_calendar/horizontal_calendar.dart';

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
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final HorizontalCalendarController _calendarAgendaControllerAppBar = HorizontalCalendarController();
  final HorizontalCalendarController _calendarAgendaControllerNotAppBar = HorizontalCalendarController();

  late DateTime _selectedDateAppBBar;
  late DateTime _selectedDateNotAppBBar;

  Random random = Random();

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    _selectedDateNotAppBBar = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HorizontalCalendar(
        controller: _calendarAgendaControllerAppBar,
        appbar: true,
        selectedDayPosition: SelectedDayPosition.right,
        weekDay: WeekDay.long,
        fullCalendarScroll: FullCalendarScroll.horizontal,
        fullCalendarDay: WeekDay.long,
        selectedDateColor: Colors.green.shade900,
        dateColor: Colors.white,
        fullCalendarDateColor: Colors.black,
        // fullCalendarWeekDayBuilder: (weekday) => Center(
        //   child: Text("$weekday - ${DateFormat.E(Platform.localeName).dateSymbols.STANDALONENARROWWEEKDAYS[weekday % 7]}"),
        // ),
        // fullCalendarDayBuilder: (date, outOfRange, isSelectedDate, isCurrentDate, event) => Text(date.day.toString()),
        firstDayOfWeek: DateTime.sunday,
        locale: 'en',
        initialDate: DateTime.now(),
        calendarEventColor: Colors.green,
        firstDate: DateTime.now().subtract(const Duration(days: 140)),
        lastDate: DateTime.now().add(const Duration(days: 60)),
        events: List.generate(100, (index) => DateTime.now().subtract(Duration(days: index * random.nextInt(5)))),
        onDateSelected: (date) {
          setState(() {
            _selectedDateAppBBar = date;
          });
        },
        calendarLogo: Image.network(
          'https://www.kindpng.com/picc/m/355-3557482_flutter-logo-png-transparent-png.png',
          scale: 5.0,
        ),
        selectedDayLogo: const NetworkImage(
          'https://www.kindpng.com/picc/m/355-3557482_flutter-logo-png-transparent-png.png',
          scale: 15.0,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _calendarAgendaControllerAppBar.goToDay(DateTime.now());
              },
              child: const Text("Today, appbar = true"),
            ),
            Text('Selected date is $_selectedDateAppBBar'),
            const SizedBox(
              height: 20.0,
            ),
            HorizontalCalendar(
              selectedDayPosition: SelectedDayPosition.center,
              controller: _calendarAgendaControllerNotAppBar,
              header: const SizedBox(
                // width: MediaQuery.of(context).size.width * 0.3,
                child: Center(
                  child: Text(
                    "Agenda anda hari ini adalah sebagai berikut",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // fullCalendar: false,
              locale: 'en',
              weekDay: WeekDay.long,
              // showHeader: false,
              // showAlignmentHelper: true,
              weekDayHeight: 80.0,
              weekDayAlignment: 0.405,
              weekDayBuilder: (context, isSelected, date, isCurrentDate) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 42.0,
                    child: Text(
                      date.day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.0,
                        color: isSelected ? Colors.white : Colors.white.withOpacity(.3),
                      ),
                    ),
                  ),
                );
              },
              prefix: GestureDetector(
                onTap: _calendarAgendaControllerNotAppBar.goToPreviousDay,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                ),
              ),
              suffix: GestureDetector(
                onTap: _calendarAgendaControllerNotAppBar.goToNextDay,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ),
              fullCalendarDay: WeekDay.short,
              selectedDateColor: Colors.blue.shade900,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 140)),
              lastDate: DateTime.now().add(const Duration(days: 140)),
              events: List.generate(100, (index) => DateTime.now().subtract(Duration(days: index * random.nextInt(5)))),
              onDateSelected: (date) {
                setState(() {
                  _selectedDateNotAppBBar = date;
                });
              },
              calendarLogo: Image.network(
                'https://www.kindpng.com/picc/m/355-3557482_flutter-logo-png-transparent-png.png',
                scale: 5.0,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _calendarAgendaControllerNotAppBar.goToDay(DateTime.now());
              },
              child: const Text("Today, appbar = false (default value)"),
            ),
            Text('Selected date is $_selectedDateNotAppBBar'),
            const SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
