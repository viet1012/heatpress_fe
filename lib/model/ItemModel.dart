class ItemModel {
  final String itemCheck;
  final DateTime? startTime;
  final DateTime? finishTime; // Có thể null
  final String? machine;
  ItemModel({required this.itemCheck, required this.startTime, this.finishTime, this.machine});
  ItemModel.basic( {
    required this.itemCheck
  }):startTime = null,
        finishTime = null,
  machine= null;

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      itemCheck: json['itemCheck'],
      startTime: DateTime.parse(json['startTime']),
      finishTime: json['finishTime'] != null ? DateTime.parse(json['finishTime']) : null,
      machine: json['machine'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCheck': itemCheck,
      'startTime': startTime?.toIso8601String(),
      'finishTime': finishTime?.toIso8601String(),
    };
  }
}
