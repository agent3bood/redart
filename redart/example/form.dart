import 'dart:async';

import 'package:redart/redart.dart';

class Form with ControllerUtils {
  @Re()
  String _firstName = '';

  @Re()
  String _lastName = '';

  @Re()
  String _email = '';

  @Re()
  String _password = '';
  //
  // String get name {
  //   return '$firstName $lastName';
  // }
  //
  // @Re()
  bool get firstNameValid {
    return firstName.isNotEmpty;
  }
  //
  // @Re()
  bool get lastNameValid {
    return lastName.isNotEmpty;
  }
  //
  // @Re()
  bool get emailValid {
    return email.isNotEmpty && email.contains('@');
  }
  //
  // @Re()
  bool get passwordValid {
    return password.isNotEmpty && password.length > 6;
  }
  //
  // @Re()
  bool get formValid {
    return firstNameValid && lastNameValid && emailValid && passwordValid;
  }

  @override
  String toString() {
    return 'Form{firstName: $firstName, lastName: $lastName, email: $email, password: $password, valid: $formValid firstNameValid: $firstNameValid lastNameValid: $lastNameValid emailValid: $emailValid passwordValid: $passwordValid}';
  }
}

void main() async {
  final form = Form();
  final dispose = listen(() {
    print(form);
  });

  // input values
  form.firstName = 'John';

  // tick to auto update the form's reactive fields
  await Future.delayed(Duration.zero);

  // input all valid values
  form.lastName = 'Doe';
  form.email = 'john.doe@example.con';
  form.password = 'password!!2';

  // tick to auto update the form's reactive fields
  await Future.delayed(Duration.zero);

  // end
  dispose();
}
