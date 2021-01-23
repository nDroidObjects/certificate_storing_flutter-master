import 'package:certificate_storage/main.dart';
import 'package:certificate_storage/pages/login_signup_page.dart';
import 'package:certificate_storage/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class TeacherHome extends StatefulWidget {
  TeacherHome({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _TeacherHomeState createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  final _formKey = new GlobalKey<FormState>();
  bool _isLoading=false;
  String _id;
  String _errorMessage="";
  List<String> imageUrlList=[];
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return Center(
        child: CircularProgressIndicator(),
      );
    return Scaffold(
        appBar: AppBar(
          title: Text("View Certificate"),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ],
        ),
        body:
        Container(
            child: Form(
                key: _formKey,
                child: ListView(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(20,10,20,10),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: new InputDecoration(
                                hintText: 'Student ID',
                                icon: new Icon(
                                  Icons.contact_mail,
                                  color: Colors.blue,
                                )
                            ),
                            validator: (value) =>
                            value.isEmpty || value == '' || value == ' '
                                ? 'Student ID can\'t be empty'
                                : null,
                            onSaved: (value) => _id = value.trim(),
                          )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            elevation: 5.0,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            color: Colors.blue,
                            child: Text("View Certificate",style: new TextStyle(fontSize: 20.0, color: Colors.white)),
                            onPressed: () {
                              setState(() {
                                _isLoading=true;
                              });
                              validateAndSubmit();
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(_errorMessage,style: TextStyle(color: Colors.red),)
                        ],
                      ),
                      showAllImages()
                    ])
            )
        )
    );
  }
  showAllImages()
  {
    return SizedBox(
      height: 400.0,
      width: double.infinity,
      child: new ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: imageUrlList==null? 0: imageUrlList.length,
          itemBuilder: (BuildContext context, int i) => new Padding(
            padding: const EdgeInsets.all(5.0),
            child: (i < imageUrlList.length) ? Image.network(
              imageUrlList[i],
              fit: BoxFit.fitWidth,
            ) : Container(),
          )),
    );
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      sp.clear();
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginSignupPage(auth: new Auth())),);
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  getImageFromDB() async
  {
    _database.reference().reference().child("certificatesPaths").child(_id).once().then((DataSnapshot snapshot){
      Map<dynamic,dynamic> values = snapshot.value;
      if(values!=null)
      {
        values.forEach((key,values) {
          imageUrlList.add(values["url"]);
        });
        setState(() {
          _errorMessage="";
          _isLoading=false;
        });
      }
      else
      {
        setState(() {
          if(imageUrlList.length==0)
          {
            _errorMessage="NotFound";
          }
          else
          {
            _errorMessage="";
          }
          imageUrlList=[];
          _isLoading=false;
        });
      }
    });
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        imageUrlList=[];
      });
      getImageFromDB();
    }
  }
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    else {
      setState(() {
        _isLoading=false;
      });
      return false;
    }
  }

}