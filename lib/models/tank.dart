import 'table_row_data.dart';

class Tank {
  String name;
  String dutModel;
  String dutSn;
  String dutLength;
  String tankDepth;
  String tankCapacity;
  String sealBody;
  String sealConnector;
  String filtrationDegree;
  double sensorX;
  double sensorY;
  List<TableRowData> table;

  Tank({
    this.name = '',
    this.dutModel = '',
    this.dutSn = '',
    this.dutLength = '',
    this.tankDepth = '',
    this.tankCapacity = '',
    this.sealBody = '',
    this.sealConnector = '',
    this.filtrationDegree = '',
    this.sensorX = 185,
    this.sensorY = 70,
    List<TableRowData>? table,
  }) : table = table ?? [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'dut_model': dutModel,
    'dut_sn': dutSn,
    'dut_length': dutLength,
    'tank_depth': tankDepth,
    'tank_capacity': tankCapacity,
    'seal_body': sealBody,
    'seal_connector': sealConnector,
    'filtration_degree': filtrationDegree,
    'sensor_pos': [sensorX, sensorY],
    'table': table.map((e) => e.toJson()).toList(),
  };

  factory Tank.fromJson(Map<String, dynamic> json) {
    final sp = json['sensor_pos'];
    double sx = 185, sy = 70;
    if (sp is List && sp.length >= 2) {
      sx = (sp[0] as num).toDouble();
      sy = (sp[1] as num).toDouble();
    }
    final tbl = json['table'];
    List<TableRowData> rows = [];
    if (tbl is List) {
      rows = tbl.map((e) => TableRowData.fromJson(e as Map<String, dynamic>)).toList();
    }
    return Tank(
      name: json['name']?.toString() ?? '',
      dutModel: json['dut_model']?.toString() ?? '',
      dutSn: json['dut_sn']?.toString() ?? '',
      dutLength: json['dut_length']?.toString() ?? '',
      tankDepth: json['tank_depth']?.toString() ?? '',
      tankCapacity: json['tank_capacity']?.toString() ?? '',
      sealBody: json['seal_body']?.toString() ?? '',
      sealConnector: json['seal_connector']?.toString() ?? '',
      filtrationDegree: json['filtration_degree']?.toString() ?? '',
      sensorX: sx,
      sensorY: sy,
      table: rows,
    );
  }
}
