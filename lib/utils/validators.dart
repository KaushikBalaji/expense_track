class InputValidators {
  static String? Validate(String input, String type) {
    switch (type) {
      case 'email':
        if (input.trim().isEmpty) return 'Email is required';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input)) {
          return 'Enter a valid email';
        }
        return null;

      case 'passwd':
        if (input.isEmpty) return 'Password is required';
        if (input.length < 6) return 'Password must be at least 6 characters';
        return null;

      case 'name':
        if (input.trim().isEmpty) return 'Name is required';
        return null;

      default:
        return null;
    }
  }
}
