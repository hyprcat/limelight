import 'package:flutter/material.dart';
import 'package:lime_time_app/defaults/fonts.dart';

class MetricWidget extends StatelessWidget {
  final String label;
  final String value;
  const MetricWidget({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              child: Text(
                value,
                style: defaultLabelText(context,
                    fontWeight: FontWeight.bold,
                    fontColor: Theme.of(context).colorScheme.primary),
              )),
          Text(label,
              style: defaultSmallLabel(context,
                  fontColor: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}
