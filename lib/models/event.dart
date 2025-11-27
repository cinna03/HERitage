class Event {
  final String title;
  final String description;
  final DateTime dateTime;
  final String type;
  final String host;
  final int attendees;
  bool isRSVPed;
  final String location;

  Event(this.title, this.description, this.dateTime, this.type, 
        this.host, this.attendees, this.isRSVPed, this.location);
}