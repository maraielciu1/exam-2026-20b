import 'dart:io';

const String _androidBaseUrl = 'http://10.0.2.2:2621';
const String _defaultBaseUrl = 'http://localhost:2621';
const String _androidWsUrl = 'ws://10.0.2.2:2621';
const String _defaultWsUrl = 'ws://localhost:2621';

String getBaseUrl() {
  if (Platform.isAndroid) {
    return _androidBaseUrl;
  }
  return _defaultBaseUrl;
}

String getWebSocketUrl() {
  if (Platform.isAndroid) {
    return _androidWsUrl;
  }
  return _defaultWsUrl;
}
