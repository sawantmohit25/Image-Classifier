import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';

class ImageClassifier extends StatefulWidget {
  @override
  _ImageClassifierState createState() => _ImageClassifierState();
}

class _ImageClassifierState extends State<ImageClassifier> {
  File _image;
  List result;
  String name='',confidence='';
  openGallery() async {
    PickedFile image = await ImagePicker().getImage(
        source: ImageSource.gallery);
    setState(() {
      _image = File(image.path);
    });
    Fluttertoast.showToast(
        msg: 'Image Uploaded Successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.pink,
        textColor: Colors.white
    );
  }

  checkGalleryPermission() async {
    var galleryStatus = await Permission.photos.status;
    print(galleryStatus);
    if (!galleryStatus.isGranted) {
      await Permission.photos.request();
    }
    if (await galleryStatus.isGranted) {
      openGallery();
    }
    else {
      Fluttertoast.showToast(
          msg: 'Provide Permission to use your photos',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.pink,
          textColor: Colors.white
      );
    }
  }
  loadMyModel()async{
    var result=await Tflite.loadModel(model:"assets/model_unquant.tflite",labels:"assets/labels.txt");
    print(result);
  }
  applyModelOnImage(File file)async{
    var res=await Tflite.runModelOnImage(
      path:file.path,
      numResults: 2,
      threshold: 0.5,
      imageMean:127.5,
      imageStd: 127.5
    );
    setState(() {
      result=res;
      String str=result[0]["label"];
      name=str.substring(2);
      confidence=result!=null?(result[0]['confidence']*100.0).toString().substring(0,2)+"%":'';
    });
    Fluttertoast.showToast(
        msg: 'Image Classified Successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.pink,
        textColor: Colors.white
    );
  }
  @override
  void initState() {
    loadMyModel();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title:Text('Image Classifier'),
        backgroundColor:Colors.pink,
      ),
      floatingActionButton:FloatingActionButton.extended(
        onPressed:(){
          checkGalleryPermission();
        },
        backgroundColor:Colors.pink,
        icon:Icon(Icons.upload_file,color:Colors.white,),
        label:Text('Upload Image',style:TextStyle(color:Colors.white),),
      ),
      body:Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            _image != null ? Image.file(_image) :Image.network('https://www.clix.capital/clixblog/wp-content/uploads/sites/3/2018/06/Two-Wheeler-vs-Four-Wheeler.png'),
            SizedBox(height:20,),
            _image!=null?RaisedButton(onPressed:(){
              applyModelOnImage(_image);
            },child:Text('CLASSIFY IMAGE'),color:Colors.pink,):Container(),
            SizedBox(height:20,),
            Row(
              children: [
                Text('Vehicle Type:- ${name!=null?name:''}',style:TextStyle(fontSize:25),),
              ],
            ),
            SizedBox(height:20,),
            Row(
              children: [
                Text('Confidence:- ${confidence!=null?confidence:''}',style:TextStyle(fontSize:25),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
