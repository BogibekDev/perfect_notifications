enum Importance {
  none(0),
  min(1),
  low(2),
  def(3),
  high(4),
  max(5),
  unspecified(-1000);

  final int value;
  const Importance(this.value);
}
