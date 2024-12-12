extension ClampNaN<T extends num> on T {
  T clampNaN(T min, T max) {
    if (isNaN) return min;
    return clamp(min, max) as T;
  }
}

extension FormatDuration on Duration {
  String format() {
    if (this > Duration(hours: 1)) {
      final hours = inHours.toString().padLeft(2, '0');
      final minutes = (inMinutes - (inHours * 60)).toString().padLeft(2, '0');
      final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    } else {
      final minutes = inMinutes.toString().padLeft(2, '0');
      final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }
  }
}
