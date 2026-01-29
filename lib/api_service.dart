import 'dart:async';
import 'dart:convert';

import 'package:headeguideiot/model/BatchAbnormalModel.dart';
import 'package:http/http.dart' as http;

import 'model/FerthModel.dart';
import 'model/LotModel.dart';
import 'model/machine.dart';

class ApiService {
  final String baseUrl = "http://192.168.122.15:9003/heatguide";

  // final String baseUrl = "http://F2PC24017:9998/heatguide";

  // final String baseUrl = "http://localhost:8080/heatguide";

  final StreamController<List<Machine>> _machineStreamController =
      StreamController.broadcast();

  List<Machine>? _lastFetchedData; // Lưu dữ liệu lần gần nhất để so sánh
  Timer? _timer; // Lưu timer để có thể hủy khi không cần thiết

  Stream<List<Machine>> get machineStream => _machineStreamController.stream;

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    startFetchingIOT();
  }

  Future<void> fetchMachines() async {
    try {
      print("🔄 Đang gọi API...");
      // final response = await http.get(Uri.parse('$baseUrl/test-group'));
      final response = await http.get(Uri.parse('$baseUrl/machines'));
      print("📥 URL: $baseUrl/machines}");
      print("📥 Response: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        List<Machine> machines =
            jsonList.map((item) => Machine.fromJson(item)).toList();

        if (_isDataChanged(machines)) {
          print("✅ Dữ liệu thay đổi, cập nhật Stream");
          _lastFetchedData = machines;
          _machineStreamController.add(machines);
        } else {
          print("⚠️ Dữ liệu không thay đổi, không cập nhật");
        }
      } else {
        throw Exception('API lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Lỗi khi gọi API: $e");

      // Xóa dữ liệu cũ để tránh giữ thông tin lỗi
      _lastFetchedData = null;

      // Cập nhật UI với danh sách rỗng để làm mới
      _machineStreamController.add([]);

      // Thử lại sau 2 phút
      Future.delayed(const Duration(minutes: 2), () {
        fetchMachines();
      });
    }
  }

  // Kiểm tra xem dữ liệu mới có khác dữ liệu cũ không
  bool _isDataChanged(List<Machine> newData) {
    if (_lastFetchedData == null)
      return true; // Nếu chưa có dữ liệu trước đó, cập nhật ngay
    return jsonEncode(_lastFetchedData) != jsonEncode(newData);
  }

  void loadMachines() async {
    try {
      List<Machine> machines = await ApiService().getMachines();
      print("✅ Lấy dữ liệu thành công: ${machines.length} máy");
    } catch (e) {
      print("❌ Lỗi khi lấy dữ liệu: $e");
    }
  }

  /// Trả về danh sách mới nhất ngay lập tức
  Future<List<Machine>> getMachines() async {
    if (_lastFetchedData != null) {
      print("⚡ Dữ liệu đã có sẵn, trả về ngay");
      return _lastFetchedData!; // ✅ Trả về dữ liệu ngay lập tức nếu có sẵn
    }

    final completer = Completer<List<Machine>>();

    StreamSubscription<List<Machine>>? subscription;
    subscription = machineStream.listen((machines) {
      completer.complete(machines);
      subscription?.cancel();
    }, onError: (error) {
      completer.completeError(error);
      subscription?.cancel();
    });

    fetchMachines(); // ✅ Vẫn gọi API nếu chưa có dữ liệu
    return completer.future;
  }

////////////////////////////////////////////////////////////////////////////////////

  Future<void> addBatch(BatchAbnormalModel batch) async {
    final url = Uri.parse('$baseUrl/lot_abnormal/add');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(batch.toJson()),
      );

      if (response.statusCode == 200) {
        print("✅ Gửi thành công: ${response.body}");
      } else {
        print("❌ Thất bại: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("⚠️ Lỗi khi gửi API: $e");
    }
  }

  Future<List<FerthModel>>
      fetchDataFromApiFindDailyHeatGuideMoldAndMainWaitingOT() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/findDailyHeatGuideMoldAndMainWaitingIOT'));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => FerthModel.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  // ✅ StreamController để truyền dữ liệu mới
  final StreamController<List<FerthModel>> _iotStreamController =
      StreamController.broadcast();
  final StreamController<List<FerthModel>> _iotStreamController1 =
      StreamController.broadcast();
  final StreamController<List<FerthModel>> _iotStreamController2 =
      StreamController.broadcast();

  List<FerthModel>? _lastFetchedDataIOT;
  List<FerthModel>? _lastFetchedDataIOT1;
  List<FerthModel>? _lastFetchedDataIOT2;

  Timer? _timerIOT; // Dùng Timer để cập nhật API định kỳ

  // ✅ Stream để UI lắng nghe dữ liệu mới
  Stream<List<FerthModel>> get iotStream => _iotStreamController.stream;

  Stream<List<FerthModel>> get iotStream1 => _iotStreamController1.stream;

  Stream<List<FerthModel>> get iotStream2 => _iotStreamController2.stream;

  void startFetchingIOT() {
    // Gọi API ngay lập tức
    fetchDataFromApiHeatGuideIOT("findDailyHeatGuideMoldAndMainIOT",
        retryCount: 1);
    // fetchDataFromApiHeatGuideIOT("findDailyHeatGuideSubAndDowelIOT");
    fetchDataFromApiHeatGuideIOT("findDailyHeatGuideMainAndMoldIOT",
        retryCount: 1);

    // Sau đó, bắt đầu Timer định kỳ
    _timerIOT?.cancel();
    _timerIOT = Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchDataFromApiHeatGuideIOT("findDailyHeatGuideMoldAndMainIOT",
          retryCount: 20);
      // fetchDataFromApiHeatGuideIOT("findDailyHeatGuideSubAndDowelIOT");
      fetchDataFromApiHeatGuideIOT("findDailyHeatGuideMainAndMoldIOT",
          retryCount: 20);
    });
  }

  List<FerthModel> tempData = [];
  List<FerthModel> listMainMoldTempData = [];

  // Lưu trạng thái API thành công
  Map<String, bool> lastApiSuccess = {
    "findDailyHeatGuideMoldAndMainIOT": true,
    "findDailyHeatGuideMainAndMoldIOT": true,
  };

  /// 📡 **Gọi API và cập nhật Stream**
  Future<void> fetchDataFromApiHeatGuideIOT(String endpoint,
      {int retryCount = 3}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    int maxRetries = lastApiSuccess[endpoint] == true ? 1 : retryCount;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.get(url);
        print("📡 API URL: $url");
        print("📩 Status Code: ${response.statusCode}");

        if (response.statusCode != 200) {
          throw Exception(
              '❌ Failed to load data (Status: ${response.statusCode})');
        }

        lastApiSuccess[endpoint] = true;

        List<dynamic> jsonList = jsonDecode(response.body);

        // List<FerthModel> fetchedData =
        //     jsonList.map((e) => FerthModel.fromJson(e)).toList();

        List<FerthModel> fetchedData = jsonList
            .map((e) {
              FerthModel ferth = FerthModel.fromJson(e);

              // Chỉ giữ item HRC_1 hoặc HRC_2
              for (var lot in ferth.lots) {
                lot.items.removeWhere((item) =>
                    item.itemCheck == "HRC_1" ||
                    item.itemCheck == "HRC_2" ||
                    item.itemCheck == "Temp_Point" ||
                    item.itemCheck == "Temp_Point_1" ||
                    item.itemCheck == "Temp_Point_2" ||
                    item.itemCheck == "Temp_Point_3" ||
                    item.itemCheck == "Temp_Point_4");
              }

              // Loại bỏ lot trống
              ferth.lots.removeWhere((lot) => lot.items.isEmpty);

              return ferth;
            })
            .where((ferth) => ferth.lots.isNotEmpty)
            .toList();

        // 🔹 Debug dữ liệu vừa lấy được
        print("\n=== 📊 API DATA DEBUG (${endpoint}) ===");
        for (var ferth in fetchedData) {
          for (var lot in ferth.lots) {
            print("  ➡ Lot: ${lot.lot}, Items: ${lot.items.length}");
            for (var item in lot.items) {
              print(
                  "     • ${item.itemCheck} | Start: ${item.startTime ?? 'null'} | Finish: ${item.finishTime ?? 'null'}");
            }
          }
        }
        print("=== END API DATA DEBUG ===\n");

        // Xử lý dữ liệu theo từng loại endpoint
        if (endpoint.contains("findDailyHeatGuideMainAndMoldIOT")) {
          processCoolFan3(fetchedData);
          listMainMoldTempData.addAll(fetchedData);
          updateStream(
              _iotStreamController2, _lastFetchedDataIOT2, fetchedData);
        } else if (endpoint.contains("findDailyHeatGuideMoldAndMainIOT")) {
          List<FerthModel> moldAndMainDataWithWash1 = [];
          List<FerthModel> movedToMainAndMold = [];

          for (var ferth in fetchedData) {
            List<LotModel> lotsWithWash1 = [];
            List<LotModel> lotsWithoutWash1 = [];

            for (var lot in ferth.lots) {
              bool hasWash1 =
                  lot.items.any((item) => item.itemCheck == "Wash_1");
              if (hasWash1) {
                lotsWithWash1.add(lot);
              } else {
                lotsWithoutWash1.add(lot);
              }
            }

            if (lotsWithWash1.isNotEmpty) {
              moldAndMainDataWithWash1.add(FerthModel(
                lots: lotsWithWash1,
              ));
            }

            if (lotsWithoutWash1.isNotEmpty) {
              movedToMainAndMold.add(FerthModel(
                lots: lotsWithoutWash1,
              ));
            }
          }

          listMainMoldTempData.addAll(movedToMainAndMold);
          List<FerthModel> mergedData = List.from(moldAndMainDataWithWash1)
            ..addAll(tempData);
          filterDuplicatedLots(mergedData, listMainMoldTempData);
          updateStream(_iotStreamController, _lastFetchedDataIOT, mergedData);
        } else if (endpoint.contains("findDailyHeatGuideSubAndDowelIOT")) {
          List<FerthModel> mergedData = List.from(fetchedData)
            ..addAll(tempData);
          updateStream(_iotStreamController1, _lastFetchedDataIOT1, mergedData);
        }
      } catch (e) {
        print("🚨 Error: $e");
        lastApiSuccess[endpoint] = false;

        if (attempt < retryCount) {
          print("🔄 Đợi 1 minutes trước khi thử lại...");
          await Future.delayed(const Duration(minutes: 1));
        } else {
          print("❌ Đã thử $retryCount lần nhưng vẫn lỗi, bỏ qua API này.");
        }
      }
    }
  }

  void filterDuplicatedLots(
      List<FerthModel> moldAndMainData, List<FerthModel> mainAndMoldData) {
    // 🔹 Tập hợp lot từ moldAndMainData để so sánh
    Set<String> moldAndMainLots = {};
    Set<String> mainAndMoldLots = {};

    for (var ferth in moldAndMainData) {
      for (var lot in ferth.lots) {
        moldAndMainLots.add(lot.lot);
      }
    }
    // For debug
    // for (var ferth in mainAndMoldData) {
    //   for (var lot in ferth.lots) {
    //     mainAndMoldLots.add(lot.lot);
    //   }
    // }
    // print("🔁 [DEBUG] Các lot mainAndMoldData: ${mainAndMoldLots.length}");

    // 🔹 Danh sách chứa lot cần xóa
    Set<String> lotsToRemoveFromMoldAndMain = {};
    Set<String> duplicatedLots = {}; // 🌟 Lưu các lot trùng

    // ✅ Duyệt từng lot trong MainAndMold để kiểm tra trùng với MoldAndMain
    for (var ferth in mainAndMoldData) {
      for (var lot in ferth.lots) {
        bool isDuplicate = moldAndMainLots.contains(lot.lot);
        bool hasCoolFan3 =
            lot.items.any((item) => item.itemCheck == "Cool_Fan_3");

        if (isDuplicate) {
          duplicatedLots.add(lot.lot); // 🌟 Thêm vào danh sách lot trùng
        }

        if (isDuplicate && !hasCoolFan3) {
          // ❌ Nếu lot trùng nhưng không có "Cool_Fan_3", xóa khỏi mainAndMold
          lotsToRemoveFromMoldAndMain.add(lot.lot);
        }
      }
    }

    // 🔥 In ra danh sách các lot trùng
    // print("🔁 [DEBUG] Các lot trùng: ${duplicatedLots.toList()}");

    // ✅ Xóa lot trùng trong MoldAnhMain
    for (var ferth in moldAndMainData) {
      ferth.lots
          .removeWhere((lot) => lotsToRemoveFromMoldAndMain.contains(lot.lot));
    }

    // print("🔁 [DEBUG] Các lot trùng với thông tin chi tiết:");
    // for (var ferth in mainAndMoldData) {
    //   for (var lot in ferth.lots) {
    //     if (duplicatedLots.contains(lot.lot)) {
    //       print(
    //           "🆔 Lot: ${lot.lot}, Items: ${lot.items.map((e) => e.itemCheck).toList()}");
    //     }
    //   }
    // }
  }

  void processCoolFan3(List<FerthModel> data) {
    tempData.clear(); // Đảm bảo dữ liệu cũ không bị lưu lại

    Set<String> removedLotNumbers = {}; // Để theo dõi các lot bị xóa

    for (var ferth in data) {
      List<LotModel> removedLots = [];

      for (var lot in ferth.lots) {
        // thay Cool_Fan_3 thành Wash_1

        if (lot.items.any((item) => item.itemCheck == "Wash_1")) {
          removedLots.add(lot);
          removedLotNumbers.add(lot.lot);
        }
      }

      if (removedLots.isNotEmpty) {
        // tempData.add(FerthModel(name: ferth.name, lots: removedLots));
        tempData.add(FerthModel(lots: removedLots));
      }

      ferth.lots.removeWhere((lot) => removedLotNumbers.contains(lot.lot));
    }
  }

  /// 🔹 **Xử lý lọc dữ liệu "Cool_Fan_3"**
  void processCoolFan31(List<FerthModel> data) {
    tempData.clear(); // Đảm bảo dữ liệu cũ không bị lưu lại

    for (var ferth in data) {
      var removedLots = ferth.lots
          .where(
              (lot) => lot.items.any((item) => item.itemCheck == "Cool_Fan_3"))
          .toList();

      if (removedLots.isNotEmpty) {
        // tempData.add(FerthModel(name: ferth.name, lots: removedLots));
        tempData.add(FerthModel(lots: removedLots));
      }

      ferth.lots.removeWhere(
          (lot) => lot.items.any((item) => item.itemCheck == "Cool_Fan_3"));
    }
  }

  /// 🔹 **Cập nhật Stream nếu dữ liệu thay đổi**
  // void updateStream(StreamController<List<FerthModel>> controller, List<FerthModel>? lastData, List<FerthModel>? newData) {
  //   if (newData == null || newData.isEmpty) {
  //     print("⚠️ Dữ liệu mới null hoặc rỗng, không cập nhật stream.");
  //     return;
  //   }
  //   if (lastData == null || _isDataChangedForIOT(lastData, newData)) {
  //     lastData = newData;
  //     controller.add(newData);
  //     print("✅ Stream đã cập nhật dữ liệu mới.");
  //   } else {
  //     print("⚠️ Dữ liệu không thay đổi, không cập nhật Stream.");
  //   }
  // }

  void updateStream(
    StreamController<List<FerthModel>> controller,
    List<FerthModel>? lastData,
    List<FerthModel>? newData,
  ) {
    if (newData == null || newData.isEmpty) {
      print("⚠️ Dữ liệu mới null hoặc rỗng, vẫn cập nhật stream với []");
      controller.add(
          []); // 🔥 emit empty list để StreamBuilder thoát khỏi trạng thái waiting
      return;
    }

    if (lastData == null || _isDataChangedForIOT(lastData, newData)) {
      lastData?.clear();
      lastData?.addAll(newData);
      controller.add(newData);
      print("✅ Stream đã cập nhật dữ liệu mới.");
    } else {
      print("⚠️ Dữ liệu không thay đổi, không cập nhật Stream.");
    }
  }

  /// 🔍 **Kiểm tra dữ liệu có thay đổi không**
  bool _isDataChangedForIOT(
      List<FerthModel>? oldData, List<FerthModel> newData) {
    if (oldData == null) return true;
    return jsonEncode(oldData) != jsonEncode(newData);
  }

  /// 🛑 **Dừng Stream khi không cần thiết để tránh rò rỉ bộ nhớ**
  void dispose() {
    _timer?.cancel();
    _iotStreamController.close();
    _iotStreamController1.close();
    _iotStreamController2.close();
  }
}
