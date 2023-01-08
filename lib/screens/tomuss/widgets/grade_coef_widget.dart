import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/screens/tomuss/tomuss_export.dart';
import 'package:sizer/sizer.dart';

class GradeCoefWidget extends StatefulWidget {
  const GradeCoefWidget({
    Key? key,
    required this.grades,
  }) : super(key: key);

  final List<GradeModel> grades;

  @override
  State<GradeCoefWidget> createState() => _GradeCoefWidgetState();
}

class _GradeCoefWidgetState extends State<GradeCoefWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = (widget.grades.first.coef ?? "").toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 2.w),
      child: SizedBox(
        width: 8.h,
        height: 8.h,
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).textTheme.bodyText1!.color!),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).textTheme.bodyText1!.color!,
              ),
            ),
            hintText: "1.0",
          ),
          onChanged: (value) {
            context.read<TomussCubit>().updateCoef(widget.grades.first,
                (value.isNotEmpty) ? double.parse(value) : null);
          },
        ),
      ),
    );
  }
}