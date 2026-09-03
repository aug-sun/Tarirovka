class TableRowData {
  String ue;
  String liters;

  TableRowData({this.ue = '', this.liters = ''});

  Map<String, dynamic> toJson() => {'ue': ue, 'liters': liters};

  factory TableRowData.fromJson(Map<String, dynamic> json) {
    return TableRowData(
      ue: json['ue']?.toString() ?? '',
      liters: json['liters']?.toString() ?? '',
    );
  }
}
