import 'package:flutter/material.dart';

class MultipartusTitle extends StatelessWidget {
  const MultipartusTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        text: 'MULTI',
        children: [
          TextSpan(
            text: 'PARTUS',
            style: TextStyle(
              color: Color(0xFF434C5D),
            ),
          ),
        ],
      ),
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.w700,
        letterSpacing: 8,
        height: 1,
      ),
    );
  }
}
