import 'LotModel.dart';

class FerthModel {
  final List<LotModel> lots;

  // FerthModel({required this.name, required this.lots});
  FerthModel({required this.lots});

  // Chuyển từ JSON sang Object
  factory FerthModel.fromJson(Map<String, dynamic> json) {
    return FerthModel(
      // name: json['name'],
      lots: (json['lots'] as List).map((e) => LotModel.fromJson(e)).toList(),
    );
  }

  // Chuyển từ Object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'lots': lots.map((e) => e.toJson()).toList(),
    };
  }
}
