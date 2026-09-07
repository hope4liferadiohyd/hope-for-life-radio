class AuthValidators {
  const AuthValidators._();

  static String? requiredName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Enter your full name.';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    final parts = text.split('@');
    if (parts.length != 2 ||
        parts.first.isEmpty ||
        !parts.last.contains('.') ||
        parts.last.startsWith('.') ||
        parts.last.endsWith('.')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 8) {
      return 'Use at least 8 characters.';
    }
    return null;
  }
}
