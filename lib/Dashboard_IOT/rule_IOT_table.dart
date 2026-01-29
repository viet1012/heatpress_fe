  import 'package:flutter/material.dart';

  class TableRuleIotRowData {
    final String code;
    final String moldBush;
    final String mainBush;
    final String subBush;
    final String subPost;
    final String mainPost;
    final String moldPost;
    final String dowelPin;

    TableRuleIotRowData({
      required this.code,
      required this.moldBush,
      required this.mainBush,
      required this.subBush,
      required this.subPost,
      required this.mainPost,
      required this.moldPost,
      required this.dowelPin,
    });
  }

  class   RuleIotDataTableWidget extends StatelessWidget {
    final List<TableRuleIotRowData> data = [
      TableRuleIotRowData(code: '1', moldBush: "Wash_1 60'", mainBush: "Wash_1 60'", subBush: "Wash_1 60'", subPost: "Wash_1 60'", mainPost: "No Washing", moldPost: "No Washing", dowelPin: "Wash_1 60'"),
      TableRuleIotRowData(code: '2', moldBush: "Quench 180'", mainBush: "Quench 180'", subBush: "Quench 180'", subPost: "Quench 180'", mainPost: "Quench 15'", moldPost: "Quench 15'", dowelPin: "Quench 180'"),
      TableRuleIotRowData(code: '3', moldBush: "OilShower 15'", mainBush: "OilShower 15'", subBush: "OilShower 15'", subPost: "OilShower 15'", mainPost: "Wash_2 15'", moldPost: "Wash_2 15'", dowelPin: "OilShower 15'"),
      TableRuleIotRowData(code: '4', moldBush: "Cool_Fan_1 60'", mainBush: "Cool_Fan_1 60'", subBush: "Cool_Fan_1 60'", subPost: "Cool_Fan_1 60'", mainPost: "Cool_Fan_1 30'", moldPost: "Cool_Fan_1 30'", dowelPin: "Cool_Fan_1 60'"),
      TableRuleIotRowData(code: '5', moldBush: "Wash_2 60'", mainBush: "Wash_2 60'", subBush: "Wash_2 60'", subPost: "Wash_2 60'", mainPost: "Temper_1 150'", moldPost: "Temper_1 150'", dowelPin: "Wash_2 60'"),
      TableRuleIotRowData(code: '6', moldBush: "Cool_Fan_2 60'", mainBush: "Cool_Fan_2 60'", subBush: "Cool_Fan_2 60'", subPost: "Cool_Fan_2 60'", mainPost: "Cool_Fan_2 60'", moldPost: "Cool_Fan_2 60'", dowelPin: "Cool_Fan_2 60'"),
      TableRuleIotRowData(code: '7', moldBush: "Temper_1 150'", mainBush: "Temper_1 150'", subBush: "Temper_1 150'", subPost: "Temper_1 150'", mainPost: "", moldPost: "", dowelPin: "Temper_1 150'"),
      TableRuleIotRowData(code: '8', moldBush: "Cool_Fan_3 60'", mainBush: "Cool_Fan_3 60'", subBush: "Cool_Fan_3 60'", subPost: "Cool_Fan_3 60'", mainPost: "", moldPost: "", dowelPin: "Cool_Fan_3 60'"),
      TableRuleIotRowData(code: '9', moldBush: "Temper_2 150'", mainBush: "Temper_2 150'", subBush: "", subPost: "", mainPost: "", moldPost: "", dowelPin: ""),
      TableRuleIotRowData(code: '10', moldBush: "Cool_Fan_4 60'", mainBush: "Cool_Fan_4 60'", subBush: "", subPost: "", mainPost: "", moldPost: "", dowelPin: ""),
      TableRuleIotRowData(code: '11', moldBush: "Waiting 1440'", mainBush: "Waiting 1440'", subBush: "", subPost: "", mainPost: "", moldPost: "", dowelPin: ""),
      TableRuleIotRowData(code: '12', moldBush: "Heat Finish", mainBush: "Heat Finish", subBush: "Heat Finish", subPost: "Heat Finish", mainPost: "Heat Finish", moldPost: "Heat Finish", dowelPin: "Heat Finish"),
    ];

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTableTheme(
                data: DataTableThemeData(
                  headingRowColor: WidgetStateProperty.all(  Colors.blue.shade700),
                  headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: DataTable(
                  columnSpacing: 14, // Giảm khoảng cách giữa các cột
                  border: TableBorder.all(color: Colors.grey),
                  columns: const [
                    DataColumn(label: SizedBox(width: 50, child: Text('No', textAlign: TextAlign.center))),
                    DataColumn(label: SizedBox(width: 100, child: Text('Mold Bush', textAlign: TextAlign.center))),
                    DataColumn(label: SizedBox(width: 100, child: Text('Main Bush', textAlign: TextAlign.center))),
                    DataColumn(label: SizedBox(width: 100, child: Text('Sub Bush', textAlign: TextAlign.center))),
                    DataColumn(label: SizedBox(width: 100, child: Text('Sub Post', textAlign: TextAlign.center))),
                    DataColumn(label: SizedBox(width: 100, child: Text('Main Post', textAlign: TextAlign.center))),
                    DataColumn(label: SizedBox(width: 100, child: Text('Mold Post', textAlign: TextAlign.center))),
                    DataColumn(label: SizedBox(width: 100, child: Text('Dowel Pins', textAlign: TextAlign.center))),
                  ],
                  rows: List.generate(
                    data.length,
                        (index) {
                      final row = data[index];
                      return DataRow.byIndex(
                        index: index,
                        cells: [
                          DataCell(Text(row.code, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          DataCell(Text(row.moldBush, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          DataCell(Text(row.mainBush, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          DataCell(Text(row.subBush, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          DataCell(Text(row.subPost, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          DataCell(Text(row.mainPost, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          DataCell(Text(row.moldPost, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          DataCell(Text(row.dowelPin, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),

                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  class TableMolipdenRowData {
    final String no;
    final String moldBush;
    final String mainBush;
    final String subBush;

    TableMolipdenRowData({
      required this.no,
      required this.moldBush,
      required this.mainBush,
      required this.subBush,
    });
  }

  class MolipdenDataTableWidget extends StatelessWidget {
    final List<TableMolipdenRowData> data = [
      TableMolipdenRowData(no: '1', moldBush: "Mo1 No", mainBush: "Mo1 No", subBush: "Mo1 No"),
      TableMolipdenRowData(no: '2', moldBush: "Shake 5'", mainBush: "Shake  5'", subBush: "Shake  5'"),
      TableMolipdenRowData(no: '3', moldBush: "Dry_170_1st  3'", mainBush: "Dry 170° 3'", subBush: "Dry 170° 3'"),
      TableMolipdenRowData(no: '4', moldBush: "Cool_Natural 10'", mainBush: "Cool_Natural 10'", subBush: "Cool_Natural 10'"),
      TableMolipdenRowData(no: '5', moldBush: "Mo2 No", mainBush: "Mo2 No", subBush: "Mo2 No"),
      TableMolipdenRowData(no: '6', moldBush: "Dry_170_2nd 90'", mainBush: "Dry 170° 90'", subBush: "Dry 170° 60'"),
      TableMolipdenRowData(no: '7', moldBush: "Cool_Fan_1 20'", mainBush: "Cool_Fan_1 20'", subBush: "Cool_Fan_1 20'"),
      TableMolipdenRowData(no: '8', moldBush: 'Naiken No', mainBush: 'NCL No', subBush: "Exa No"),
      TableMolipdenRowData(no: '9', moldBush: "Ngâm dầu nóng 60'", mainBush: "Ngâm dầu nóng 60'", subBush: "Ngâm dầu nóng 60'"),
      TableMolipdenRowData(no: '10', moldBush: "Ngâm dầu nguội 180'", mainBush: "Ngâm dầu nguội 180'", subBush: "Ngâm dầu nguội 180'"),
      TableMolipdenRowData(no: '11', moldBush: "", mainBush: "", subBush: "Waiting 180'"),

    ];

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTableTheme(
              data: DataTableThemeData(
                headingRowColor: WidgetStateProperty.all(Colors.blueAccent),
                headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14,),
              ),
              child: DataTable(
                columnSpacing: 14,
                border: TableBorder.all(color: Colors.grey),
                columns: const [
                  DataColumn(label: SizedBox(width: 40, child: Text('No',textAlign: TextAlign.center)),),
                  DataColumn(label: SizedBox(width: 150, child: Text('Mold Bush',textAlign: TextAlign.center))),
                  DataColumn(label: SizedBox(width: 150, child: Text('Main Bush',textAlign: TextAlign.center))),
                  DataColumn(label: SizedBox(width: 150, child: Text('Sub Bush',textAlign: TextAlign.center))),
                ],
                rows: List.generate(
                  data.length,
                      (index) {
                    final row = data[index];
                    return DataRow.byIndex(
                      index: index,
                      cells: [
                        DataCell(Center(child: Text(row.no,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                        DataCell(Center(child: Text(row.moldBush,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                        DataCell(Center(child: Text(row.mainBush,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                        DataCell(Center(child: Text(row.subBush,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
