import 'package:flutter/material.dart';

class AdditionalInfoItem extends StatelessWidget {
  final IconData icon;
  final Text lable;
  final Text value;
  const AdditionalInfoItem(
      {super.key,
      required this.icon,
      required this.lable,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Colors.white,
        ),
        const SizedBox(
          height: 8,
        ),
        lable,
        const SizedBox(
          height: 8,
        ),
        value
      ],
    );
  }
}
