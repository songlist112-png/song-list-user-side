String supportErrorText(Object error) {
  final text = error.toString();
  for (final prefix in const ['Invalid argument(s): ', 'Bad state: ']) {
    if (text.startsWith(prefix)) return text.substring(prefix.length);
  }
  return 'Could not save your request. Please try again.';
}
