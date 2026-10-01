import 'package:flutter/foundation.dart';
import '../services/api_exception.dart';

enum ResourceStatus {
  initial,
  loading,
  success,
  error,
  empty,
}

class ResourceController<T> extends ChangeNotifier {
  ResourceStatus _status = ResourceStatus.initial;
  T? _data;
  String? _errorMessage;

  ResourceController({T? initialData}) {
    if (initialData != null) {
      _data = initialData;
      _status = ResourceStatus.success;
    }
  }

  ResourceStatus get status => _status;
  T? get data => _data;
  String? get errorMessage => _errorMessage;

  bool get isInitial => _status == ResourceStatus.initial;
  bool get isLoading => _status == ResourceStatus.loading;
  bool get isSuccess => _status == ResourceStatus.success;
  bool get isError => _status == ResourceStatus.error;
  bool get isEmpty => _status == ResourceStatus.empty;
  bool get hasData => _data != null;

  void setLoading() {
    _status = ResourceStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void setData(T data, {bool Function(T data)? isEmpty}) {
    _data = data;
    _errorMessage = null;

    final checkEmpty = isEmpty ?? _defaultIsEmpty;
    if (checkEmpty(data)) {
      _status = ResourceStatus.empty;
    } else {
      _status = ResourceStatus.success;
    }
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _status = ResourceStatus.error;
    notifyListeners();
  }

  void reset() {
    _status = ResourceStatus.initial;
    _data = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Executes an asynchronous operation, automatically managing loading, error, empty, and success states.
  Future<T?> execute(
    Future<T> Function() action, {
    bool Function(T data)? isEmpty,
  }) async {
    setLoading();
    try {
      final result = await action();
      setData(result, isEmpty: isEmpty);
      return result;
    } on ApiException catch (e) {
      setError(e.message);
      return null;
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }

  bool _defaultIsEmpty(T data) {
    if (data == null) return true;
    if (data is Iterable) return data.isEmpty;
    if (data is Map) return data.isEmpty;
    if (data is String) return data.trim().isEmpty;
    return false;
  }
}
