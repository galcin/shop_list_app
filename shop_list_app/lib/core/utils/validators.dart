class Validators {
  Validators._();

  static bool isNotEmpty(String? value) =>
      value != null && value.trim().isNotEmpty;

  static bool isPositiveNumber(num? value) => value != null && value > 0;

  static bool isValidDate(DateTime? date) => date != null;
}
