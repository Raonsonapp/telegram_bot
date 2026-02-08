import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppLoading extends StatelessWidget {
  final String? text;
  final double size;

  const AppLoading({
    super.key,
    this.text,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (text != null) ...[
            const SizedBox(height: 14),
            Text(
              text!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
