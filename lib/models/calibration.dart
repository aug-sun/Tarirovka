import 'tank.dart';

class Calibration {
  String client;
  String workAddress;
  String date;
  String carModel;
  String grz;
  String atModel;
  String atImei;
  List<Tank> tanks;

  Calibration({
    this.client = '',
    this.workAddress = '',
    this.date = '',
    this.carModel = '',
    this.grz = '',
    this.atModel = '',
    this.atImei = '',
    List<Tank>? tanks,
  }) : tanks = tanks ?? [];

  Map<String, dynamic> toJson() => {
    'client': client,
    'work_address': workAddress,
    'date': date,
    'car_model': carModel,
    'grz': grz,
    'at_model': atModel,
    'at_imei': atImei,
    'tanks': tanks.map((e) => e.toJson()).toList(),
  };

  factory Calibration.fromJson(Map<String, dynamic> json) {
    final t = json['tanks'];
    List<Tank> tanks = [];
    if (t is List) {
      tanks = t.map((e) => Tank.fromJson(e as Map<String, dynamic>)).toList();
    }
    return Calibration(
      client: json['client']?.toString() ?? '',
      workAddress: json['work_address']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      carModel: json['car_model']?.toString() ?? '',
      grz: json['grz']?.toString() ?? '',
      atModel: json['at_model']?.toString() ?? '',
      atImei: json['at_imei']?.toString() ?? '',
      tanks: tanks,
    );
  }
}
