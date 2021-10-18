import 'package:flutter/material.dart';

// const String API_URL = "http://smartsociety.itfuturz.com/api/AppAPI/";
// const String IMG_URL = "http://smartsociety.itfuturz.com";

const String API_URL = "http://mywatcher.itfuturz.com/api/AppAPI/";
 String IMG_URL = "";
 String NODE_API = "";
String NODE_API_2 = "";
const Inr_Rupee = "₹";
const String Access_Token = "Mjdjhcbj43jkmsijkmjJKJKJoijlkmlkjo-HfdkvjDJjMoikjnNJn-JNFhukmk";
const Color appcolor = Color.fromRGBO(0, 171, 199, 1);
const Color secondaryColor = Color.fromRGBO(85, 96, 128, 1);

const String whatsAppLink = "https://wa.me/#mobile?text=#msg";

Map<int, Color> appprimarycolors = {
  50: Color.fromRGBO(114, 34, 169, .1),
  100: Color.fromRGBO(114, 34, 169, .2),
  200: Color.fromRGBO(114, 34, 169, .3),
  300: Color.fromRGBO(114, 34, 169, .4),
  400: Color.fromRGBO(114, 34, 169, .5),
  500: Color.fromRGBO(114, 34, 169, .6),
  600: Color.fromRGBO(114, 34, 169, .7),
  700: Color.fromRGBO(114, 34, 169, .8),
  800: Color.fromRGBO(114, 34, 169, .9),
  900: Color.fromRGBO(114, 34, 169, 1)
};

MaterialColor appPrimaryMaterialColor =
    MaterialColor(0xFF7222A9, appprimarycolors);

class MESSAGES {
  static const String INTERNET_ERROR = "No Internet Connection";
  static const String INTERNET_ERROR_RETRY =
      "No Internet Connection.\nPlease Retry";
}

class stringCollection {
  static const String EnterCode = "Enter Code";
  static const String FeqVisitor = "Freq Visitor";
  static const String Visitor = "Visitor";
}

class Session {
  static const String MemberId = "Id";
  static const String called = "called";
  static const String societyName = "societyName";
  static const String RoleId = "RoleId";
  static const String SocietyId = "SocietyId";
  static const String Name = "Name";
  static const String mobileNo = "mobileNo";
  static const String WingId = "WingId";
  static const String UserName = "UserName";
  static const String Password = "Password";
  static const String Role = "Role";
  static const String flateid = "flate";
}
