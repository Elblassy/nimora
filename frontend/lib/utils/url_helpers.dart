import '../utils/constants.dart';

String getFullUrl(String url) {
  if (url.startsWith('http')) return url;
  return '${AppConstants.apiBaseUrl}$url';
}
