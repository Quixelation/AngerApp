extension MapWithIndex<E> on List {
  List<T> mapWithIndex<T>(T Function(E element, int index) cb) {
    List<T> mapList = [];
    for (var i = 0; i < this.length; i++) {
      mapList.add(cb(this[i], i));
    }
    return mapList;
  }
}
