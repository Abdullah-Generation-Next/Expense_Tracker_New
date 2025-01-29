import 'package:etmm/const/const.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  bool loading;
  RoundButton({Key? key, required this.title, required this.onTap, this.loading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Material(
        color: Colors.white,
        child: InkWell(
          // focusColor: Colors.transparent,
          // hoverColor: Colors.white,
          splashColor: Colors.white,
          // hoverColor: Colors.transparent,
          onTap: onTap,
          child: Container(
            height: 50,
            width: 100,
            decoration: BoxDecoration(color: themecolor, borderRadius: BorderRadius.circular(25)),
            child: Center(
              child: loading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                      color: Colors.white,
                    )
                  : Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }
}
