import 'calendar.dart';

// CalendarController
class HorizontalCalendarController {
  HorizontalCalendarState? state;

  void bindState(HorizontalCalendarState state) {
    this.state = state;
  }

  void goToDay(DateTime date) {
    state!.getDate(date);
  }

  void goToToday() {
    goToDay(DateTime.now());
  }

  void goToNextDay() {
    state!.getDate(state!.selectedDate!.add(const Duration(days: 1)));
  }

  void goToPreviousDay() {
    state!.getDate(state!.selectedDate!.subtract(const Duration(days: 1)));
  }

  void openCalendar() {
    state!.openCalendar();
  }

  void dispose() {
    state = null;
  }
}
