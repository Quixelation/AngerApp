part of moodle;

class _MoodleException {
  final String? exception;
  final String? errorcode;
  final String? message;
  final String? error;
  _MoodleException(
      {required this.errorcode,
      required this.exception,
      required this.error,
      required this.message});

  _MoodleException.fromApi(Map<String, dynamic> apiMap)
      : exception = apiMap["exception"],
        errorcode = apiMap["errorcode"],
        error = apiMap["error"],
        message = apiMap["message"];
}

class _MoodleResponse<E> {
  final bool hasError;
  final _MoodleException? error;
  final E? data;

  _MoodleResponse({
    this.error,
    required this.data,
    required this.hasError,
  }) {
    if (hasError) {
      assert(error != null);
    } else {
      assert(error == null);
    }
  }
}

Future<_MoodleResponse<dynamic>> _moodleRequest<E>({
  String? function,
  bool includeToken = true,
  bool includeUserId = true,
  Map<String, String>? parameters,
  String? customPath,
}) async {
  if (function == null) {
    assert(customPath != null);
  } else {
    assert(customPath == null);
  }

  String encodeMap(Map data) {
    return data.keys
        .map((key) => "$key=${Uri.encodeComponent(data[key])}")
        .join("&");
  }

  Map<String, String> encodeToMap(Map data) {
    Map<String, String> finalMap = {};
    for (var key in data.keys) {
      finalMap[key] = Uri.encodeComponent(data[key]);
    }

    return finalMap;
  }

  var token = AngerApp.moodle.login.creds.subject.valueWrapper?.value?.token;
  var userid = AngerApp.moodle.login.creds.subject.valueWrapper?.value?.userId;

  Map<String, String> mapToEncode = {};

  if (includeToken) {
    if (token == null) {
      throw ErrorDescription("no token");
    } else {
      mapToEncode["wstoken"] = token;
    }
  }
  if (includeUserId) {
    if (userid == null) {
      throw ErrorDescription("no userid");
    } else {
      mapToEncode["userid"] = userid.toString();
    }
  }

  if (customPath == null) {
    mapToEncode["wsfunction"] = function!;
  }
  mapToEncode["moodlewsrestformat"] = "json";

  var encodedMap = {...mapToEncode, ...encodeToMap(parameters ?? {})};

  logger.v(encodedMap);

  var uri = Uri.https(
      AppManager.moodleSiteHost,
      (customPath != null ? customPath : AppManager.moodleApiPath),
      {...mapToEncode, ...(parameters ?? {})});

  logger.v(uri);

  var response = await http.post(uri);

  if (response.statusCode != 200) {
    throw ErrorDescription("Status not OK");
  }

  var json = jsonDecode(response.body);
  logger.v(json);
  if ((json is! List) && (json["error"] != null || json["exception"] != null)) {
    return _MoodleResponse(
        data: null, hasError: true, error: _MoodleException.fromApi(json));
  } else {
    return _MoodleResponse(data: json, hasError: false);
  }
}
