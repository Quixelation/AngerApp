part of moodle;

class _MoodleException {
  final String exception;
  final String errorcode;
  final String message;
  _MoodleException(
      {required this.errorcode,
      required this.exception,
      required this.message});

  _MoodleException.fromApi(Map<String, dynamic> apiMap)
      : exception = apiMap["exception"],
        errorcode = apiMap["errorcode"],
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
    assert(hasError && error != null);
  }
}

Future<_MoodleResponse<Map<String, dynamic>>> _moodleRequest<E>({
  String? function,
  bool includeToken = true,
  bool includeUserId = true,
  required Map<String, String> parameters,
  String? customPath,
}) async {
  assert(function == null && customPath != null);
  assert(function != null && customPath == null);

  String encodeMap(Map data) {
    return data.keys
        .map((key) =>
            "${Uri.encodeComponent(key)}=${Uri.encodeComponent(data[key])}")
        .join("&");
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
      mapToEncode["wsfunction"] = userid.toString();
    }
  }

  if (customPath == null) {
    mapToEncode["wsfunction"] = function!;
  }
  mapToEncode["moodlewsrestformat"] = "json";

  var response = await http.post(Uri.parse((customPath != null
          ? (AppManager.moodleSiteUrl + customPath)
          : AppManager.moodleApi) +
      "?" +
      encodeMap({...mapToEncode, ...parameters})));

  if (response.statusCode != 200) {
    throw ErrorDescription("Status not OK");
  }

  var json = jsonDecode(response.body);

  if (json["exception"] != null) {
    return _MoodleResponse(
        data: null, hasError: true, error: _MoodleException.fromApi(json));
  } else {
    return _MoodleResponse(data: json, hasError: false);
  }
}
