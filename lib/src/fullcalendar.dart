import 'dart:io';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:horizontal_calendar/src/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'typedata.dart';

class FullCalendar extends StatefulWidget {
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? selectedDate;
  final Color dateColor;
  final Color? dateSelectedColor;
  final Color? currentDateColor;
  final Color? dateSelectedBg;
  final double? padding;
  final String? locale;
  final WeekDay? fullCalendarDay;
  final FullCalendarScroll? calendarScroll;
  final Widget? calendarBackground;
  final List<String>? events;
  final void Function(DateTime date) onDateChange;

  final Widget Function(DateTime date)? headerBuilder;
  final Widget Function(int weekday)? weekDayBuilder;
  final Widget Function(DateTime date, bool outOfRange, bool isSelectedDate, bool isCurrentDate, bool event)? dayBuilder;
  final Widget Function(PageController controller, void Function(DateTime date) onDateChange)? footerBuilder;

  /// The first day of the week, use DateTime.sunday or DateTime.monday
  final int? firstDayOfWeek;

  const FullCalendar({
    super.key,
    this.endDate,
    required this.startDate,
    required this.padding,
    required this.onDateChange,
    this.calendarBackground,
    this.events,
    this.dateColor = Colors.black,
    this.currentDateColor,
    this.dateSelectedColor,
    this.dateSelectedBg,
    this.locale,
    this.selectedDate,
    this.fullCalendarDay,
    this.calendarScroll,
    this.headerBuilder,
    this.weekDayBuilder,
    this.dayBuilder,
    this.footerBuilder,
    this.firstDayOfWeek,
  });

  @override
  State<FullCalendar> createState() => _FullCalendarState();
}

class _FullCalendarState extends State<FullCalendar> {
  late DateTime endDate;

  late DateTime startDate;
  late int _initialPage;

  List<String>? _events = [];

  late PageController _horizontalScroll;

  @override
  void initState() {
    setState(() {
      startDate = DateTime.parse("${widget.startDate.toString().split(" ").first} 00:00:00.000");

      endDate = DateTime.parse("${widget.endDate.toString().split(" ").first} 23:00:00.000");

      _events = widget.events;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> partsStart = startDate.toString().split(" ").first.split("-");

    DateTime firstDate = DateTime.parse("${partsStart.first}-${partsStart[1].padLeft(2, '0')}-01 00:00:00.000");

    List<String> partsEnd = endDate.toString().split(" ").first.split("-");

    DateTime lastDate =
        DateTime.parse("${partsEnd.first}-${(int.parse(partsEnd[1]) + 1).toString().padLeft(2, '0')}-01 23:00:00.000").subtract(const Duration(days: 1));

    double width = MediaQuery.of(context).size.width - (2 * widget.padding!);

    List<DateTime?> dates = [];

    DateTime referenceDate = firstDate;

    while (referenceDate.isBefore(lastDate)) {
      List<String> referenceParts = referenceDate.toString().split(" ");
      DateTime newDate = DateTime.parse("${referenceParts.first} 12:00:00.000");
      dates.add(newDate);

      referenceDate = newDate.add(const Duration(days: 1));
    }

    if (firstDate.year == lastDate.year && firstDate.month == lastDate.month) {
      return Padding(
        padding: EdgeInsets.fromLTRB(widget.padding!, 40.0, widget.padding!, 0.0),
        child: month(dates, width, widget.locale, widget.fullCalendarDay),
      );
    } else {
      List<DateTime?> months = [];
      for (int i = 0; i < dates.length; i++) {
        if (i == 0 || (dates[i]!.month != dates[i - 1]!.month)) {
          months.add(dates[i]);
        }
      }

      months.sort((b, a) => a!.compareTo(b!));

      final initalIndex = months.indexWhere((element) => element!.month == widget.selectedDate!.month && element.year == widget.selectedDate!.year);

      _initialPage = initalIndex;
      _horizontalScroll = PageController(initialPage: _initialPage);

      return Container(
        padding: const EdgeInsets.fromLTRB(25, 10.0, 25, 20.0),
        child: widget.calendarScroll == FullCalendarScroll.horizontal
            ? SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: Center(child: widget.calendarBackground),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ExpandablePageView.builder(
                          controller: _horizontalScroll,
                          physics: const BouncingScrollPhysics(),
                          reverse: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: months.length,
                          itemBuilder: (context, index) {
                            DateTime? date = months[index];
                            List<DateTime?> daysOfMonth = [];
                            for (var item in dates) {
                              if (date!.month == item!.month && date.year == item.year) {
                                daysOfMonth.add(item);
                              }
                            }

                            bool isLast = index == 0;

                            return Container(
                              padding: EdgeInsets.only(bottom: isLast ? 0.0 : 10.0),
                              child: month(daysOfMonth, width, widget.locale, widget.fullCalendarDay),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        widget.footerBuilder != null
                            ? widget.footerBuilder!.call(_horizontalScroll, widget.onDateChange)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _horizontalScroll.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    },
                                    icon: const Icon(Icons.arrow_back),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      widget.onDateChange(DateTime.now());
                                    },
                                    icon: const Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                    ),
                                    label: const Text("Today"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: widget.dateColor,
                                      side: BorderSide(
                                        width: 1.0,
                                        color: widget.dateColor.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _horizontalScroll.previousPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    },
                                    icon: const Icon(Icons.arrow_forward),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  Opacity(
                    opacity: 0.2,
                    child: Center(
                      child: widget.calendarBackground,
                    ),
                  ),
                  ScrollablePositionedList.builder(
                    shrinkWrap: true,
                    initialScrollIndex: initalIndex,
                    itemCount: months.length,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      DateTime? date = months[index];
                      List<DateTime?> daysOfMonth = [];
                      for (var item in dates) {
                        if (date!.month == item!.month && date.year == item.year) {
                          daysOfMonth.add(item);
                        }
                      }

                      bool isLast = index == 0;

                      return Container(
                        padding: EdgeInsets.only(bottom: isLast ? 0.0 : 25.0),
                        child: month(daysOfMonth, width, widget.locale, widget.fullCalendarDay),
                      );
                    },
                  ),
                ],
              ),
      );
    }
  }

  Widget daysOfWeek(double width, String? locale, WeekDay? weekday) {
    final localeFirstDayOfWeek = (MaterialLocalizations.of(context).firstDayOfWeekIndex + 7) % (7 + 1);
    final weekdays = [for (var i = 0; i < 7; ++i) ((widget.firstDayOfWeek ?? localeFirstDayOfWeek) + i) % 7];

    final weekdayWidth = width / weekdays.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        dayName(weekdayWidth, weekdays[0]),
        dayName(weekdayWidth, weekdays[1]),
        dayName(weekdayWidth, weekdays[2]),
        dayName(weekdayWidth, weekdays[3]),
        dayName(weekdayWidth, weekdays[4]),
        dayName(weekdayWidth, weekdays[5]),
        dayName(weekdayWidth, weekdays[6]),
      ],
    );
  }

  Widget dayName(double width, int weekday) {
    final dayName = widget.fullCalendarDay == WeekDay.short
        ? DateFormat.E(Platform.localeName).dateSymbols.STANDALONENARROWWEEKDAYS[weekday % 7]
        : DateFormat.E(Platform.localeName).dateSymbols.STANDALONESHORTWEEKDAYS[weekday % 7];

    return Container(
      width: width,
      alignment: Alignment.center,
      child: widget.weekDayBuilder != null
          ? widget.weekDayBuilder!.call(weekday)
          : Text(
              dayName,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
    );
  }

  Widget dateInCalendar(DateTime date, bool outOfRange, double width, bool event) {
    bool isSelectedDate = date.toString().split(" ").first == widget.selectedDate.toString().split(" ").first;
    bool isCurrentDate = date.isSameDate(DateTime.now());

    return GestureDetector(
      onTap: () => outOfRange ? null : widget.onDateChange(date),
      child: Container(
        width: width / 7,
        height: width / 7,
        decoration: widget.dayBuilder == null
            ? BoxDecoration(
                shape: BoxShape.circle,
                color: isSelectedDate ? widget.dateSelectedBg : Colors.transparent,
              )
            : null,
        alignment: Alignment.center,
        child: widget.dayBuilder != null
            ? widget.dayBuilder!.call(date, outOfRange, isSelectedDate, isCurrentDate, event)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      DateFormat("dd").format(date),
                      style: TextStyle(
                          color: outOfRange
                              ? isSelectedDate
                                  ? (widget.dateSelectedColor ?? Theme.of(context).primaryColor).withOpacity(0.9)
                                  : isCurrentDate
                                      ? (widget.currentDateColor ?? widget.dateColor).withOpacity(0.4)
                                      : widget.dateColor.withOpacity(0.4)
                              : isSelectedDate
                                  ? widget.dateSelectedColor
                                  : isCurrentDate
                                      ? widget.currentDateColor
                                      : widget.dateColor),
                    ),
                  ),
                  event
                      ? Icon(
                          Icons.bookmark,
                          size: 8,
                          color: isSelectedDate ? widget.dateSelectedColor : widget.dateSelectedBg,
                        )
                      : const SizedBox(height: 5.0),
                ],
              ),
      ),
    );
  }

  Widget month(List dates, double width, String? locale, WeekDay? weekday) {
    DateTime first = dates.first;
    final localeFirstDayOfWeek = (MaterialLocalizations.of(context).firstDayOfWeekIndex + 7) % (7 + 1);
    while (dates.first.weekday != (widget.firstDayOfWeek ?? localeFirstDayOfWeek)) {
      dates.add(dates.first.subtract(const Duration(days: 1)));

      dates.sort();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        widget.headerBuilder != null
            ? widget.headerBuilder!.call(first)
            : Text(
                DateFormat.yMMMM(Locale(locale!).toString()).format(first),
                style: TextStyle(fontSize: 18.0, color: widget.dateColor, fontWeight: FontWeight.w400),
              ),
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: daysOfWeek(width, widget.locale, widget.fullCalendarDay),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10.0),
          height: dates.length > 28
              ? dates.length > 35
                  ? 6.2 * width / 7
                  : 5.2 * width / 7
              : 4 * width / 7,
          width: MediaQuery.of(context).size.width - 2 * widget.padding!,
          child: GridView.builder(
            itemCount: dates.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemBuilder: (context, index) {
              DateTime date = dates[index];

              bool outOfRange = date.isBefore(startDate) || date.isAfter(endDate);

              if (date.isBefore(first)) {
                return Container(
                  width: width / 7,
                  height: width / 7,
                  color: Colors.transparent,
                );
              } else {
                return dateInCalendar(
                  date,
                  outOfRange,
                  width,
                  _events!.contains(date.toString().split(" ").first) && !outOfRange,
                );
              }
            },
          ),
        )
      ],
    );
  }
}
