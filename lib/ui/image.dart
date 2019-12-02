import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ViewImages extends StatefulWidget {
  final int _index;
  final Asset _asset;
  final bool _uploaded;
  final FileItem _file;
  ViewImages(
      this._index,
      this._asset,
      this._uploaded,
      this._file, {
        Key key,
      }
      ) : super(key: key);
  @override  State<StatefulWidget>
  createState() => AssetState(this._index, this._asset, this._uploaded, this._file);
}

class AssetState extends State<ViewImages> {
  int _index = 0;
  Asset _asset;
  FileItem _file;
  bool _uploaded;
  int _progress;
  UploadTaskStatus _status;
  AssetState(this._index, this._asset, this._uploaded, this._file);
  
  // final uploader = FlutterUploader();
  // StreamSubscription _progressSubscription;
  // StreamSubscription _resultSubscription;
  
  @override 
  void initState() {
    super.initState();
    // if(!uploaded) {
    //   _setListener();
    //   _uploadImage();
    // }
  }

  // void _setListener() {
  //   _progressSubscription = uploader.progress.listen((progress) {
  //     // final task = _tasks[progress.tag];
  //     print("progress: ${progress.progress} , tag: ${progress.tag}");
  //     this.setState((){
  //       _progress = progress.progress;
  //       _status = progress.status;
  //     });
      
  //   });
  //   _resultSubscription =uploader.result.listen((result) {
  //     print("id: ${result.taskId}, status: ${result.status}");
  //     print("response: ${result.response}, statusCode: ${result.statusCode}");
  //     print("tag: ${result.tag}, headers: ${result.headers}");
  //     setState(() {
  //       uploaded = true;
  //     });
  //   }, onError: (ex, stacktrace) {
  //     print("stacktrace: $stacktrace" ?? "no stacktrace");
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    // _progressSubscription?.cancel();
    // _resultSubscription?.cancel();
  }

  // void _uploadImage() async {
  //   try {
  //     var filename = _file.filename;
  //     String taskId = '';
  //     Map<String,String> headers = {
  //           "Content-Type": "application/octet-stream",
  //           "Authorization": "Bearer 2XIY9sJs32QAAAAAAAABVCH4XNvPghqnXaloy2OpxVYWBEmozbW7Sg5Qf5ixJKPe",
  //           "Dropbox-API-Arg": "{\"path\": \"/example/$filename\",\"mode\": \"add\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}",
  //         };
  //       taskId = await uploader.enqueueBinary(
  //         url: "https://content.dropboxapi.com/2/files/upload",
  //         file: _file,
  //         method: UploadMethod.POST,
  //         headers: headers,
  //         showNotification: false,
  //         tag: 'upload $filename'
  //       );

  //     print('taskId $taskId');
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override  Widget build(BuildContext context) {
    // final progressIndicator = LinearProgressIndicator(value: _progress.toDouble());
    final defaultContainer = Container(
      color: Colors.blueAccent,
      child: Center(
        child: Text('progress'),
      ),
    );
    // final onProgress = _progress.toDouble() != null ? progressIndicator : defaultContainer;
    
    final image =  AssetThumb(
      asset: _asset,
      height: 300,
      width: 300,
      quality: 60,
    );

    return !_uploaded ? image : defaultContainer;

  }
}
