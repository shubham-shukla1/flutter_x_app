import 'package:json_annotation/json_annotation.dart';

part 'fnotification_model.g.dart';

@JsonSerializable()
class FNotificationModel {
  String? title;
  String? message;
  String? type;
  String? deepLink;

  FNotificationModel({
    this.title,
    this.message,
    this.type,
    this.deepLink,
  });

  factory FNotificationModel.fromJson(Map<String, dynamic> data) =>
      _$FNotificationModelFromJson(data);

  Map<String, dynamic> toJson() => _$FNotificationModelToJson(this);
}
