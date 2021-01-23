import 'package:certificate_storage/pages/login_signup_page.dart';
import 'package:certificate_storage/pages/root_page.dart';
import 'package:certificate_storage/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


SharedPreferences sp;
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  sp = await SharedPreferences.getInstance();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Certificate Storage',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: RootPage(auth: new Auth())
    );
  }
}
