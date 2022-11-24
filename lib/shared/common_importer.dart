import '../services/firebase/firebase_analytics_service.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/local_pref/app_pref.dart';
import '../services/network/network_service.dart';

export 'app_logging/app_log_helper.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:provider/provider.dart';

typedef KApi = NetworkServiceImplementation;
typedef KFAS = FirebaseAuthService;
typedef KFANS = FirebaseAnalyticsService;
typedef KPref = AppPreferences;
