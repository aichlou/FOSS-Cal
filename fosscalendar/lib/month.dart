class Month {
  final DateTime firstDay;
  final Duration lastMonth;
  final Duration month;
  final int calWeek;
  int get coveredWeeks => ((month.inDays.toInt() + firstDay.weekday.toInt() - 1) / 7).ceil();
  
  Month(this.firstDay)
    : month = DateTime(firstDay.year, firstDay.month + 1).difference(DateTime(firstDay.year, firstDay.month)),
    lastMonth = firstDay.difference(DateTime(firstDay.year, firstDay.month - 1)),
    calWeek = (firstDay.difference(DateTime(firstDay.year)).inDays / 7).floor() + 1;
}