import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http_parser/http_parser.dart';
import 'dart:async';
import '../models/recognitionlicenseplate.dart';

void main() {
  runApp(const SampleApp());
}

class SampleApp extends StatelessWidget{
  const SampleApp({super.key});
  @override
  Widget build(BuildContext context){
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensing API LPR API',
      home: SampleFlutterLprApi(),
    );
  }
}

class SampleFlutterLprApi extends StatelessWidget{
  const SampleFlutterLprApi({super.key});
  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body: TakePictureScreen(),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key});
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen>{
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  void _getLicensePlate(ImageSource imageSource)async {
    setState(() {
      _imageFile = null;
    });

    final XFile? pickedImage = await _picker.pickImage(
      source: imageSource,
      maxWidth: 1200,
      maxHeight: 1080,
      imageQuality: 90,
    );

    final File? imageFile = File(pickedImage!.path);

    if (imageFile != null) {
      lprApiReq(imageFile).then((model) => _apiInfo(model));
    }

    setState(() {
      _imageFile = imageFile;
    });
  }

  Widget _makeImage() {
    return Container(
      // constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.file(_imageFile!).image,
          // fit: BoxFit.contain,
        ),
      ),
      margin: const EdgeInsets.only(left:15,top: 50,right: 15,bottom: 50),
    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("LPR API Sample",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        backgroundColor: const Color(0xFF71C9CE),
      ),
      body: _imageFile == null
          ? const Center(child: Text("No image selected"))
          : _makeImage(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "hero1",
            backgroundColor: const Color(0xFF71C9CE),
            onPressed:(){_getLicensePlate(ImageSource.gallery);} ,
            tooltip: "Select Image",
            child: const Icon(Icons.add_photo_alternate,color: Colors.white),
          ),
          const Padding(padding: EdgeInsets.all(10.0)),
          FloatingActionButton(
            heroTag: "hero2",
            backgroundColor: const Color(0xFF71C9CE),
            onPressed:(){_getLicensePlate(ImageSource.camera);} ,
            tooltip: "Take Photo",
            child: const Icon(Icons.add_a_photo,color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void _apiInfo(model){

    if (model.length > 10 ){
      final results = RecognitionResults.fromJson(jsonDecode(model) as Map<String, dynamic>);
      final String areaName = results.PLATES[0].AREA;
      final String classNumber = results.PLATES[0].CLASS;
      final String kanaName = results.PLATES[0].KANA;
      final String digitsNumber = results.PLATES[0].DIGITS;

      final textResultsMain = '$areaName '' $classNumber '' $kanaName '' $digitsNumber';

      showCupertinoModalPopup<void>(
        context: context,
        builder:(BuildContext context) => CupertinoActionSheet(
          title: Text(textResultsMain,style:const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize:23)),
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,

              child: const Text('閉じる',style: TextStyle(color: Colors.blue)),
              onPressed: () async{
                Navigator.of(context).pop();
              },
            )
          ],
        ),
        barrierDismissible: false,
      );
    }  else if(model == "noPlate") {

      showCupertinoModalPopup<void>(
        context: context,
        builder:(BuildContext context) => CupertinoActionSheet(
          title: const Text('ナンバープレートが見つかりませんでした。'),
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,

              child: const Text('戻る',style: TextStyle(color: Colors.blue)),
              onPressed: () async{
                Navigator.of(context).pop();
              },
            )
          ],
        ),
        barrierDismissible: false,
      );
    } else if(model == "tokenFalse") {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Tokenの設定が誤っています。\n 一度ご確認ください。'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('戻る',style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else if(model == 'timeout'){
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('タイムアウトしました。'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('戻る',style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }else if(model == 'unexpected error'){
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('予期せぬエラーが発生しました。'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('戻る',style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

//LPR APIリクエスト
lprApiReq(imageFile) async{
    //発行したTokenに変更してください。
    String apiToken = "Token";
    String uri = 'https://api.sensing-api.com/api/lpr-entry?token=${apiToken}';
    var imagePic = imageFile.path;

    var request = http.MultipartRequest('PUT',Uri.parse(uri));
    request.files.add(await http.MultipartFile.fromPath('image1',imagePic, contentType: MediaType('image','jpeg')));
    request.files.add(await http.MultipartFile.fromBytes('meta',(await rootBundle.load('assets/json/param.json')).buffer.asUint8List(),
        filename:'param.json',contentType: MediaType('application','json')));

    var timeoutDuration = const Duration(seconds: 30);

    try{
      var response = await request.send().timeout(timeoutDuration,onTimeout: (){
        throw  'リクエストがタイムアウトしました';
      });
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final json = jsonDecode(respStr);
        if (json['RES'] == 1){
          return respStr;
        }else{
          return "noPlate";
        }

      } else if(response.statusCode == 401){
        return "tokenFalse";

      }else{
        return "noPlate";
      }
    }catch (e){
      if (e is TimeoutException) {
        return 'timeout';
      } else {
        return 'unexpected error';
      }
    }

  }
}

