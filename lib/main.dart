import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  Size? _imageSize;

  // List _recognitionResults = [];
  final ImagePicker _picker = ImagePicker();
  String _imagePath = '';
  String _imageSave = '';

  void _setImagePath() async {
    _imagePath = (await getApplicationDocumentsDirectory()).path;
  }

  @override
  void initState() {
    super.initState();
    _setImagePath();
  }



  void _getLicensePlate(ImageSource imageSource)async {
    setState(() {
      _imageFile = null;
      _imageSize = null;

    });

    final XFile? pickedImage = await _picker.pickImage(
      source: imageSource,
      maxWidth: 1200,
      maxHeight: 1080,
      imageQuality: 90,
    );

    final File? imageFile = File(pickedImage!.path);



    if (imageFile != null) {
      _setImagePath();
      _getImageSize(imageFile);
      LprApiReq(imageFile).then((model) => _apiInfo(model));
    }

    setState(() {
      _imageFile = imageFile;
      _imageSave = pickedImage.path;
    });
  }

  void _getImageSize(File imageFile) {
    final Image image = Image.file(imageFile);

    image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          setState(() {
            _imageSize = Size(
              info.image.width.toDouble(),
              info.image.height.toDouble(),
            );
          });
        })
    );
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
        title: const     Text("Sample LPR API"),
      ),
      body: _imageFile == null
          ? const Center(child: Text("No image selected"))
          : _makeImage(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "hero1",
            onPressed:(){_getLicensePlate(ImageSource.gallery);} ,
            tooltip: "Select Image",
            child: const Icon(Icons.add_photo_alternate),
          ),
          const Padding(padding: EdgeInsets.all(10.0)),
          FloatingActionButton(
            heroTag: "hero2",
            onPressed:(){_getLicensePlate(ImageSource.camera);} ,
            tooltip: "Take Photo",
            child: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
    );
  }

  @override
  void _apiInfo(model){

    if (model.length > 10 ){
      final results = RecognitionResults.fromJson(jsonDecode(model) as Map<String, dynamic>);
      final String Area = results.PLATES[0].AREA;
      final String Class = results.PLATES[0].CLASS;
      final String Color = results.PLATES[0].COLOR;
      final String Digits = results.PLATES[0].DIGITS;
      final String Kana = results.PLATES[0].KANA;
      final String Kind = results.PLATES[0].KIND;


      final textResultsmain = Area+"  "+Class+"  "+Kana+"  "+Digits ;
      final textResultscontents = Kind+"  "+Color ;

      showDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title:Text(textResultsmain),
            content: Text(textResultscontents),
            actions: [
              CupertinoDialogAction(
                  child: const Text('撮り直す'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
              ),
            ],
          )
      );
    } else {
      showDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('ナンバープレートが見つかりませんでした。'),
            actions: [
              CupertinoDialogAction(
                  child:Text('撮り直す'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
              ),
            ],
          )
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

//LPR APIリクエスト
  LprApiReq(imageFile) async{
    //発行したTokenに変更してください。
    String apiToken = "Token";
    String uri = 'https://api.sensing-api.com/api/lpr-entry?token=${apiToken}';
    var imagePic = imageFile.path;

    var request = http.MultipartRequest('PUT',Uri.parse(uri));
    request.files.add(await http.MultipartFile.fromPath('image1',imagePic, contentType: MediaType('image','jpeg')));
    // request.files.add(await http.MultipartFile.fromBytes('meta',(await rootBundle.load('json/parm.json')).buffer.asUint8List(),
    //     filename:'parm.json',contentType: MediaType('application','json')));

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

