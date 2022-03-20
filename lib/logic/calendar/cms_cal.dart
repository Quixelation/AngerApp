part of calendar;

Future<List<EventData>> _fetchCmsCal() async {
  var resp =
      await http.get(Uri.parse("${AppManager.directusUrl}/items/kalender"));
  if (resp.statusCode != 200) {
    logger.e("Error fetching calendar: Non 200 response");
    throw "Error fetching calendar: Non 200 response";
  }
  var json = jsonDecode(resp.body);
  if (json["data"] == null) {
    logger.e("Error fetching calendar: No data");
    throw "Error fetching calendar: No data";
  }
  var data = json["data"] as List;
  List<EventData> eventList = [];
  for (var item in data) {
    eventList.add(EventData(
        id: item["id"],
        dateFrom: DateTime.parse(item["date_start"]),
        title: item["titel"],
        dateTo:
            item["date_end"] != null ? DateTime.parse(item["date_end"]) : null,
        //TODO: ADD desc to CMS
        desc: ""));
  }
  return eventList;
}
