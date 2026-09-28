String formatDuration(Duration duration) {
  String two(int num) => num.toString().padLeft(2, '0');
  final hour = duration.inHours;
  final minute = two(duration.inMinutes.remainder(60));
  final second = two(duration.inSeconds.remainder(60));
  return hour > 0 ? '$hour:$minute:$second' : '$minute:$second';
}
