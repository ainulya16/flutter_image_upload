import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  String _error = '';
  List<Asset> _images = List();
  List<Asset> _uploadedImages = List();
  List<FileItem> _files = List();

  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void callbackDispatcher() {
    Workmanager.executeTask((task, images) async {
      switch (task) {
        case 'upload':
          print("upload file was executed");
          _uploadImage();
          break;
        case Workmanager.iOSBackgroundTask:
          print("The iOS background fetch was triggered");
          break;
      }

      return Future.value(true);
    });
  }

  void initialize() {
    Workmanager.initialize(callbackDispatcher,isInDebugMode: true,);
  }


  void _uploadImage() async {
    if(_images.length==0) {
      Workmanager.cancelAll();
      return;
    }
    try {

        final String url = "https://content.dropboxapi.com/2/files/upload";
        final Asset asset = _images[0];    
        final String filename = asset.name;
        final Map<String,String> headers = {
          "Content-Type": "application/octet-stream",
          "Authorization": "Bearer 2XIY9sJs32QAAAAAAAABVCH4XNvPghqnXaloy2OpxVYWBEmozbW7Sg5Qf5ixJKPe",
          "Dropbox-API-Arg": "{\"path\": \"/example/$filename\",\"mode\": \"add\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}",
        };

        Uri uri = Uri.parse(url);
        ByteData byteData = await asset.getByteData();
        List<int> imageData = byteData.buffer.asUint8List();

        final response = await http.post(url, body: imageData, headers: headers);
        print(response.body);
        if(response.statusCode==200) {
          this.setState((){
            _images = _images.toList()..removeAt(0);
            _uploadedImages = _uploadedImages.toList()..add(asset);
          });
          _uploadImage();
        }

    } on PlatformException catch (e) {
      print(e);
    }
  }

  void startUploadFiles() {
    Workmanager.registerOneOffTask("1",'upload');
  }

  void _getImages() async {
    List<Asset> result = List<Asset>();
    String error = '';
    try {
      result = await MultiImagePicker.pickImages(maxImages: 10, enableCamera: false);
      for (var item in result) {
        var savedDir = await item.filePath;
        savedDir = savedDir.substring(0, savedDir.lastIndexOf('/')+1);
        _files.add(FileItem(filename: item.name, savedDir: savedDir, fieldname: 'file'));
      }
    } on PlatformException catch (e) {
      error = e.message;
    }
    if(!mounted) return;
    setState(() {
      _images = result;
      _files = _files;
      _error = error;
    });
  }


  Widget _buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(_images.length, (index) {
        Asset asset = _images[index];
        return AssetThumb(
          asset: asset,
          height: 300,
          width: 300,
          quality: 60,
        );
      }),
    );
  }

  Widget _getContent() {
    if (_error.length > 0) {
      return Center(
        child: Text(_error),
      );
    }

    if (_images.length == 0) {
      return Center(
        child: Text('Please select image'),
      );
    }

    return _buildGridView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _getContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _images.length == 0 ? _getImages : _uploadImage,
        tooltip: 'Upload',
        child: _images.length == 0 ? Icon(Icons.add) : Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
