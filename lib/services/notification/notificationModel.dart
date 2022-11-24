class Notifications {
  Notifications(
      {required this.id,
      required this.title,
      required this.body,
      this.payload,
      required this.isRead});

  final String id;
  final String title;
  final String body;
  final String? payload;
  final bool isRead;
}

class NotificationModel {
  NotificationModel({
    required this.msg,
    required this.date,
    required this.isRead,
    required this.id,
  });

  late final Msg msg;
  late final String date;
  late final String isRead;
  late final String id;

  NotificationModel.fromJson(Map<String, dynamic> json) {
    msg = Msg.fromJson(json['msg'] as Map<String, dynamic>);
    date = json['date'].toString();
    isRead = json['isRead'].toString();
    id = json['id'].toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['msg'] = msg.toJson();
    _data['date'] = date;
    _data['isRead'] = isRead;
    _data['id'] = id;
    return _data;
  }
}

class Msg {
  Msg({
    // required this.type,
    // required this.bg,
    // required this.orientation,
    required this.content,
  });

  // late final String type;
  // late final String bg;
  // late final String orientation;
  late final List<Content> content;

  Msg.fromJson(Map<String, dynamic> json) {
    // type = json['type'].toString();
    // bg = json['bg'].toString();
    // orientation = json['orientation'].toString();
    content = List.from(json['content'] as Iterable<dynamic>)
        .map((e) => Content.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    // _data['type'] = type;
    // _data['bg'] = bg;
    // _data['orientation'] = orientation;
    _data['content'] = content.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Content {
  Content({
    required this.key,
    required this.message,
    required this.title,
    required this.action,
  });

  late final int key;
  late final Message message;
  late final Title title;
  late final Action action;

  Content.fromJson(Map<String, dynamic> json) {
    key = json['key'] as int;
    message = Message.fromJson(json['message'] as Map<String, dynamic>);
    title = Title.fromJson(json['title'] as Map<String, dynamic>);
    action = Action.fromJson(json['action'] as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['key'] = key;
    _data['message'] = message.toJson();
    _data['title'] = title.toJson();
    _data['action'] = action.toJson();
    return _data;
  }
}

class Message {
  Message({
    required this.text,
    // required this.color,
    // required this.og,
    // required this.replacements,
    // required this.defaultValuesSet,
  });

  late final String text;

  // late final String color;
  // late final String og;
  // late final String replacements;
  // late final DefaultValuesSet defaultValuesSet;

  Message.fromJson(Map<String, dynamic> json) {
    text = json['text'].toString();
    // color = json['color'].toString();
    // og = json['og'].toString();
    // replacements = json['replacements'].toString();
    // defaultValuesSet = DefaultValuesSet.fromJson(
    //     json['defaultValuesSet'] as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['text'] = text;
    // _data['color'] = color;
    // _data['og'] = og;
    // _data['replacements'] = replacements;
    // _data['defaultValuesSet'] = defaultValuesSet.toJson();
    return _data;
  }
}

// class DefaultValuesSet {
//   DefaultValuesSet({
//     required this.value,
//     required this.strict,
//   });
//
//   late final bool value;
//   late final bool strict;
//
//   DefaultValuesSet.fromJson(Map<String, dynamic> json) {
//     value = json['value'].toString().toLowerCase() == 'true';
//     strict = json['strict'].toString().toLowerCase() == 'true';
//   }
//
//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['value'] = value;
//     _data['strict'] = strict;
//     return _data;
//   }
// }

class Title {
  Title({
    required this.text,
    // required this.color,
    // required this.og,
    // required this.replacements,
    // required this.defaultValuesSet,
  });

  late final String text;

  // late final String color;
  // late final String og;
  // late final String replacements;
  // late final DefaultValuesSet defaultValuesSet;

  Title.fromJson(Map<String, dynamic> json) {
    text = json['text'].toString();
    // color = json['color'].toString();
    // og = json['og'].toString();
    // replacements = json['replacements'].toString();
    // defaultValuesSet = DefaultValuesSet.fromJson(
    //     json['defaultValuesSet'] as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['text'] = text;
    // _data['color'] = color;
    // _data['og'] = og;
    // _data['replacements'] = replacements;
    // _data['defaultValuesSet'] = defaultValuesSet.toJson();
    return _data;
  }
}

class Action {
  Action({
    required this.hasUrl,
    required this.hasLinks,
    required this.url,
    // required this.links,
  });

  late final bool hasUrl;
  late final bool hasLinks;
  late final Url url;

  // late final List<Links> links;

  Action.fromJson(Map<String, dynamic> json) {
    hasUrl = json['hasUrl'].toString().toLowerCase() == 'true';
    hasLinks = json['hasLinks'].toString().toLowerCase() == 'true';
    url = Url.fromJson(json['url'] as Map<String, dynamic>);
    // links = List.from(json['links'] as Iterable<dynamic>)
    //     .map((e) => Links.fromJson(e as Map<String, dynamic>))
    //     .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['hasUrl'] = hasUrl;
    _data['hasLinks'] = hasLinks;
    _data['url'] = url.toJson();
    // _data['links'] = links.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Url {
  Url({
    required this.android,
    required this.ios,
  });

  late final Android android;
  late final Ios ios;

  Url.fromJson(Map<String, dynamic> json) {
    android = Android.fromJson(json['android'] as Map<String, dynamic>);
    ios = Ios.fromJson(json['ios'] as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['android'] = android.toJson();
    _data['ios'] = ios.toJson();
    return _data;
  }
}

class Android {
  Android({
    required this.text,
    // required this.og,
    // required this.replacements,
    // required this.key,
  });

  late final String text;

  // late final String og;
  // late final String replacements;
  // late final String key;

  Android.fromJson(Map<String, dynamic> json) {
    text = json['text'].toString();
    // og = json['og'].toString();
    // replacements = json['replacements'].toString();
    // key = json['key'].toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['text'] = text;
    // _data['og'] = og;
    // _data['replacements'] = replacements;
    // _data['key'] = key;
    return _data;
  }
}

class Ios {
  Ios({
    required this.text,
    // required this.og,
    // required this.replacements,
    // required this.key,
  });

  late final String text;

  // late final String og;
  // late final String replacements;
  // late final String key;

  Ios.fromJson(Map<String, dynamic> json) {
    text = json['text'].toString();
    // og = json['og'].toString();
    // replacements = json['replacements'].toString();
    // key = json['key'].toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['text'] = text;
    // _data['og'] = og;
    // _data['replacements'] = replacements;
    // _data['key'] = key;
    return _data;
  }
}

// class Links {
//   Links({
//     required this.type,
//     required this.text,
//     required this.color,
//     required this.bg,
//     required this.copyText,
//     required this.url,
//   });
//
//   late final String type;
//   late final String text;
//   late final String color;
//   late final String bg;
//   late final CopyText copyText;
//   late final Url url;
//
//   Links.fromJson(Map<String, dynamic> json) {
//     type = json['type'].toString();
//     text = json['text'].toString();
//     color = json['color'].toString();
//     bg = json['bg'].toString();
//     copyText = CopyText.fromJson(json['copyText'] as Map<String, dynamic>);
//     url = Url.fromJson(json['url'] as Map<String, dynamic>);
//   }
//
//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['type'] = type;
//     _data['text'] = text;
//     _data['color'] = color;
//     _data['bg'] = bg;
//     _data['copyText'] = copyText.toJson();
//     _data['url'] = url.toJson();
//     return _data;
//   }
// }

// class CopyText {
//   CopyText({
//     required this.text,
//     required this.replacements,
//     required this.og,
//   });
//
//   late final String text;
//   late final String replacements;
//   late final String og;
//
//   CopyText.fromJson(Map<String, dynamic> json) {
//     text = json['text'].toString();
//     replacements = json['replacements'].toString();
//     og = json['og'].toString();
//   }
//
//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['text'] = text;
//     _data['replacements'] = replacements;
//     _data['og'] = og;
//     return _data;
//   }
// }
