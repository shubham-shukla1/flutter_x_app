// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fnotification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FNotificationModel _$FNotificationModelFromJson(Map<String, dynamic> json) =>
    FNotificationModel(
      title: json['title'] as String?,
      message: json['message'] as String?,
      type: json['type'] as String?,
      deepLink: json['deepLink'] as String?,
    );

Map<String, dynamic> _$FNotificationModelToJson(FNotificationModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'deepLink': instance.deepLink,
    };
