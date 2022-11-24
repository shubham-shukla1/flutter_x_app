import 'dart:io';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../shared/flavor/app_flutter_config.dart';
import '../local_pref/app_pref.dart';
import '../network/network_exceptions.dart';

class SystemEventService {
  static Future<bool> callSystemEvent(
      Map<String, dynamic> params, String eventName) async {
    try {
      // Let's parce to Uri first
      String? url = AppFlavorConfig.instance!.systemEventUrl!;
      Uri? uri;

      if (url != null) {
        uri = Uri.parse(url);
      }

      // Add extra event name to the url
      params.putIfAbsent('eventName', () => eventName);
      params.putIfAbsent(
          'device', () => Platform.isAndroid ? 'android' : 'ios');

      // convert dynamic value to string
      // Map<String, String> convertedParams =
      //     AppUtils.convertMapDynamicToString(params);

      // Lets make actual URI with parameters as well
      Uri actualData = Uri(
        host: uri?.host,
        port: uri?.port,
        path: uri?.path,
        scheme: uri?.scheme,
        queryParameters: params,
      );

      // http request
      final Response response = await http.get(
        actualData,
        headers: {
          'Accept': 'application/json',
          'Access-Control_Allow_Origin': '*',
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': 'Bearer ${AppPreferences.instance!.authToken}',
        },
        // queryParameters: params,
      );

      var responseInObj = jsonDecode(response.body);

      if (responseInObj['status'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw SystemEventException(e);
    }
  }
}
