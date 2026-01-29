import 'package:flutter/material.dart';

class ErrorItemsProvider with ChangeNotifier {
  // Sử dụng rowId làm key, lưu trữ lỗi cho từng rowId.
  Map<String, Map<String, dynamic>> _errorItemsByRowId = {};

  Map<String, Map<String, dynamic>> get errorItemsByRowId => _errorItemsByRowId;

  final Set<String> abnormalLots = {}; // ✅ lưu các lot đã gửi lỗi

  void setErrorsFromSet(Set<Map<String, String>> overdueItems) {
    errorItemsByRowId.clear(); // Xóa toàn bộ lỗi cũ

    for (var item in overdueItems) {
      if (item['rowId'] == null || item['checkType'] == null) continue;
      errorItemsByRowId[item['rowId']!] = {
        "machineId": item['checkType']!,
        "errors": ["Overdue"]
      };
    }

    notifyListeners(); // Thông báo UI cập nhật
  }

  // Cập nhật lỗi cho một rowId, nếu rowId đã tồn tại thì cập nhật lỗi, nếu chưa thì thêm mới
  // void updateErrorItems(String rowId, String machineId, String checkType, String lot,List<String> errors) {
  //   // Thêm hoặc cập nhật lỗi cho rowId
  //   if (!_errorItemsByRowId.containsKey(lot)) {
  //     _errorItemsByRowId[lot] = {'machineId': machineId, 'checkType': checkType, 'rowId': rowId, 'errors': errors};
  //   } else {
  //     _errorItemsByRowId[lot]!['errors'] = errors;
  //   }
  //   notifyListeners();
  // }

  void updateErrorItems(String rowId, String machineId, String checkType,
      String lot, List<String> errors) {
    // Thêm hoặc cập nhật lỗi cho rowId
    if (!_errorItemsByRowId.containsKey(rowId)) {
      _errorItemsByRowId[rowId] = {
        'machineId': machineId,
        'checkType': checkType,
        'lot': lot,
        'errors': errors
      };
    } else {
      _errorItemsByRowId[rowId]!['errors'] = errors;
    }
    notifyListeners();
  }

  // Thêm lỗi 'Overdue' cho một rowId
  void addOverdueItem(String rowId, String machineId, String itemCheck) {
    if (!_errorItemsByRowId.containsKey(rowId)) {
      _errorItemsByRowId[rowId] = {
        'machineId': machineId,
        'errors': ['Overdue']
      };
    } else {
      List<String> errors = _errorItemsByRowId[rowId]!['errors'] ?? [];
      if (!errors.contains("Overdue")) {
        errors.add("Overdue");
      }
      _errorItemsByRowId[rowId]!['errors'] = errors;
    }
    notifyListeners();
  }

  // Xóa lỗi của một rowId
  void removeError(String rowId) {
    if (errorItemsByRowId.containsKey(rowId)) {
      // print(
      //     "🛑 Xóa khỏi Provider: $rowId - Trước khi xóa: ${errorItemsByRowId.keys}");
      errorItemsByRowId.remove(rowId);
      notifyListeners();
      //print("✅ Sau khi xóa: ${errorItemsByRowId.keys}");
    }
  }

  void clearErrors() {
    errorItemsByRowId.clear();
    notifyListeners();
  }

  // ✅ Đánh dấu lot đã gửi lỗi
  void markAbnormal(String lotId) {
    abnormalLots.add(lotId);
  }

  // ✅ Kiểm tra đã gửi lỗi chưa
  bool isAlreadyAbnormal(String lotId) {
    return abnormalLots.contains(lotId);
  }
}
