class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter vehicle number';
    }
    if (value.trim().length < 4) {
      return 'Vehicle number is too short';
    }
    return null;
  }

  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mobile number';
    }
    if (value.trim().length != 10) {
      return 'Mobile number must be 10 digits';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter amount';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount < 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    final number = int.tryParse(value);
    if (number == null || number < 0) {
      return 'Please enter a valid $fieldName';
    }
    return null;
  }

  static String? validatePasswordMatch(String? value, String password) {
    if (value == null || value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
