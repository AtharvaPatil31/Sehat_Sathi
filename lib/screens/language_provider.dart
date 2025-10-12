import 'package:flutter/material.dart';

enum AppLanguage { english, punjabi }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;

  void changeLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  // Helper to get text in current language
  String getText(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? key;
  }

  // All localized strings
  final Map<AppLanguage, Map<String, String>> _localizedValues = {
    AppLanguage.english: {
      'home_title': 'Home',
      'welcome': 'Welcome to Sehat Saathi!',
      'book_consultation': 'Book Consultation',
      'settings': 'Settings',
      'profile': 'Profile',
      'live_video': 'Live Video',
      'pre_recorded_videos': 'Prerecorded Videos',
      'enter_room_name': 'Enter room name',
      'generate_random': 'Generate Random',
      'start_video_call': 'Start Video Call',
      'enter_room_message': 'Enter a room name to start video consultation',
      'video_consultation': 'Video Consultation',
      'tap_to_play': 'Tap to play',
      'invalid_url': 'Invalid YouTube URL',
      'language': 'Language',
      'english': 'English',
      'punjabi': 'Punjabi',
    },
    AppLanguage.punjabi: {
      'home_title': 'ਹੋਮ',
      'welcome': 'ਸਿਹਤ ਸਾਥੀ ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ!',
      'book_consultation': 'ਸਲਾਹ-ਮਸ਼ਵਰਾ ਬੁੱਕ ਕਰੋ',
      'settings': 'ਸੈਟਿੰਗਸ',
      'profile': 'ਪ੍ਰੋਫਾਈਲ',
      'live_video': 'ਲਾਈਵ ਵੀਡੀਓ',
      'pre_recorded_videos': 'ਪੂਰਵ-ਰਿਕਾਰਡ ਕੀਤੇ ਵੀਡੀਓ',
      'enter_room_name': 'ਰੂਮ ਦਾ ਨਾਮ ਦਰਜ ਕਰੋ',
      'generate_random': 'ਯਾਦਗਾਰੀ ਬਣਾਓ',
      'start_video_call': 'ਵੀਡੀਓ ਕਾਲ ਸ਼ੁਰੂ ਕਰੋ',
      'enter_room_message': 'ਵੀਡੀਓ ਕਾਲ ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਰੂਮ ਦਾ ਨਾਮ ਦਰਜ ਕਰੋ',
      'video_consultation': 'ਵੀਡੀਓ ਸਲਾਹ-ਮਸ਼ਵਰਾ',
      'tap_to_play': 'ਖੇਡਣ ਲਈ ਟੈਪ ਕਰੋ',
      'invalid_url': 'ਅਮਾਨਯੂ ਯੂਟਿਊਬ URL',
      'language': 'ਭਾਸ਼ਾ',
      'english': 'ਅੰਗਰੇਜ਼ੀ',
      'punjabi': 'ਪੰਜਾਬੀ',
    },
  };
}
