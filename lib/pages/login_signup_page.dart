import 'dart:convert';

import 'package:certificate_storage/main.dart';
import 'package:certificate_storage/models/user.dart';
import 'package:certificate_storage/pages/Student_Home.dart';
import 'package:certificate_storage/pages/TeacherHome.dart';
import 'package:certificate_storage/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = new GlobalKey<FormState>();
  final FirebaseDatabase _database = FirebaseDatabase.instance;


  List<String> _roles=["Student","Teacher"];

  String _email;
  String _password;
  String _name;
  String _role;
  String _errorMessage;

  String userId = "";

  bool _isLoginForm;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      try {
        if (_isLoginForm) {
          userId = await widget.auth.signIn(_email, _password);
          getUserById(userId);
        } else {
          userId = await widget.auth.signUp(_email, _password);
          addNewUser(userId);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          if(e.message=="The email address is already in use by another account.")
            {
              _errorMessage="Id already in use";
            }
          else if(e.message== "The email address is badly formatted.")
            {
              _errorMessage="Invalid Id";
            }
          else
            {
              _errorMessage = e.message;
            }
//          _formKey.currentState.reset();
        });
      }
    }
    else
      {
        _isLoading=false;
      }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    _role=_roles[0];
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Certificate Storage'),
        ),
        body: Stack(
          children: <Widget>[
            _showForm(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              showRoleDropdown(),
              showNameInput(),
              showEmailInput(),
              showPasswordInput(),
              showErrorMessage(),
              showPrimaryButton(),
              showSecondaryButton(),
            ],
          ),
        ));
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return
        Padding(
          padding: EdgeInsets.all(10),
          child:             Text(
            _errorMessage,
            style: TextStyle(
                fontSize: 20.0,
                color: Colors.red,
                height: 1.0,
                fontWeight: FontWeight.w300),
          ),
        );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget showRoleDropdown() {
    if(_isLoginForm==true)
      return Container();
    else return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 15.0, 30.0, 0.0),
      child:DropdownButton(
        value: this._role,
        onChanged: (newValue) {
          setState(() {
            _role = newValue;
          });
        },
        items: _roles.map((type) {
          return DropdownMenuItem(
            child: new Text(type.toString()),
            value: type.toString(),
          );
        }).toList(),
      ),
    );
  }


  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'ID',
            icon: new Icon(
              Icons.contact_mail,
              color: Colors.blue,
            )),
        validator: (value) => value.isEmpty  || value=='' || value == ' ' ? 'ID can\'t be empty' : null,
        onSaved: (value) => _email = value.trim()+"@gmail.com",
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.blue,
            )),
        validator: (value) => value.isEmpty  || value=='' || value == ' ' ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showNameInput() {
    if(_isLoginForm==true)
      return Container();
    else return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Name',
            icon: new Icon(
              Icons.person,
              color: Colors.blue,
            )),
        validator: (value) => value.isEmpty || value=='' || value == ' ' ? 'Name can\'t be empty' : null,
        onSaved: (value) => _name = value.trim(),
      ),
    );
  }

  Widget showSecondaryButton() {
    return new FlatButton(
        child: new Text(
            _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blue)),
        onPressed: toggleFormMode);
  }

  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text(_isLoginForm ? 'Login' : 'Create account',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: validateAndSubmit,
          ),
        )
    );
  }

  addNewUser(String uid) {
    if (uid.length > 0) {
      User user = new User();
      user.id=_email.split("@")[0];
      user.name=_name;
      user.role=_role;
      user.uid=userId;
      _database.reference().child("users").push().set(user.toJson());
      setState(() {
        _isLoginForm=!_isLoginForm;
        _isLoading=false;
      });
    }
  }

  getUserById(String userId){
    _database.reference().reference().child("users").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      if(values!=null)
        {      values.forEach((key,values) {
          if(userId==values["uid"])
          {
            User user = new User();
            user.id=values["id"];
            user.name=values["name"];
            user.role=values["role"];
            user.uid=values["uid"];

            sp.setString("currentUser",jsonEncode(user.toJson()).toString());
            if(values["role"]=="Student")
            {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => StudentHome(auth: new Auth())),);
            }
            else if(values["role"]=="Teacher")
            {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => TeacherHome(auth: new Auth())),);
            }
          }
        });
        }
    });
  }
}

