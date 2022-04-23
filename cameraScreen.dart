import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  CameraImage? cameraImage;
  CameraController? cameraController;
  String output='';
  @override
  void initState(){
    super.initState();
    loadCamera();
    loadModel();

  }

  loadCamera(){
    cameraController=CameraController(cameras![0], ResolutionPreset.medium,
    );
    cameraController!.initialize().then((value) =>{
      if(!mounted){}
      else{
        setState((){cameraController!.startImageStream((image) {
           cameraImage=image;
           runModel();
        });})
      }
    } );
  }
  runModel()async {
    if(cameraImage!=null){
      var predections=await Tflite.runModelOnFrame(bytesList: cameraImage!.planes.map((plane) => plane.bytes).toList(),
      imageHeight:cameraImage!.height,
      imageWidth:cameraImage!.width   ,
       imageMean: 127.5,
       imageStd: 127.5,
        rotation: 90,
        numResults: 1,
        threshold: 0.1,
        asynch: true
      );
      predections!.forEach((element) {
        setState(() {
          output=element['label'];
        });
      });
    }
  }
  loadModel()async{
    await Tflite.loadModel(model: 'assets/model_unquant.tflite',
    labels:'assets/labels.txt' );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title:Text('Camera' ,),),
    body: Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height*0.7,
          width: MediaQuery.of(context).size.width,
          child: !cameraController!.value.isInitialized? Container():AspectRatio(aspectRatio: cameraController!.value.aspectRatio,
          child: CameraPreview(cameraController!),),
        ),
        Text(output,
        style: TextStyle(fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black),)
      ],
    ),

    );
  }
}
