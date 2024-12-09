O Function(I) cached<I, O>(O Function(I) fn) {
  O? value;
  I? prevArg;

  return (I arg) {
    if (arg != prevArg) {
      value = fn(arg);
      prevArg = arg;
    }

    return value!;
  };
}
