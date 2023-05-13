part of opensense;

class _OpenSenseSensor {
  late final String id;
  late final _OpenSenseLastMeasurement lastMeasurement;
  late final String sensorType;
  late final String title;
  late final String unit;

  _OpenSenseSensor.fromApiMap(Map<String, dynamic> apiData) {
    id = apiData["_id"];
    lastMeasurement =
        _OpenSenseLastMeasurement.fromApiMap(apiData["lastMeasurement"]);
    sensorType = apiData["sensorType"];
    title = apiData["title"];
    unit = apiData["unit"];
  }
}

class _OpenSenseLastMeasurement {
  late final double value;
  late final DateTime createdAt;
  _OpenSenseLastMeasurement.fromApiMap(Map<String, dynamic> apiData) {
    value = double.parse(apiData["value"]);
    createdAt = DateTime.parse(apiData["createdAt"]);
  }
}

class _OpenSenseFullData {
  late final String id;
  late final DateTime createdAt;
  late final DateTime updatedAt;
  late final DateTime lastMeasurementAt;
  late final String exposure;
  late final String name;
  late final String model;
  late final _OpenSenseCurrentLocation currentLocation;
  late final List<_OpenSenseSensor> sensors;

  _OpenSenseFullData.fromApiMap(Map<String, dynamic> apiData) {
    id = apiData["_id"];
    createdAt = DateTime.parse(apiData["createdAt"]);
    updatedAt = DateTime.parse(apiData["updatedAt"]);
    lastMeasurementAt = DateTime.parse(apiData["lastMeasurementAt"]);
    currentLocation =
        _OpenSenseCurrentLocation.fromApiMap(apiData["currentLocation"]);
    exposure = apiData["exposure"];
    model = apiData["model"];
    sensors = (apiData["sensors"] as List<dynamic>)
        .map((e) => _OpenSenseSensor.fromApiMap(e))
        .toList();
    name = apiData["name"];
  }
}

class _OpenSenseCurrentLocation {
  late final DateTime timestamp;
  late final List<double> coordinates;
  late final String type;
  _OpenSenseCurrentLocation.fromApiMap(Map<String, dynamic> apiData) {
    timestamp = DateTime.parse(apiData["timestamp"]);

    coordinates = [
      apiData["coordinates"][0] as double,
      apiData["coordinates"][1] as double
    ];
    type = apiData["type"];
  }
}

class _OpenSenseHistoricalData {
  late final double value;
  late final List<double> location;
  late final DateTime createdAt;
  _OpenSenseHistoricalData.fromApiMap(Map<String, dynamic> apiData) {
    value = double.parse(apiData["value"]);
    location = [
      apiData["location"][0] as double,
      apiData["location"][1] as double
    ];
    createdAt = DateTime.parse(apiData["createdAt"]);
  }
}
