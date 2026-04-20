class FormValidator{

  static bool isValidEmail(String email){
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  static bool isValidPassword(String password, {int minLength = 6}) {
    return password.trim().length >= minLength;
  }

  static bool isValidName(String name, {int minLength = 4}) {
    return name.trim().length >= minLength;
  }

  static bool isValidPhone(String phone, {int minLength = 7}) {
    return RegExp(r'^\d+$').hasMatch(phone.trim()) && phone.trim().length >= minLength;
  }

}