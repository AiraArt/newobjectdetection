import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:newobjectdetectionyolov5/LoaderState.dart';
import 'package:newobjectdetectionyolov5/add_recipe.dart';
import 'package:newobjectdetectionyolov5/recipe_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  

  
}

class _HomeScreenState extends State<HomeScreen> {
  late ModelObjectDetection _objectModel;
  String? _imagePrediction;
  List? _prediction;
  File? _image;
  ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];
  bool firststate = false;
  bool message = true;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    String pathObjectDetectionModel = "assets/models/yolov5s.torchscript";
    try {
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
        // change the 80 with number of classes in your model pretrained yolov5 had almost 80 classes so I added 80 here.
          pathObjectDetectionModel, 80, 640, 640,
          labelPath: "assets/labels/labels.txt");
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  void handleTimeout() {
    // callback function
    // Do some work.
    setState(() {
      firststate = true;
    });
  }
   

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);
  //running detections on image
  Future runObjectDetection() async {
    setState(() {
      firststate = false;
      message = false;
    });
    //pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    objDetect = await _objectModel.getImagePrediction(
        await File(image!.path).readAsBytes(),
        minimumScore: 0.1,
        IOUThershold: 0.3);
    objDetect.forEach((element) {
      print({
        "score": element?.score,
        "className": element?.className,
        "class": element?.classIndex,
        "rect": {
          "left": element?.rect.left,
          "top": element?.rect.top,
          "width": element?.rect.width,
          "height": element?.rect.height,
          "right": element?.rect.right,
          "bottom": element?.rect.bottom,
        },
      });
    });
    scheduleTimeout(5 * 1000);
    setState(() {
      _image = File(image.path);
    });
  }
  resultData() {
    var result = objDetect;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SMART PALATE"),
      centerTitle: true,
      backgroundColor: Colors.pink,),
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddRecipe()));
                }, child: const Text('Add Recipe')),
          SizedBox(height: 80,),

                
          //Image with Detections....

          !firststate
              ? !message ? LoaderState() : Text("Select the Camera to Begin Detections")
              : Expanded(
                  child: Container(
                      child:
                          _objectModel.renderBoxesOnImage(_image!, objDetect)),
                ),
                

          // !firststate
          //     ? LoaderState()
          //     : Expanded(
          //         child: Container(
          //             height: 150,
          //             width: 300,
          //             child: objDetect.isEmpty
          //                 ? Text("hello")
          //                 : _objectModel.renderBoxesOnImage(
          //                     _image!, objDetect)),
          //       ),
          Center(
            child: Visibility(
              visible: _imagePrediction != null,
              child: Text("$_imagePrediction"),
            ),
          ),
          //Button to click pic
          ElevatedButton(
            onPressed: () {
              runObjectDetection();
            },
             
            child: const Icon(Icons.camera),
          ), 
          SizedBox(height: 100,),

          ElevatedButton(onPressed: (){
              runObjectDetection();

              !firststate
              ? !message ? LoaderState() : Text("Select the Camera to Begin Detections")
              : Expanded(
                  child: Container(
                      child:
                          _objectModel.renderBoxesOnImage(_image!, objDetect)),
                );

                Center(
            child: Visibility(
              visible: _imagePrediction != null,
              child: Text("$_imagePrediction"),
            ),

          );
            }, child: Text('Retake Photo')),
            SizedBox(height: 80,),

            ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeList(resultData: objDetect,)));
                }, child: const Text('print Recipe')),
        ],
      )),
    );
  }
}