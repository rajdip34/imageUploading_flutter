import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:toast/toast.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File _imageFile;
  bool _isUploading = false;

  String baseUrl = "https://api.imgur.com/3/image";

  // rest apt call for uplode the image

  Future<Map<String, dynamic>> _uploadImage(File image) async {
// update state
    setState(() {
      _isUploading = true;
    });

    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(baseUrl));

    imageUploadRequest.headers['authorization'] =
        "Bearer 11ab4bf7ffaac804bc54548784bb66e9d7f21327";

    final file = await http.MultipartFile.fromPath(
      'image', image.path,
      // contentType: MediaType(mimeTypeData[0], mimeTypeData[1])
    );
    imageUploadRequest.fields['image'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);

    try {
      final streamResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamResponse);
      if (response.statusCode != 200) {
        print("not working");
        return null;
      }
      final Map<String, dynamic> resData = json.decode(response.body);

      _resetState();

      return resData;
    } catch (e) {
      print(e);

      return null;
    }
  }
// change the state for image uploading

  void _resetState() {
    setState(() {
      _isUploading = false;
      _imageFile = null;
    });
  }

  //start image uplodading

  void _startImageUploading() async {
    final Map<String, dynamic> response = await _uploadImage(_imageFile);

    print(response);

    if (response == null || response.containsKey("error")) {
      Toast.show("iamge uplodaing faild", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      Toast.show("iamge uplodaing  Success ", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

// image picker model
  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Pick the image from your device",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                    color: Colors.red,
                    onPressed: () {
                      _getImage(context, ImageSource.camera);
                    },
                    child: Text("Use camera")),
                FlatButton(
                    color: Colors.green,
                    onPressed: () {
                      _getImage(context, ImageSource.gallery);
                    },
                    child: Text("Use gallery")),
              ],
            ),
          );
        });
  }

// uplode button
  Widget _buildUplodeButton() {
    Widget btnW = Container();

    if (_isUploading) {
      btnW = Container(
        margin: EdgeInsets.only(top: 10.0),
        child: CircularProgressIndicator(),
      );
    } else if (!_isUploading && _imageFile != null) {
      btnW = Container(
          margin: EdgeInsets.only(top: 10),
          child: RaisedButton(
            onPressed: () {
              _startImageUploading();
            },
            color: Colors.cyan,
            textColor: Colors.black,
            child: Text("Upload"),
          ));
    }
    return btnW;
  }

// pick the image from device  ##
  void _getImage(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = image;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 10.10),
          child: OutlineButton(
            onPressed: () => _openImagePicker(context),
            borderSide: BorderSide(color: Colors.black, width: 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.camera),
                SizedBox(
                  width: 5.0,
                ),
                Text("add Image")
              ],
            ),
          ),
        ),
        _imageFile == null
            ? Text("Please pick a image")
            : Image.file(
                _imageFile,
                fit: BoxFit.cover,
                height: 300.0,
                alignment: Alignment.topCenter,
                width: MediaQuery.of(context).size.width,
              ),
        _buildUplodeButton()
      ],
    ));
  }
}
