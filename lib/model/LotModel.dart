import 'ItemModel.dart';
import 'LotInfoModel.dart';

class LotModel {
  final String lot;
  final String rfID_key;
  final List<LotInfoModel> info;
  final List<ItemModel> items;

  LotModel(
      {required this.lot,
      required this.rfID_key,
      required this.info,
      required this.items});

  factory LotModel.fromJson(Map<String, dynamic> json) {
    return LotModel(
      lot: json['lot'],
      rfID_key: json['rfID_key'] ?? '',
      info:
          (json['info'] as List).map((e) => LotInfoModel.fromJson(e)).toList(),
      items: (json['items'] as List).map((e) => ItemModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lot': lot,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
