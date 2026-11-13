import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HIconButton extends StatelessWidget {
  final IconData icon;
  final Function? onTap;
  const HIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).cardColor,
        child: IconButton(
          icon: Icon(
            icon,
            size: 19,
          ),
          onPressed: () {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
          },
        ),
      ),
    );
  }
}
