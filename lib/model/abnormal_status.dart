class AbnormalStatus {
  final bool isError;
  final bool isOverdue;

  AbnormalStatus({required this.isError, required this.isOverdue});

  bool get isAbnormal => isError || isOverdue;
}
