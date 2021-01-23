import 'dart:async';
import 'package:certificate_storage/main.dart';
import 'package:certificate_storage/models/user.dart';
import 'package:certificate_storage/pages/Student_Home.dart';
import 'package:certificate_storage/pages/TeacherHome.dart';
import 'package:certificate_storage/pages/login_signup_page.dart';
import 'package:certificate_storage/services/authentication.dart';
import 'package:flutter/material.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), (){
      if((sp.getString('currentUser'))!=null && (sp.getString('currentUser'))!="")
      {
        User currentUser = User.fromJson(sp.getString('currentUser'));
        if(currentUser==null)
        {
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginSignupPage(auth: new Auth())),);
        }
        else
        {
          if(currentUser!=null)
          {
            if(currentUser.role=="Student")
            {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => StudentHome(auth: new Auth())),);
            }
            else if(currentUser.role=="Teacher")
            {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => TeacherHome(auth: new Auth())),);
            }
          }
        }
      }
      else
      {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginSignupPage(auth: new Auth())),);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
          child:           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Certificate Storage",style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.blue))
            ],
          )

          )
        ],
      ),
    );
  }
}