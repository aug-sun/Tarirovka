import 'package:flutter/material.dart';

class TankVisual extends StatefulWidget {
  final double initialX;
  final double initialY;
  final ValueChanged<Offset> onChanged;

  const TankVisual({
    super.key,
    required this.initialX,
    required this.initialY,
    required this.onChanged,
  });

  @override
  State<TankVisual> createState() => _TankVisualState();
}

class _TankVisualState extends State<TankVisual> {
  late double _x;
  late double _y;

  @override
  void initState() {
    super.initState();
    _x = widget.initialX;
    _y = widget.initialY;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        setState(() {
          _x = details.localPosition.dx.clamp(0.0, 340.0);
          _y = details.localPosition.dy.clamp(0.0, 120.0);
        });
        widget.onChanged(Offset(_x, _y));
      },
      child: Container(
        height: 130,
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2C2C2C)
              : const Color(0xFFECEFF1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                width: 330,
                height: 110,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF78909C)
                        : const Color(0xFF37474F),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            Positioned(
              left: _x - 7,
              top: _y - 7,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF5350),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
