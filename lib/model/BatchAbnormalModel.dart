class BatchAbnormalModel {
  final String batchId;
  final DateTime dateadd;
  final String process;
  final String comment;

  BatchAbnormalModel(
      {required this.batchId,
      required this.dateadd,
      required this.process,
      required this.comment});

  Map<String, dynamic> toJson() {
    return {
      'batchId': batchId,
      'dateadd': dateadd.toIso8601String(),
      'process': process,
      'comment': comment,
    };
  }
}
