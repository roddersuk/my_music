Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, E Function(int index, T item) f) sync* {
  var index = 0;

  for (final item in items) {
    yield f(index, item);
    index = index + 1;
  }
}

void justWait({required int milliseconds}) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
}
