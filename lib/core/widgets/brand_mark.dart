import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final diameter = compact ? 58.0 : 86.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: diameter,
          height: diameter,
          decoration: const BoxDecoration(
            color: AppColors.navy,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.radio_rounded,
            color: AppColors.gold,
            size: compact ? 32 : 48,
          ),
        ),
        SizedBox(height: compact ? 10 : 16),
        Text(
          'HOPE FOR LIFE',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
        ),
        Text(
          'RADIO',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.red,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
        ),
      ],
    );
  }
}
