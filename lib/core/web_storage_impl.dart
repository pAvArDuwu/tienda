import 'package:web/web.dart' as web;

String? getLocalStorage(String key) => web.window.localStorage.getItem(key);
void setLocalStorage(String key, String value) => web.window.localStorage.setItem(key, value);
void removeLocalStorage(String key) => web.window.localStorage.removeItem(key);
