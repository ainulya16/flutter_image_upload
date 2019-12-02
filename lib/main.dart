import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:todo_flutter/ui/image.dart';

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
  List<FileItem> _files = List();

  
  final uploader = FlutterUploader();
  StreamSubscription _progressSubscription;
  StreamSubscription _resultSubscription;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _progressSubscription?.cancel();
    _resultSubscription?.cancel();
  }


  void _setListener() {
    _progressSubscription = uploader.progress.listen((progress) {
      // final task = _tasks[progress.tag];
      print("progress: ${progress.progress} , tag: ${progress.tag}");
      // this.setState((){
        // _progress = progress.progress;
        // _status = progress.status;
      // });
      
    });
    _resultSubscription =uploader.result.listen((result) {
      print("id: ${result.taskId}, status: ${result.status}");
      print("response: ${result.response}, statusCode: ${result.statusCode}");
      print("tag: ${result.tag}, headers: ${result.headers}");
      setState(() {
        _images = _images.toList()..removeAt(0);
        _files = _files.toList()..removeAt(0);
      });
    }, onError: (ex, stacktrace) {
      print("stacktrace: $stacktrace" ?? "no stacktrace");
    });
  }


  void _uploadImage() async {
    try {
      var filename = _files[0].filename;
      String taskId = '';
      Map<String,String> headers = {
            "Content-Type": "application/octet-stream",
            "Authorization": "Bearer 2XIY9sJs32QAAAAAAAABVCH4XNvPghqnXaloy2OpxVYWBEmozbW7Sg5Qf5ixJKPe",
            "Dropbox-API-Arg": "{\"path\": \"/example/$filename\",\"mode\": \"add\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}",
          };
        taskId = await uploader.enqueueBinary(
          url: "https://content.dropboxapi.com/2/files/upload",
          file: _files[0],
          method: UploadMethod.POST,
          headers: headers,
          showNotification: false,
          tag: 'upload $filename'
        );

      print('taskId $taskId');
    } on PlatformException catch (e) {
      print(e);
    }
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
        FileItem file = _files[index];
        // return ViewImages(index, asset, false, file, key: UniqueKey());
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
