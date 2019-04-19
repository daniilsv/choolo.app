import 'package:flutter/material.dart';

class NumberWidget extends StatelessWidget {
  final String number;
  final double size;
  final GestureTapCallback onTap;
  NumberWidget(this.number, this.size, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1.0, offset: Offset(1.0, 1.0))],
        color: Colors.white,
      ),
      child: InkWell(
        child: SizedBox(
            height: size - 20,
            width: size - 20,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(number, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400)),
            )),
        onTap: onTap,
      ),
    );
  }
}
