import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:mycustomers/core/constants/hive_boxes.dart';
import 'package:mycustomers/ui/shared/const_color.dart';

part 'password_manager_services.g.dart';
@HiveType(typeId: 1, adapterName: 'PasswordManagerAdapter')

class PasswordManager{
  @HiveField(0)
  final String userPassword;

  PasswordManager(this.userPassword);

}

class PasswordManagerService{

    static final  key = Key.fromLength(32);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    static final keyStore = _randomValue();


  Future<void>saveSetPin(String password) async{
    final passwordManagerBox = await Hive.openBox(HiveBox.passwordManagerBoxName);
    final encryptedPassword = encryptPassword(password);
    passwordManagerBox.put(key,encryptedPassword);
    var pass = passwordManagerBox.get(keyStore);
    print(pass);


  }

   // a function to genrate random keys for the pin entered by users
 static String _randomValue() {
    final rand = Random();
    final codeUnits = List.generate(20, (index) {
      return rand.nextInt(26) + 65;
    });

    return String.fromCharCodes(codeUnits);
  }


  //This function display a success message upon completion of setting pin
  void showPinSetConfirmationMessage(){
    FlutterToast.showToast(
      msg: 'Pin was set Successfully',
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: BrandColors.yellow,
      textColor: ThemeColors.background,
      gravity: ToastGravity.CENTER

      );
  }

  void showPinRemoveConfirmationMessage(){
    FlutterToast.showToast(
      msg: 'Pin removed Successfully',
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: BrandColors.yellow,
      textColor: ThemeColors.background,
      gravity: ToastGravity.CENTER

      );
  }


  void showErrorMessage(){
    FlutterToast.showToast(
      msg: 'An error occured while setting pin',
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: BrandColors.secondary,
      textColor: ThemeColors.background,
      gravity: ToastGravity.CENTER
      );
  }

  void showRemoveErrorMessage(){
    FlutterToast.showToast(
      msg: 'Wrong pin ! Try again.',
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: BrandColors.secondary,
      textColor: ThemeColors.background,
      gravity: ToastGravity.CENTER
      );
  }

  String encryptPassword(String value){

    final encrypted = encrypter.encrypt(value, iv: iv);
    return encrypted.toString();

  }

  String decryptPassword(var value){
    final decrypted = encrypter.decrypt(value, iv: iv);
    return decrypted;
}

Future<String> getPassword() async{
  final passwordManagerBox = await Hive.openBox(HiveBox.passwordManagerBoxName);
  final pass = passwordManagerBox.get(keyStore);
   return decryptPassword(pass);
}

Future<void> deleteSetPin() async{
   final passwordManagerBox = await Hive.openBox(HiveBox.passwordManagerBoxName);
   passwordManagerBox.delete(keyStore);
}
}