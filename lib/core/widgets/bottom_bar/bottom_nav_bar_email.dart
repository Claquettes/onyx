import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BottomNavBarEmail extends StatelessWidget {
  const BottomNavBarEmail({Key? key, required this.selected}) : super(key: key);
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.email_rounded,
      color: selected ? Theme.of(context).primaryColor : Colors.white,
      size: 30.sp,
    );
  }
}
