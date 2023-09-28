import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(SampleApp());
}

class SampleApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensing API LPR API',
      home: SampleFlutterLprApi(),
    );
  }
}

class SampleFlutterLprApi extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: TakePictureScreen(),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
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

  _setImagePath() async {
    _imagePath = (await getApplicationDocumentsDirectory()).path;
  }



  void _getLicenseplate(ImageSource imageSource)async {
    setState(() {
      _imageFile = null;
      _imageSize = null;

    });

    final XFile? pickedImage = await _picker.pickImage(
        source: imageSource,
        maxWidth: 1980,
        maxHeight: 1080,
        imageQuality: 100
    );

    final File? imageFile = File(pickedImage!.path);



    if (imageFile != null) {
      _setImagePath();
      _getImageSize(imageFile);


    }

    setState(() {
      _imageFile = imageFile;
      _imageSave = pickedImage.path;
    });
  }

  void _getImageSize(File imageFile) {
    final Image image = Image.file(imageFile);

    image.image.resolve(ImageConfiguration()).addListener(
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
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.file(_imageFile!).image,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("ShotingPage"),
      ),
      body: _imageFile == null
          ? Center(child: Text("No image selected"))
          : _makeImage(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "hero1",
            onPressed:(){_getLicenseplate(ImageSource.gallery);} ,
            tooltip: "Select Image",
            child: Icon(Icons.add_photo_alternate),
          ),
          Padding(padding: EdgeInsets.all(10.0)),
          FloatingActionButton(
            heroTag: "hero2",
            onPressed:(){_getLicenseplate(ImageSource.camera);} ,
            tooltip: "Take Photo",
            child: Icon(Icons.add_a_photo),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
  }
}


