import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../home.dart';

class CurrPage {
  static File currImage;
  static BuildContext context;

  static List _output;
  static final FlutterTts flutterTts = FlutterTts();

  static void currencyDetect(BuildContext buildContext, File img) {
    loadModel().then((value) {
      // setState(() {});
    });
    context = buildContext;
    currImage = img;
    speakCurrencyValue();
  }

  static classifyCurrency(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 7,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    print("This is the $output");
    print("This is the ${output[0]['label']}");
    dynamic label = output[0]['label'];
    print(label.runtimeType);
    _speak(label);
    _output = output;
    showCaptionDialog(label, image);
  }

  static loadModel() async {
    await Tflite.loadModel(
      model: 'assets/cash_model_unquant.tflite',
      labels: 'assets/cash_labels.txt',
    );
  }

  static speakCurrencyValue() {
    classifyCurrency(currImage);
  }

  static Future _speak(String output) async {
    await flutterTts.speak(output);
  }

  static Future<void> showCaptionDialog(String text, File picture) async {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Text('Currency Identification'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      new RaisedButton(
                        onPressed: () {
                          _speak(text);
                        },
                        padding: const EdgeInsets.all(10.0),
                        child: const Text('Replay'),
                        color: Color(0xFFE08284),
                        elevation: 5.0,
                      ),
                      new Image.file(picture),
                      SizedBox(width: 20),
                      new Text("$text"),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }

  static void _stopTts() {
    flutterTts.stop();
  }
}
//