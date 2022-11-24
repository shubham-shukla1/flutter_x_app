// import 'package:flutter/material.dart';
//
// import 'app_colors/app_colors.dart';
//
// class AppThemeProvider extends ChangeNotifier {
//   /// Getter and setter of main theme
//   ThemeData _currentTheme;
//
//   ThemeData get themeData => _currentTheme;
//
//   ThemeFlavors _currentThemeFlavor;
//
//   ThemeFlavors get themeFlavor => _currentThemeFlavor;
//
//   AppThemeProvider({bool isDarkMode = true}) {
//     this._currentTheme = isDarkMode ? myDark : myLight;
//     this._currentAppThemeData =
//         isDarkMode ? _darkAppThemeData : _lightAppThemeData;
//     this._currentThemeFlavor =
//         isDarkMode ? ThemeFlavors.DARK : ThemeFlavors.LIGHT;
//   }
//
//   ThemeData myLight = ThemeData(
//     brightness: Brightness.light,
//     primaryColor: AppColors.scaffoldLight,
//     scaffoldBackgroundColor: AppColors.scaffoldLight,
//     primarySwatch: MaterialColor(AppColors.primaryColor, AppColors.color),
//     bottomSheetTheme: BottomSheetThemeData(
//       backgroundColor: AppColors.bottomSheetBGColorLight,
//     ),
//   );
//
//   /// * * * * * END * * * * *
//
//   /// Toggle main and widget theme
//   void toggleTheme() {
//     print('Current theme: $_currentThemeFlavor');
//
//     /// 1.Toggle to variable
//     bool isMainLight = false;
//     isMainLight = _currentTheme == myLight ? true : false;
//
//     /// 1.Change main theme
//     _currentTheme = isMainLight ? myDark : myLight;
//
//     /// 2.Change app theme own data (for our widgets)
//     bool isAppLightData = _currentAppThemeData == _lightAppThemeData;
//
//     /// 2.Change app theme own data
//     _currentAppThemeData =
//         isAppLightData ? _darkAppThemeData : _lightAppThemeData;
//
//     /// 3.Change enum theme flavor
//     _currentThemeFlavor =
//         isAppLightData ? ThemeFlavors.DARK : ThemeFlavors.LIGHT;
//
//     /// 4.Notify to update in app
//     print('Toggle to theme: $_currentThemeFlavor');
//     notifyListeners();
//   }
//
//   void toggleTo(ThemeFlavors flavor) {
//     print('Current theme: $_currentThemeFlavor');
//
//     /// 1.Check parameter theme
//     bool isParameterLight = false;
//     isParameterLight = flavor == ThemeFlavors.DARK ? false : true;
//
//     /// 1.Change main theme
//     _currentTheme = isParameterLight ? myLight : myDark;
//
//     /// 2.Change app theme own data (for our widgets)
//     bool isAppLightData = isParameterLight;
//
//     /// 2.Change app theme own data
//     _currentAppThemeData =
//         isAppLightData ? _lightAppThemeData : _darkAppThemeData;
//
//     /// 3.Change enum theme flavor
//     _currentThemeFlavor =
//         isAppLightData ? ThemeFlavors.LIGHT : ThemeFlavors.DARK;
//
//     /// 4.Notify to update in app
//     print('Toggle to theme: $_currentThemeFlavor');
//     notifyListeners();
//   }
//
//   /// * * * * * END * * * * *
//
//   /// Getter and setter of widget theme
//   AppThemeData _currentAppThemeData;
//
//   AppThemeData get appThemeData => _currentAppThemeData;
//
//   AppThemeData _darkAppThemeData = AppThemeData(
//       appRoundedButtonData: AppRoundedButtonData.darkTheme,
//       appTextFieldWithLabelData: AppTextFieldWithLabelData.darkTheme,
//       appLinkPreviewData: AppLinkPreviewData.darkTheme,
//       appPostData: AppPostData.darkTheme,
//       appQuestionData: AppQuestionData.darkTheme,
//       appPollData: AppPollData.darkTheme,
//       appEventData: AppEventData.darkTheme,
//       appReactionPanelData: AppReactionPanelData.darkTheme,
//       appShimmerEffect: AppShimmerEffect.darkTheme,
//       appIconThemeData: AppIconThemeData.darkTheme,
//       appFeedTopCommunityData: AppFeedTopCommunityData.darkTheme,
//       appFilterComponentData: AppFilterComponentData.darkTheme,
//       appTagData: AppTagData.darkTheme,
//       appFeedBreakerData: AppFeedBreakerData(
//         feedBreakerFaqData: FeedBreakerFaqData.darkTheme,
//         articleData: ArticleData.darkTheme,
//         followCardData: FollowCardData.darkTheme,
//       ),
//       appCommentBoxData: AppCommentBoxData.darkTheme,
//       appCreatePost: AppCreatePost.darkTheme,
//       appCreateQuestion: AppCreateQuestion.darkTheme,
//       appCreatePoll: AppCreatePoll.darkTheme,
//       appCreatePostBSData: AppCreatePostBSData.darkTheme,
//       appTagsBSData: AppTagsBSData.darkTheme,
//       appCreateEvent: AppCreateEvent.darkTheme,
//       appChatListData: AppChatListData.darkTheme,
//       appChatScreenData: AppChatScreenData.darkTheme,
//
//       /// New chat
//       appChatPageData: AppChatPageData.darkTheme,
//       appChatThreadPageData: AppChatThreadPageData.darkTheme,
//       appMemberListBSData: AppMemberListBSData.darkTheme,
//       appSplashScreenData: AppSplashScreenData.darkTheme,
//       appServicesListData: AppServicesListData.darkTheme,
//       appMembersListPageData: AppMembersListPageData.darkTheme,
//       appBadgeData: AppBadgeData.darkTheme,
//       appKbTopData: AppKbTopData.darkTheme,
//       appLinkData: AppLinkData.darkTheme,
//       appExpandedCommunnityData: AppExpandedCommunnityData.darkTheme);
//
//   AppThemeData _lightAppThemeData = AppThemeData(
//     appRoundedButtonData: AppRoundedButtonData.lightTheme,
//     appTextFieldWithLabelData: AppTextFieldWithLabelData.lightTheme,
//     appLinkPreviewData: AppLinkPreviewData.lightTheme,
//     appPostData: AppPostData.lightTheme,
//     appQuestionData: AppQuestionData.lightTheme,
//     appPollData: AppPollData.lightTheme,
//     appEventData: AppEventData.lightTheme,
//     appReactionPanelData: AppReactionPanelData.lightTheme,
//     appShimmerEffect: AppShimmerEffect.lightTheme,
//     appIconThemeData: AppIconThemeData.lightTheme,
//     appFeedTopCommunityData: AppFeedTopCommunityData.lightTheme,
//     appFilterComponentData: AppFilterComponentData.lightTheme,
//     appTagData: AppTagData.lightTheme,
//     appFeedBreakerData: AppFeedBreakerData(
//       feedBreakerFaqData: FeedBreakerFaqData.lightTheme,
//       articleData: ArticleData.lightTheme,
//       followCardData: FollowCardData.lightTheme,
//     ),
//     appCommentBoxData: AppCommentBoxData.lightTheme,
//     appCreatePost: AppCreatePost.lightTheme,
//     appCreateQuestion: AppCreateQuestion.lightTheme,
//     appCreatePoll: AppCreatePoll.lightTheme,
//     appCreatePostBSData: AppCreatePostBSData.lightTheme,
//     appTagsBSData: AppTagsBSData.lightTheme,
//     appCreateEvent: AppCreateEvent.lightTheme,
//     appChatListData: AppChatListData.lightTheme,
//     appChatScreenData: AppChatScreenData.lightTheme,
//
//     /// New chat
//     appChatPageData: AppChatPageData.lightTheme,
//     appChatThreadPageData: AppChatThreadPageData.lightTheme,
//     appMemberListBSData: AppMemberListBSData.lightTheme,
//     appSplashScreenData: AppSplashScreenData.lightTheme,
//     appServicesListData: AppServicesListData.lightTheme,
//     appMembersListPageData: AppMembersListPageData.lightTheme,
//     appBadgeData: AppBadgeData.lightTheme,
//     appKbTopData: AppKbTopData.lightTheme,
//     appLinkData: AppLinkData.lightTheme,
//     appExpandedCommunnityData: AppExpandedCommunnityData.lightTheme,
//   );
//
//   /// * * * * * END * * * * *
// }
//
// enum ThemeFlavors {
//   DARK,
//   LIGHT,
// }
