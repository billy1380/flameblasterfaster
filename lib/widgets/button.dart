import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final String text;
  final String normal;
  final String hover;
  final String pressed;
  final VoidCallback onPressed;

  Button(
    this.text,
    this.normal, {
    this.hover = "",
    this.pressed = "",
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  _ButtonState createState() => _ButtonState(text, normal,
      hover: hover, pressed: pressed, onPressed: onPressed);
}

class _ButtonState extends State<Button> {
  final String text;
  final String normal;
  final String hover;
  final String pressed;
  final VoidCallback onPressed;

  bool _hover = false;
  bool _pressed = false;

  _ButtonState(
    this.text,
    this.normal, {
    this.hover = "",
    this.pressed = "",
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTapDown: (d) => setState(() => _pressed = true),
        onTap: onPressed,
        onTapUp: (d) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: Stack(alignment: Alignment.center, children: <Widget>[
          MouseRegion(
            onEnter: (e) => _mouseEnter(true),
            onExit: (e) => _mouseEnter(false),
            child: Image.asset(
              _pressed
                  ? (pressed == "" ? normal : pressed)
                  : _hover
                      ? (hover == "" ? normal : hover)
                      : normal,
              scale: .5,
            ),
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontFamily: "m5x7", color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }

  void _mouseEnter(bool state) {
    setState(() {
      _hover = state;
    });
  }
}
