

class Event {
  final int id;
  final String version = "0.0";
  String name;
  DateTime start;
  DateTime end;

  Event(this.name, this.start, this.end)
    : id = 0;
}