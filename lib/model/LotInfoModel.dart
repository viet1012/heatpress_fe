class LotInfoModel {
  final int qty;
  final String poreqno;
  final String ferth;
  final String itemCheckFinal;
  final String note;
  final String poreqnosWithQty;

  LotInfoModel({
    required this.qty,
    required this.poreqno,
    required this.ferth,
    required this.itemCheckFinal,
    required this.note,
    required this.poreqnosWithQty,
  });

  factory LotInfoModel.fromJson(Map<String, dynamic> json) {
    return LotInfoModel(
        qty: json['qty'] ?? 0,
        poreqno: json['poreqno'] ?? '',
        ferth: json['ferth'] ?? '',
        itemCheckFinal: json['itemCheckFinal'] ?? '',
        note: json['note'] ?? '',
        poreqnosWithQty: json['poreqnosWithQty'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'qty': qty,
      'poreqno': poreqno,
    };
  }
}
