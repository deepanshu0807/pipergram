import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pipergram/models/user.dart';
import 'package:pipergram/pages/home.dart';
import 'package:pipergram/widgets/progress.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text("Display Name",
              style: TextStyle(
                color: Colors.grey,
              )),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
              hintText: "Update Display Name",
              errorText: _displayNameValid ? null : "Display Name too short"),
        ),
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text("Bio",
              style: TextStyle(
                color: Colors.grey,
              )),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
              hintText: "Update Bio - Keep it short and simple",
              errorText:
                  _bioValid ? null : "Bio can not exceed 100 characters"),
        ),
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;

      if (_displayNameValid && _bioValid) {
        usersRef.document(widget.currentUserId).updateData({
          "displayName": displayNameController.text,
          "bio": bioController.text,
        });
      }
      SnackBar snackbar = SnackBar(content: Text("Profile Updated!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
    });
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              color: Colors.white,
              size: 30.0,
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.orange, Colors.teal])),
        ),
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.orange,
                          ),
                          onPressed: () => print("")),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildDisplayNameField(),
                            buildBioField(),
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: updateProfileData,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                        color: Colors.teal[400],
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: FlatButton.icon(
                          onPressed: logout,
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          label: Text(
                            "Logout",
                            style: TextStyle(fontSize: 20.0, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
