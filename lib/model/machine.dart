class Machine {
  final String macId;
  final String macName;
  final double stdHour;
  final int output;
  final int stdOutputday;
  final double processingHour;
  final DateTime? finishDate; // ✅ Có thể null
  final DateTime? finishTime; // ✅ Có thể null
  final String? note; // ✅ Có thể null

  Machine({
    required this.macId,
    required this.macName,
    required this.stdHour,
    required this.processingHour,
    required this.output,
    required this.stdOutputday,
    this.finishDate,
    required this.finishTime,
    required this.note
  });

  Machine.basic({
    required this.macId,
    required this.macName,
  })  : output = 0,
        processingHour = 0.0,
        stdHour = 0.0,
        stdOutputday = 0,
        finishDate = null,
        finishTime = null,
        note = "";

  Machine.blank()
      : macId = "",
        macName = "",
        processingHour = 0.0,
        stdOutputday = 0,
        stdHour = 0.0,
        output = 0,
        finishTime = null,
        note = "",
        finishDate = null;

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      macId: json['macId']?.toString() ?? "",
      macName: json['macName'] ?? "Unknown",
      output: json['outputQty'] ?? 0,
      stdOutputday: json['stdOutputDay'] ?? 0,
      processingHour: (json['processingHour'] as num?)?.toDouble() ?? 0.0,
      stdHour: (json['stdHour'] as num?)?.toDouble() ?? 0.0,
      finishDate: json['finishDate'] != null
          ? DateTime.tryParse(json['finishDate'])
          : null,
      finishTime: json['finishTime'] != null
          ? DateTime.tryParse(json['finishTime'])
          : null,
      note: json['note'] ?? "Unknown",
    );
  }

  /// ✅ **Hàm này giúp chuyển object thành JSON mà không bị lỗi**
  Map<String, dynamic> toJson() {
    return {
      'macId': macId,
      'macName': macName,
      'stdHour': stdHour,
      'outputQty': output,
      'stdOutputDay': stdOutputday,
      'processingHour': processingHour,
      'finishDate': finishDate?.toIso8601String(), // ✅ Convert DateTime thành String
    };
  }
}
