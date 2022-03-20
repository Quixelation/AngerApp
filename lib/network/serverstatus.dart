import 'dart:async';

import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

enum ServerStatusState {
  online,
  offline,
  error,
  unknown,
}

class ServerStatus {
  final ServerStatusState status;
  final Duration? latency;
  ServerStatus({required this.status, this.latency});
}

Future<ServerStatus> fetchCmsServerStatus() async {
  var url = Uri.parse("${AppManager.directusUrl}/server/ping");
  var now = DateTime.now();
  http.Response response;
  try {
    response = await http.get(url);
  } catch (err) {
    return ServerStatus(
        status: ServerStatusState.offline, latency: const Duration());
  }

  if (response.statusCode == 200) {
    var responseTime = DateTime.now().difference(now);
    return ServerStatus(
        status: ServerStatusState.online, latency: responseTime);
  } else {
    var responseTime = DateTime.now().difference(now);
    return ServerStatus(status: ServerStatusState.error, latency: responseTime);
  }
}

var serverStatusSubject = BehaviorSubject<ServerStatus>.seeded(
    ServerStatus(status: ServerStatusState.unknown, latency: null));

Future<ServerStatus> loadServerStatus() async {
  var status = await fetchCmsServerStatus();
  serverStatusSubject.add(status);

  return status;
}

void startServerStatusUpdates() {
  loadServerStatus();
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    await loadServerStatus();
  });
}
