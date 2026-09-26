import 'web_storage_stub.dart'
    if (dart.library.js_interop) 'web_storage_impl.dart';

String? webGetItem(String key) => getLocalStorage(key);
void webSetItem(String key, String value) => setLocalStorage(key, value);
void webRemoveItem(String key) => removeLocalStorage(key);
