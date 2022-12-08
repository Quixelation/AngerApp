extension MapWithIndex<E> on List {
  List<T> mapWithIndex<T, E>(T Function(E element, int index) cb) {
    List<T> mapList = [];
    for (var i = 0; i < this.length; i++) {
      mapList.add(cb(this[i], i));
    }
    return mapList;
  }
}

extension DateExt on DateTime {
  DateTime get at0 {
    return DateTime(year, month, day, 0, 0, 0, 0, 0);
  }

  bool isSameOrAfterDateAt0(DateTime date2) {
    var datified = date2.at0;
    return isAtSameMomentAs(datified) || isAfter(datified);
  }

  bool isSameOrBeforeDateAt0(DateTime date2) {
    var datified = date2.at0;
    return isAtSameMomentAs(datified) || isBefore(datified);
  }
}
