import 'package:flutter/material.dart';
import '../models/tank.dart';
import '../models/table_row_data.dart';
import 'tank_visual.dart';

class TankBlock extends StatefulWidget {
  final Tank tank;
  final VoidCallback onDelete;

  const TankBlock({
    super.key,
    required this.tank,
    required this.onDelete,
  });

  @override
  State<TankBlock> createState() => TankBlockState();
}

class TankBlockState extends State<TankBlock> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _dutModelCtrl;
  late final TextEditingController _dutSnCtrl;
  late final TextEditingController _dutLengthCtrl;
  late final TextEditingController _tankDepthCtrl;
  late final TextEditingController _tankCapacityCtrl;
  late final TextEditingController _sealBodyCtrl;
  late final TextEditingController _sealConnectorCtrl;
  late final TextEditingController _filtrationCtrl;
  late final TextEditingController _poursCtrl;
  late final TextEditingController _stepCtrl;

  final List<TextEditingController> _ueCtrls = [];
  final List<TextEditingController> _litCtrls = [];
  final List<FocusNode> _ueFocusNodes = [];
  final List<FocusNode> _litFocusNodes = [];

  Set<int> _duplicateUeIndices = {};
  Set<int> _duplicateLitIndices = {};

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.tank.name);
    _dutModelCtrl = TextEditingController(text: widget.tank.dutModel);
    _dutSnCtrl = TextEditingController(text: widget.tank.dutSn);
    _dutLengthCtrl = TextEditingController(text: widget.tank.dutLength);
    _tankDepthCtrl = TextEditingController(text: widget.tank.tankDepth);
    _tankCapacityCtrl = TextEditingController(text: widget.tank.tankCapacity);
    _sealBodyCtrl = TextEditingController(text: widget.tank.sealBody);
    _sealConnectorCtrl = TextEditingController(text: widget.tank.sealConnector);
    _filtrationCtrl = TextEditingController(text: widget.tank.filtrationDegree);
    _poursCtrl = TextEditingController();
    _stepCtrl = TextEditingController();

    for (final r in widget.tank.table) {
      _addRow(ue: r.ue, lit: r.liters);
    }
    _validateDuplicates();
  }

  void _addRow({String ue = '', String lit = ''}) {
    final ueCtrl = TextEditingController(text: ue);
    final litCtrl = TextEditingController(text: lit);
    final ueFn = FocusNode();
    final litFn = FocusNode();

    ueCtrl.addListener(_validateDuplicates);
    litCtrl.addListener(_validateDuplicates);

    _ueCtrls.add(ueCtrl);
    _litCtrls.add(litCtrl);
    _ueFocusNodes.add(ueFn);
    _litFocusNodes.add(litFn);
  }

  /// П.5 Валидация на повторяющиеся значения У.Е. и Литров
  void _validateDuplicates() {
    final ueMap = <String, List<int>>{};
    final litMap = <String, List<int>>{};

    for (int i = 0; i < _ueCtrls.length; i++) {
      final ueVal = _ueCtrls[i].text.trim();
      if (ueVal.isNotEmpty) {
        ueMap.putIfAbsent(ueVal, () => []).add(i);
      }
      final litVal = _litCtrls[i].text.trim();
      if (litVal.isNotEmpty) {
        litMap.putIfAbsent(litVal, () => []).add(i);
      }
    }

    final dupUe = <int>{};
    ueMap.forEach((key, list) {
      if (list.length > 1) dupUe.addAll(list);
    });

    final dupLit = <int>{};
    litMap.forEach((key, list) {
      if (list.length > 1) dupLit.addAll(list);
    });

    setState(() {
      _duplicateUeIndices = dupUe;
      _duplicateLitIndices = dupLit;
    });
  }

  /// П.4 Создаётся на 1 строчку больше, т.к. первая всегда (0, 0)
  void _generateRows() {
    final pours = int.tryParse(_poursCtrl.text) ?? 0;
    final step = int.tryParse(_stepCtrl.text) ?? 0;
    if (pours <= 0) return;

    setState(() {
      _clearRows();

      // Первая строка 0, 0
      _addRow(ue: '0', lit: '0');

      // Остальные pours строк
      for (int i = 1; i <= pours; i++) {
        _addRow(ue: '', lit: (i * step).toString());
      }
    });
    _validateDuplicates();
  }

  void _clearRows() {
    for (var c in _ueCtrls) c.dispose();
    for (var c in _litCtrls) c.dispose();
    for (var f in _ueFocusNodes) f.dispose();
    for (var f in _litFocusNodes) f.dispose();

    _ueCtrls.clear();
    _litCtrls.clear();
    _ueFocusNodes.clear();
    _litFocusNodes.clear();
  }

  void _addManualRow() {
    String nextLit = '0';
    if (_litCtrls.isNotEmpty) {
      final last = int.tryParse(_litCtrls.last.text) ?? 0;
      final step = int.tryParse(_stepCtrl.text) ?? 0;
      nextLit = (last + step).toString();
    }
    setState(() {
      _addRow(ue: '', lit: nextLit);
    });
    _validateDuplicates();
  }

  void _removeRow(int index) {
    setState(() {
      _ueCtrls[index].dispose();
      _litCtrls[index].dispose();
      _ueFocusNodes[index].dispose();
      _litFocusNodes[index].dispose();

      _ueCtrls.removeAt(index);
      _litCtrls.removeAt(index);
      _ueFocusNodes.removeAt(index);
      _litFocusNodes.removeAt(index);
    });
    _validateDuplicates();
  }

  Tank getTankData() {
    final table = <TableRowData>[];
    for (int i = 0; i < _ueCtrls.length; i++) {
      table.add(TableRowData(ue: _ueCtrls[i].text, liters: _litCtrls[i].text));
    }
    return Tank(
      name: _nameCtrl.text,
      dutModel: _dutModelCtrl.text,
      dutSn: _dutSnCtrl.text,
      dutLength: _dutLengthCtrl.text,
      tankDepth: _tankDepthCtrl.text,
      tankCapacity: _tankCapacityCtrl.text,
      sealBody: _sealBodyCtrl.text,
      sealConnector: _sealConnectorCtrl.text,
      filtrationDegree: _filtrationCtrl.text,
      sensorX: widget.tank.sensorX,
      sensorY: widget.tank.sensorY,
      table: table,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dutModelCtrl.dispose();
    _dutSnCtrl.dispose();
    _dutLengthCtrl.dispose();
    _tankDepthCtrl.dispose();
    _tankCapacityCtrl.dispose();
    _sealBodyCtrl.dispose();
    _sealConnectorCtrl.dispose();
    _filtrationCtrl.dispose();
    _poursCtrl.dispose();
    _stepCtrl.dispose();
    _clearRows();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Название таблицы/ДУТ', isDense: true),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Color(0xFFEF5350)),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dutModelCtrl,
                    decoration: const InputDecoration(labelText: 'Марка ДУТ', isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _dutSnCtrl,
                    decoration: const InputDecoration(labelText: 'S/N ДУТ', isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _filtrationCtrl,
                    decoration: const InputDecoration(labelText: 'Степень фильтрации', isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dutLengthCtrl,
                    decoration: const InputDecoration(labelText: 'Длина ДУТ (мм)', isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _tankDepthCtrl,
                    decoration: const InputDecoration(labelText: 'Глубина бака (мм)', isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _tankCapacityCtrl,
                    decoration: const InputDecoration(labelText: 'Ёмкость бака (л)', isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sealBodyCtrl,
                    decoration: const InputDecoration(labelText: 'Пломба (корпус)', isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _sealConnectorCtrl,
                    decoration: const InputDecoration(labelText: 'Пломба (разъем)', isDense: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _poursCtrl,
                    decoration: const InputDecoration(labelText: 'Кол-во проливов', isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _stepCtrl,
                    decoration: const InputDecoration(labelText: 'Шаг (л)', isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _generateRows,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2979FF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Создать'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_ueCtrls.length, (index) {
              final isUeDup = _duplicateUeIndices.contains(index);
              final isLitDup = _duplicateLitIndices.contains(index);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ueCtrls[index],
                        focusNode: _ueFocusNodes[index],
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_litFocusNodes[index]);
                        },
                        decoration: InputDecoration(
                          labelText: 'У.Е.',
                          isDense: true,
                          errorText: isUeDup ? 'Дубликат' : null,
                          enabledBorder: isUeDup
                              ? const OutlineInputBorder(borderSide: BorderSide(color: Colors.red))
                              : null,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _litCtrls[index],
                        focusNode: _litFocusNodes[index],
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) {
                          if (index + 1 < _ueFocusNodes.length) {
                            FocusScope.of(context).requestFocus(_ueFocusNodes[index + 1]);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Литры',
                          isDense: true,
                          errorText: isLitDup ? 'Дубликат' : null,
                          enabledBorder: isLitDup
                              ? const OutlineInputBorder(borderSide: BorderSide(color: Colors.red))
                              : null,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
                      onPressed: () => _removeRow(index),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addManualRow,
              icon: const Icon(Icons.add),
              label: const Text('Добавить строку'),
            ),
            const Divider(),
            const Text('Положение датчика на схеме бака:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            TankVisual(
              initialX: widget.tank.sensorX,
              initialY: widget.tank.sensorY,
              onChanged: (offset) {
                setState(() {
                  widget.tank.sensorX = offset.dx;
                  widget.tank.sensorY = offset.dy;
                });
              },
            ),
            const SizedBox(height: 4),
            ExpansionTile(
              title: const Text('Подстройка положения датчика (ползунки)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              initiallyExpanded: true,
              children: [
                Row(
                  children: [
                    const Text('X:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Expanded(
                      child: Slider(
                        value: widget.tank.sensorX,
                        min: 10,
                        max: 340,
                        label: widget.tank.sensorX.toStringAsFixed(0),
                        onChanged: (v) => setState(() => widget.tank.sensorX = v),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Y:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Expanded(
                      child: Slider(
                        value: widget.tank.sensorY,
                        min: 10,
                        max: 120,
                        label: widget.tank.sensorY.toStringAsFixed(0),
                        onChanged: (v) => setState(() => widget.tank.sensorY = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}