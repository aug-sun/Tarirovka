import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/calibration.dart';
import '../models/tank.dart';
import '../services/storage_service.dart';
import '../widgets/tank_block.dart';

class CalibrationEditScreen extends StatefulWidget {
  final Calibration? calibration;
  final int? editIndex;

  const CalibrationEditScreen({
    super.key,
    this.calibration,
    this.editIndex,
  });

  @override
  State<CalibrationEditScreen> createState() => _CalibrationEditScreenState();
}

class _CalibrationEditScreenState extends State<CalibrationEditScreen> {
  final _storage = StorageService();
  final _clientCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: DateFormat('dd.MM.yyyy').format(DateTime.now()));
  final _carModelCtrl = TextEditingController();
  final _grzCtrl = TextEditingController();
  final _atModelCtrl = TextEditingController();
  final _atImeiCtrl = TextEditingController();

  final List<GlobalKey<TankBlockState>> _tankKeys = [];
  final List<Tank> _tanks = [];

  @override
  void initState() {
    super.initState();
    if (widget.calibration != null) {
      final c = widget.calibration!;
      _clientCtrl.text = c.client;
      _addressCtrl.text = c.workAddress;
      _dateCtrl.text = c.date;
      _carModelCtrl.text = c.carModel;
      _grzCtrl.text = c.grz;
      _atModelCtrl.text = c.atModel;
      _atImeiCtrl.text = c.atImei;
      for (final t in c.tanks) {
        _tanks.add(t);
        _tankKeys.add(GlobalKey<TankBlockState>());
      }
    } else {
      _addTank();
    }
  }

  void _addTank() {
    setState(() {
      _tanks.add(Tank(name: 'ДУТ №${_tanks.length + 1}'));
      _tankKeys.add(GlobalKey<TankBlockState>());
    });
  }

  void _removeTank(int index) {
    setState(() {
      _tanks.removeAt(index);
      _tankKeys.removeAt(index);
    });
  }

  Future<void> _save() async {
    final updatedTanks = <Tank>[];
    for (int i = 0; i < _tankKeys.length; i++) {
      final state = _tankKeys[i].currentState;
      if (state != null) {
        updatedTanks.add(state.getTankData());
      } else {
        updatedTanks.add(_tanks[i]);
      }
    }

    final cal = Calibration(
      client: _clientCtrl.text,
      workAddress: _addressCtrl.text,
      date: _dateCtrl.text,
      carModel: _carModelCtrl.text,
      grz: _grzCtrl.text,
      atModel: _atModelCtrl.text,
      atImei: _atImeiCtrl.text,
      tanks: updatedTanks,
    );

    final cals = await _storage.loadCalibrations();
    if (widget.editIndex != null) {
      cals[widget.editIndex!] = cal;
    } else {
      cals.add(cal);
    }
    await _storage.saveCalibrations(cals);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _clientCtrl.dispose();
    _addressCtrl.dispose();
    _dateCtrl.dispose();
    _carModelCtrl.dispose();
    _grzCtrl.dispose();
    _atModelCtrl.dispose();
    _atImeiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editIndex != null ? 'Редактирование тарировки' : 'Новая тарировка'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          TextField(
            controller: _clientCtrl,
            decoration: const InputDecoration(labelText: 'Наименование клиента', prefixIcon: Icon(Icons.business)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressCtrl,
            decoration: const InputDecoration(labelText: 'Адрес проведения работ', prefixIcon: Icon(Icons.location_on)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dateCtrl,
            decoration: const InputDecoration(labelText: 'Дата тарировки', prefixIcon: Icon(Icons.calendar_today)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _carModelCtrl,
            decoration: const InputDecoration(labelText: 'Марка ТС', prefixIcon: Icon(Icons.directions_car)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _grzCtrl,
            decoration: const InputDecoration(labelText: 'Г.Р.З.', prefixIcon: Icon(Icons.pin)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _atModelCtrl,
            decoration: const InputDecoration(labelText: 'Марка АТ (Терминала)', prefixIcon: Icon(Icons.router)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _atImeiCtrl,
            decoration: const InputDecoration(labelText: 'Идентификатор АТ (IMEI)', prefixIcon: Icon(Icons.numbers)),
            keyboardType: TextInputType.number,
          ),
          const Divider(height: 32),
          const Text('Тарировочные таблицы и ДУТ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List.generate(_tanks.length, (index) {
            return TankBlock(
              key: _tankKeys[index],
              tank: _tanks[index],
              onDelete: () => _removeTank(index),
            );
          }),
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton.icon(
              onPressed: _addTank,
              icon: const Icon(Icons.add_box),
              label: const Text('Добавить бак / ДУТ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2979FF),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const Divider(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Сохранить тарировку'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
