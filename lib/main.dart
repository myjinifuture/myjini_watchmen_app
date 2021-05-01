import 'package:easy_localization/easy_localization.dart';
import 'package:easy_permission_validator/easy_permission_validator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
//Component
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/join.dart';
import 'package:smartsocietystaff/Component/NotificationAnswerDialog.dart';
import 'package:smartsocietystaff/Screens/AddDocument.dart';
import 'package:smartsocietystaff/Screens/AddEvent.dart';
import 'package:smartsocietystaff/Screens/AddNotice.dart';
import 'package:smartsocietystaff/Screens/AddRules.dart';
import 'package:smartsocietystaff/Screens/AddVisitorForm.dart';
import 'package:smartsocietystaff/Screens/BalanceSheet.dart';
import 'package:smartsocietystaff/Screens/Complaints.dart';
import 'package:smartsocietystaff/Screens/Dashboard.dart';
import 'package:smartsocietystaff/Screens/Directory.dart';
import 'package:smartsocietystaff/Screens/Document.dart';
import 'package:smartsocietystaff/Screens/Emergency.dart';
import 'package:smartsocietystaff/Screens/Events.dart';
import 'package:smartsocietystaff/Screens/Expense.dart';
import 'package:smartsocietystaff/Screens/ExpenseByMonth.dart';
import 'package:smartsocietystaff/Screens/Income.dart';
import 'package:smartsocietystaff/Screens/IncomeByMonth.dart';
//Screens
import 'package:smartsocietystaff/Screens/Login.dart';
import 'package:smartsocietystaff/Screens/MemberProfile.dart';
import 'package:smartsocietystaff/Screens/Notice.dart';
import 'package:smartsocietystaff/Screens/Polling.dart';
import 'package:smartsocietystaff/Screens/SOSpage.dart';
import 'package:smartsocietystaff/Screens/Splash.dart';
import 'package:smartsocietystaff/Screens/Staff.dart';
import 'package:smartsocietystaff/Screens/StaffInOut.dart';
import 'package:smartsocietystaff/Screens/Visitor.dart';
import 'package:smartsocietystaff/Screens/VisitorHistoryList.dart';
import 'package:smartsocietystaff/Screens/WatchmanDashboard.dart';
import 'package:vibration/vibration.dart';

import 'Screens/AddAMC.dart';
import 'Screens/AddExpense.dart';
import 'Screens/AddIncome.dart';
import 'Screens/AddPolling.dart';
import 'Screens/AddStaff.dart';
import 'Screens/CallSocietyMembers.dart';
import 'Screens/FromMemberScreen.dart';
import 'Screens/RulesAndRegulations.dart';
import 'Screens/StaffList.dart';
import 'Screens/amcList.dart';
import 'Screens/watchmanVisitorList.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  OneSignal.shared.init(
    "ee47c5c3-6bc9-427a-93c7-2b037f8c0e64",
    iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: false,
    },

  );
  runApp(EasyLocalization(child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String Title;
  String bodymessage;

  var playerId;
  void _handleSendNotification() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();

    playerId = status.subscriptionStatus.userId;
    print("playerid");
    print(playerId);
  }

  Future<void> initOneSignalNotification() async {
    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      // will be called whenever a notification is received
      print("Received body");
      //print(notification.jsonRepresentation().replaceAll("\\n", "\n"));
      print(notification.payload.body);
      print("Received title");
      //print(notification.jsonRepresentation().replaceAll("\\n", "\n"));
      print(notification.payload.title);
      print("Received sound");
      //print(notification.jsonRepresentation().replaceAll("\\n", "\n"));
      print(notification.payload.sound);
      print("received notification.payload.additionalData");
      print(notification.payload.additionalData);
      dynamic data = notification.payload.additionalData;
      // if (data["NotificationType"] == 'VisitorAccepted') {
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) =>
      //               NotificationAnswerDialog(data,VisitorAccepted:"VisitorAccepted")));
      // }
      // else if (data["NotificationType"] == 'VisitorRejected') {
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) =>
      //               NotificationAnswerDialog(data,VisitorAccepted:"VisitorRejected")));
      // }
      // else if(data["CallResponseIs"] == 'Rejected') {
      //   Get.to(FromMemberScreen(rejected: "Rejected",));
      //   // audioCache.play('Sound.mp3');
      //   //for vibration
      //   // Vibration.vibrate(
      //   // duration: 15000,
      //   // );
      // }
      // else if (data["NotificationType"] == 'VisitorAccepted') {
      //   Get.to(NotificationAnswerDialog(data,VisitorAccepted:"VisitorAccepted"));
      //   // audioCache.play('Sound.mp3');
      //   //for vibration
      //   // Vibration.vibrate(
      //   //   duration: 15000,
      //   // );
      // }
      // else if (data["NotificationType"] == 'VisitorRejected') {
      //   Get.to(NotificationAnswerDialog(data,VisitorAccepted:"VisitorRejected"));
      //   // audioCache.play('Sound.mp3');
      //   //for vibration
      //   // Vibration.vibrate(
      //   //   duration: 15000,
      //   // );
      // }
      // else if(data["NotificationType"] == 'VoiceCall') {
      //   Get.to(JoinPage(entryIdWhileGuestEntry: data["CallingId"],voicecall : data["NotificationType"]));        // audioCache.play('Sound.mp3');
      //   //for vibration
      //   // Vibration.vibrate(
      //   //   duration: 15000,
      //   // );
      // }
      // else if (data["NotificationType"]== 'VideoCalling') {
      //   Get.to(JoinPage(entryIdWhileGuestEntry:data["VisitorEntryId"],data: data,CallingId:data["CallingId"]));
      //   // audioCache.play('Sound.mp3');
      //   //for vibration
      //   // Vibration.vibrate(
      //   //   duration: 15000,
      //   // );
      // }
      // else if (data["NotificationType"] == 'UnknownVisitor') {
      //   if(data["CallStatus"] == "Accepted") {
      //     Get.to(JoinPage(
      //       // entryIdWhileGuestEntry: message["data"]["VisitorEntryId"],
      //       // data: message["data"],
      //       // CallingId:message["data"]["CallingId"],
      //       unknownVisitorEntryId: data["EntryId"],
      //     ),
      //     );
      //   }
      //   else{
      //     Get.to(NotificationAnswerDialog(data));
      //   }
      //   // audioCache.play('Sound.mp3');
      //   //for vibration
      //   // Vibration.vibrate(
      //   //   duration: 15000,
      //   // );
      // }
      // else if (data["NotificationType"] == 'Visitor') {
      //   Get.to(
      //     JoinPage(
      //       entryIdWhileGuestEntry: data["VisitorEntryId"],
      //       data: data,
      //       CallingId:data["CallingId"],
      //     ),
      //   );
      //   // audioCache.play('Sound.mp3');
      //   //for vibration
      //   // Vibration.vibrate(
      //   //   duration: 15000,
      //   // );
      // }
      // else if (data["Type"] == 'Accepted') {
      //   Get.to(JoinPage());
      //   // audioCache.play('Sound.mp3');
      //   //for vibration
      //   // Vibration.vibrate(
      //   //   duration: 15000,
      //   // );
      // }
      //
      // else {
      //   Get.to(NotificationAnswerDialog(data));
      // }
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      // will be called whenever the permission changes
      // (ie. user taps Allow on the permission prompt in iOS)
      print("PERMISSION STATE CHANGED");
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      // will be called whenever the subscription changes
      //(ie. user gets registered with OneSignal and gets a user ID)
    });

    OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges emailChanges) {
      // will be called whenever then user's email subscription changes
      // (ie. OneSignal.setEmail(email) is called and the user gets registered
    });
  }

  @override
  void initState() {
    initOneSignalNotification();
    _handleSendNotification();
    // _firebaseMessaging.configure(
    //     onMessage: (Map<String, dynamic> message) async{
    //   print("onMessage");
    //   print(message);
    //   Title = message["notification"]["title"];
    //   bodymessage = message["notification"]["body"];
    //        if(message["data"]["CallResponseIs"] == 'Rejected') {
    //       print('message["data"]');
    //       print(message["data"]);
    //       Get.to(FromMemberScreen(rejected: "Rejected",));
    //       // audioCache.play('Sound.mp3');
    //       //for vibration
    //       // Vibration.vibrate(
    //       // duration: 15000,
    //       // );
    //       }
    //        else if (message["data"]["NotificationType"] == 'VisitorAccepted') {
    //          print('message["data"]');
    //          print(message["data"]);
    //          Get.to(NotificationAnswerDialog(message,VisitorAccepted:"VisitorAccepted"));
    //          // audioCache.play('Sound.mp3');
    //          //for vibration
    //          // Vibration.vibrate(
    //          //   duration: 15000,
    //          // );
    //        }
    //        else if (message["data"]["NotificationType"] == 'VisitorRejected') {
    //          print('message["data"]');
    //          print(message["data"]);
    //          Get.to(NotificationAnswerDialog(message,VisitorAccepted:"VisitorRejected"));
    //          // audioCache.play('Sound.mp3');
    //          //for vibration
    //          // Vibration.vibrate(
    //          //   duration: 15000,
    //          // );
    //        }
    //   else if(message["data"]["NotificationType"] == 'VoiceCall') {
    //     print('message["data"]');
    //     print(message["data"]);
    //     Get.to(JoinPage(entryIdWhileGuestEntry: message["data"]["CallingId"],voicecall : message["data"]["NotificationType"]));        // audioCache.play('Sound.mp3');
    //     //for vibration
    //     // Vibration.vibrate(
    //     //   duration: 15000,
    //     // );
    //   }
    //   else if (message["data"]["NotificationType"] == 'VideoCalling') {
    //     print('message["data"]');
    //     print(message["data"]);
    //     Get.to(JoinPage(entryIdWhileGuestEntry: message["data"]["VisitorEntryId"],data: message["data"],CallingId:message["data"]["CallingId"]));
    //     // audioCache.play('Sound.mp3');
    //     //for vibration
    //     // Vibration.vibrate(
    //     //   duration: 15000,
    //     // );
    //   }
    //        else if (message["data"]["notificationType"] == 'UnknownVisitor') {
    //          print('message["data"]');
    //          print(message["data"]);
    //          if(message["data"]["CallStatus"] == "Accepted") {
    //            Get.to(JoinPage(
    //              // entryIdWhileGuestEntry: message["data"]["VisitorEntryId"],
    //              // data: message["data"],
    //              // CallingId:message["data"]["CallingId"],
    //              unknownVisitorEntryId: message["data"]["EntryId"],
    //            ),
    //            );
    //          }
    //          else{
    //            Get.to(NotificationAnswerDialog(message));
    //          }
    //          // audioCache.play('Sound.mp3');
    //          //for vibration
    //          // Vibration.vibrate(
    //          //   duration: 15000,
    //          // );
    //        }
    //        else if (message["data"]["NotificationType"] == 'Visitor') {
    //          print('message["data"]');
    //          print(message["data"]);
    //          Get.to(
    //              JoinPage(
    //                  entryIdWhileGuestEntry: message["data"]["VisitorEntryId"],
    //                  data: message["data"],
    //                  CallingId:message["data"]["CallingId"],
    //              ),
    //          );
    //          // audioCache.play('Sound.mp3');
    //          //for vibration
    //          // Vibration.vibrate(
    //          //   duration: 15000,
    //          // );
    //        }
    //   else if (message["data"]["Type"] == 'Accepted') {
    //     print('message["data"]');
    //     print(message["data"]);
    //     Get.to(JoinPage());
    //     // audioCache.play('Sound.mp3');
    //     //for vibration
    //     // Vibration.vibrate(
    //     //   duration: 15000,
    //     // );
    //   }
    //
    //   else {
    //     Get.to(NotificationAnswerDialog(message));
    //   }
    // },
    //     onResume: (Map<String, dynamic> message) async{
    //       print("onMessage");
    //       print(message);
    //       Title = message["notification"]["title"];
    //       bodymessage = message["notification"]["body"];
    //       if(message["data"]["CallResponseIs"] == 'Rejected') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(FromMemberScreen(rejected: "Rejected",));
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         // duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["NotificationType"] == 'VisitorAccepted') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(NotificationAnswerDialog(message,VisitorAccepted:"VisitorAccepted"));
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["NotificationType"] == 'VisitorRejected') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(NotificationAnswerDialog(message,VisitorAccepted:"VisitorRejected"));
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if(message["data"]["NotificationType"] == 'VoiceCall') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(JoinPage(entryIdWhileGuestEntry: message["data"]["CallingId"],voicecall : message["data"]["NotificationType"]));        // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["NotificationType"] == 'VideoCalling') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(JoinPage(entryIdWhileGuestEntry: message["data"]["VisitorEntryId"],data: message["data"],CallingId:message["data"]["CallingId"]));
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["notificationType"] == 'UnknownVisitor') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         if(message["data"]["CallStatus"] == "Accepted") {
    //           Get.to(JoinPage(
    //             // entryIdWhileGuestEntry: message["data"]["VisitorEntryId"],
    //             // data: message["data"],
    //             // CallingId:message["data"]["CallingId"],
    //             unknownVisitorEntryId: message["data"]["EntryId"],
    //           ),
    //           );
    //         }
    //         else{
    //           Get.to(NotificationAnswerDialog(message));
    //         }
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["NotificationType"] == 'Visitor') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(
    //           JoinPage(
    //             entryIdWhileGuestEntry: message["data"]["VisitorEntryId"],
    //             data: message["data"],
    //             CallingId:message["data"]["CallingId"],
    //           ),
    //         );
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["Type"] == 'Accepted') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(JoinPage());
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //
    //       else {
    //         Get.to(NotificationAnswerDialog(message));
    //       }
    //     },
    //     onLaunch: (Map<String, dynamic> message) async{
    //       print("onMessage");
    //       print(message);
    //       Title = message["notification"]["title"];
    //       bodymessage = message["notification"]["body"];
    //       if(message["data"]["CallResponseIs"] == 'Rejected') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(FromMemberScreen(rejected: "Rejected",));
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         // duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["NotificationType"] == 'VisitorAccepted') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(NotificationAnswerDialog(message,VisitorAccepted:"VisitorAccepted"));
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["NotificationType"] == 'VisitorRejected') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(NotificationAnswerDialog(message,VisitorAccepted:"VisitorRejected"));
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if(message["data"]["NotificationType"] == 'VoiceCall') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(JoinPage(entryIdWhileGuestEntry: message["data"]["CallingId"],voicecall : message["data"]["NotificationType"]));        // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["NotificationType"] == 'VideoCalling') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(JoinPage(entryIdWhileGuestEntry: message["data"]["VisitorEntryId"],data: message["data"],CallingId:message["data"]["CallingId"]));
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["notificationType"] == 'UnknownVisitor') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         if(message["data"]["CallStatus"] == "Accepted") {
    //           Get.to(JoinPage(
    //             // entryIdWhileGuestEntry: message["data"]["VisitorEntryId"],
    //             // data: message["data"],
    //             // CallingId:message["data"]["CallingId"],
    //             unknownVisitorEntryId: message["data"]["EntryId"],
    //           ),
    //           );
    //         }
    //         else{
    //           Get.to(NotificationAnswerDialog(message));
    //         }
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["NotificationType"] == 'Visitor') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(
    //           JoinPage(
    //             entryIdWhileGuestEntry: message["data"]["VisitorEntryId"],
    //             data: message["data"],
    //             CallingId:message["data"]["CallingId"],
    //           ),
    //         );
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //       else if (message["data"]["Type"] == 'Accepted') {
    //         print('message["data"]');
    //         print(message["data"]);
    //         Get.to(JoinPage());
    //         // audioCache.play('Sound.mp3');
    //         //for vibration
    //         // Vibration.vibrate(
    //         //   duration: 15000,
    //         // );
    //       }
    //
    //       else {
    //         Get.to(NotificationAnswerDialog(message));
    //       }
    //     },
    // );

    //For Ios Notification
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Setting reqistered : $settings");
    });

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings);
    final permissionValidator = EasyPermissionValidator(
      context: context,
      appName: 'Easy Permission Validator',
    );
    permissionValidator.microphone();
  }

  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
      data: data,
      child: MaterialApp(
        navigatorKey: Get.key,
        debugShowCheckedModeBanner: false,
        title: 'MYJINI Staff',
        initialRoute: '/',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          EasyLocalizationDelegate(
            locale: data.locale,
            path: 'resources/langs',
          ),
        ],
        supportedLocales: [
          Locale('en', 'US'),
          Locale('hi', 'IN'),
          Locale('gu', 'IN'),
          Locale('mr', 'IN')
        ],
        locale: data.savedLocale,
        routes: {
          '/': (context) => Splash(),
          '/Login': (context) => Login(),
          '/Dashboard': (context) => Dashboard(),
          '/WatchmanDashboard': (context) => WatchmanDashboard(),
          '/AddNotice': (context) => AddNotice(),
          '/AddDocument': (context) => AddDocument(),
          '/Directory': (context) => Directory(),
          '/Notice': (context) => Notice(),
          '/Document': (context) => Document(),
          '/Visitor': (context) => Visitor(),
          '/Staff': (context) => Staff(),
          '/RulesAndRegulations': (context) => RulesAndRegulations(),
          '/AddRules': (context) => AddRules(),
          '/Complaints': (context) => Complaints(),
          '/MemberProfile': (context) => MemberProfile(),
          '/Emergency': (context) => Emergency(),
          '/Events': (context) => Events(),
          '/AddEvent': (context) => AddEvent(),
          '/Income': (context) => Income(),
          '/CallSocietyMembers': (context) => CallSocietyMembers(),
          '/Expense': (context) => Expense(),
          '/BalanceSheet': (context) => BalanceSheet(),
          '/ExpenseByMonth': (context) => ExpenseByMonth(),
          '/IncomeByMonth': (context) => IncomeByMonth(),
          '/AddIncome': (context) => AddIncome(),
          '/AddExpense': (context) => AddExpense(),
          '/Polling': (context) => Polling(),
          '/AddPolling': (context) => AddPolling(),
          '/AddVisitorForm': (context) => AddVisitorForm(),
          '/AddStaff': (context) => AddStaff(),
          '/StaffList': (context) => StaffList(),
          '/amcList': (context) => amcList(),
          '/AddAMC': (context) => AddAMC(),
          '/visitorlist': (context) => visitorlist(),
          '/VisitorHistoryList': (context) => VisitorHistoryList(),
          '/StaffInOut': (context) => StaffInOut(),
          '/SOSpage': (context) => SOSpage(),
        },
        theme: ThemeData(
          fontFamily: 'Montserrat',
          primarySwatch: appPrimaryMaterialColor,
          accentColor: appPrimaryMaterialColor,
          buttonColor: Colors.deepPurple,
        ),
      ),
    );
  }

  showNotification(String title, String body) async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max, playSound: false);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, '$title', '$body', platform,
        payload: 'MYJINI');
  }
}
