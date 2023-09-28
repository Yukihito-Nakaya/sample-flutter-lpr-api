// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recognitionlicenseplate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

plates _$platesFromJson(Map<String, dynamic> json) => plates(
      AREA: json['AREA'] as String,
      CLASS: json['CLASS'] as String,
      COLOR: json['COLOR'] as String,
      DIGITS: json['DIGITS'] as String,
      KANA: json['KANA'] as String,
      KIND: json['KIND'] as String,
    );

Map<String, dynamic> _$platesToJson(plates instance) => <String, dynamic>{
      'AREA': instance.AREA,
      'CLASS': instance.CLASS,
      'COLOR': instance.COLOR,
      'DIGITS': instance.DIGITS,
      'KANA': instance.KANA,
      'KIND': instance.KIND,
    };

RecognitionResults _$RecognitionResultsFromJson(Map<String, dynamic> json) =>
    RecognitionResults(
      PLATES: (json['PLATES'] as List<dynamic>)
          .map((e) => plates.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecognitionResultsToJson(RecognitionResults instance) =>
    <String, dynamic>{
      'PLATES': instance.PLATES.map((e) => e.toJson()).toList(),
    };
