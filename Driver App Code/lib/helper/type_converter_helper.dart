class TypeConverter {
  static bool getBool(dynamic value) {
    return value == true || value == 1 || value == '1' || value == 'true';
  }
}
