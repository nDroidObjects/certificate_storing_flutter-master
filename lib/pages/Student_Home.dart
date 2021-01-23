import 'dart:io';

import 'package:certificate_storage/main.dart';
import 'package:certificate_storage/models/user.dart';
import 'package:certificate_storage/pages/login_signup_page.dart';
import 'package:certificate_storage/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class StudentHome extends StatefulWidget {
  StudentHome({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  bool _isLoading = true;
  int imageToBeDeleted=-1;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  User currentUser;
  List<String> imageUrlList = [];
  var image;

  File imageFile;

  Future _getImage() async {
    try {
      imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
      StorageReference storageReference = FirebaseStorage.instance.ref().child(
          'certificates/${currentUser.id}/' + imageFile.path.split('/').last);
      StorageUploadTask uploadTask = storageReference.putFile(imageFile);
      uploadTask.onComplete.then((f) {
        print('File Uploaded');
        f.ref.getDownloadURL().then((url) {
          _database
              .reference()
              .child("certificatesPaths/" + currentUser.id)
              .push()
              .set({"url": url});
          setState(() {
            imageUrlList.add(url);
            _isLoading = false;
          });
        }).catchError((error) {
          setState(() {
            _isLoading = false;
          });
        });
      }).catchError(() {
        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = false;
    });
    currentUser = User.fromJson(sp.getString("currentUser"));
    getImageFromDB();
  }

  getImageFromDB() async {
    imageUrlList=[];
    _database
        .reference()
        .reference()
        .child("certificatesPaths")
        .child(currentUser.id)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values != null) {
        values.forEach((key, values) {
          imageUrlList.add(values["url"]);
        });
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          imageUrlList = [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return Center(
        child: CircularProgressIndicator(),
      );
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Certificate'),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: signOut)
        ],
      ),
      body: ListView(
        children: <Widget>[
          showAllImages(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                elevation: 5.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.blue,
                child: Text("Upload Certificate",
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _getImage();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  showAllImages() {
    if (imageUrlList == null || imageUrlList.length == 0) {
      return Container();
    }
    return SizedBox(
      height: 500.0,
      width: double.infinity,
      child: new ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: imageUrlList == null ? 0 : imageUrlList.length,
          itemBuilder: (BuildContext context, int i) => new Padding(
                padding: const EdgeInsets.all(5.0),
                child: (i < imageUrlList.length)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Image.network(
                            imageUrlList[i],
                            fit: BoxFit.fitWidth,
                            width: 300,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                              });
                              FirebaseStorage.instance.getReferenceFromUrl(imageUrlList[i]).then((storageRef) {
                                  _database.reference().reference().child("certificatesPaths").child(currentUser.id).once().then((DataSnapshot snapshot) {
                                    Map<dynamic, dynamic> values =
                                        snapshot.value;
                                    if (values != null) {
                                      values.forEach((key, values) {
                                        if (imageUrlList[i] == values["url"]) {
                                          _database.reference().reference().child("certificatesPaths").child(currentUser.id).child(key).remove().then((success) {
                                              storageRef.delete().then((success) {
                                                getImageFromDB();
                                              }).catchError((error) {
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              });
                                          })
                                          .catchError((error) {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          });
                                        }
                                      });
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  });
                              }).catchError((e) {
                                setState(() {
                                  _isLoading = false;
                                });
                              });
                            },
                            icon: Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      )
                    : Container(),
              )),
    );
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      sp.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginSignupPage(auth: new Auth())),
      );
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
}
