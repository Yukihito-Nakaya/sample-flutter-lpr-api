// ignore_for_file: camel_case_types, non_constant_identifier_names, duplicate_ignore

import 'package:json_annotation/json_annotation.dart';
part 'recognitionlicenseplate.g.dart';


// ignore: camel_case_types
@JsonSerializable()
class plates {
  plates({
    required this.AREA,
    required this.CLASS,
    required this.COLOR,
    required this.DIGITS,
    required this.KANA,
    required this.KIND,
  });

  factory plates.fromJson(Map<String, dynamic> json) => _$platesFromJson(json);
  String AREA;
  String CLASS;
  String COLOR;
  String DIGITS;
  String KANA;
  String KIND;

  Map<String, dynamic> toJson() => _$platesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecognitionResults {
  RecognitionResults({

    required this.PLATES,

  });
  factory RecognitionResults.fromJson(Map<String, dynamic> json) => _$RecognitionResultsFromJson(json);

  List<plates> PLATES;

  Map<String, dynamic> toJson() => _$RecognitionResultsToJson(this);
}