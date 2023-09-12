part of statuspage;

class _StatuspageApiResponseConfig {
  final String slug;
  final String title;
  final String icon;
  final String footerText;

  _StatuspageApiResponseConfig.fromApi(Map<String, dynamic> apiMap)
      : slug = apiMap["slug"],
        title = apiMap["title"],
        icon = apiMap["icon"],
        footerText = apiMap["footerText"];
}

class _StatuspageApiResponsePublicGroupListItem {
  final int id;
  final String name;
  final int weight;
  final List<_StatuspageApiResponseMonitor> monitorList;

  _StatuspageApiResponsePublicGroupListItem.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        name = apiMap["name"],
        weight = apiMap["weight"],
        monitorList = List.from(apiMap["monitorList"])
            .map((e) => _StatuspageApiResponseMonitor.fromApi(e))
            .toList();
}

class _StatuspageApiResponseMonitor {
  final int id;
  final String name;
  final int sendUrl;

  _StatuspageApiResponseMonitor.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        name = apiMap["name"],
        sendUrl = apiMap["sendUrl"];
}

class _StatuspageApiResponse {
  final _StatuspageApiResponseConfig config;
  //TODO: Incidents
  final List<_StatuspageApiResponsePublicGroupListItem> publicGroupList;
  _StatuspageApiResponse.fromApi(Map<String, dynamic> apiMap)
      : config = _StatuspageApiResponseConfig.fromApi(apiMap["config"]),
        publicGroupList = List.from(apiMap["publicGroupList"])
            .map((e) => _StatuspageApiResponsePublicGroupListItem.fromApi(e))
            .toList();
}

class _StatuspageApiHeartbeat {
  /// 1 = online, 0 = offline
  final int status;
  final String time;
  final String msg;
  final int? ping;
  _StatuspageApiHeartbeat(
      {required this.msg,
      required this.ping,
      required this.status,
      required this.time});
  _StatuspageApiHeartbeat.fromApi(Map<String, dynamic> apiMap)
      : status = apiMap["status"],
        time = apiMap["time"],
        msg = apiMap["msg"],
        ping = apiMap["ping"];
}

class _StatuspageApiHeartbeatResponse {
  late final Map<int, List<_StatuspageApiHeartbeat>> heartbeatList;
  late final Map<int, double> uptimeList;

  //TODO: add uptimeList
  _StatuspageApiHeartbeatResponse.fromApi(Map<String, dynamic> apiMap) {
    // /* ------------------------------ heartbeatList ----------------------------- */
    Map<int, List<_StatuspageApiHeartbeat>> tempHeartbeatList = {};
    for (var heartbeatEntryList in Map.from(apiMap["heartbeatList"]).entries) {
      tempHeartbeatList[int.parse(heartbeatEntryList.key)] =
          List.from(heartbeatEntryList.value)
              .map((e) => _StatuspageApiHeartbeat.fromApi(e))
              .toList();
    }
    heartbeatList = tempHeartbeatList;

    /* ------------------------------- uptimeList ------------------------------- */
    Map<int, double> tempUptimeList = {};
    try {
      for (var uptimeEntry in Map.from(apiMap["uptimeList"]).entries) {
        tempUptimeList[
                int.parse((uptimeEntry.key as String).replaceAll("_24", ""))] =
            double.parse(uptimeEntry.value.toString());
      }
    } catch (err) {
      logger.w(err);
    }
    uptimeList = tempUptimeList;
  }
}
