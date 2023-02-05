import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final String text;
  final String normal;
  final String hover;
  final String pressed;
  final VoidCallback onPressed;

  const Button(
    this.text,
    this.normal, {
    this.hover = "",
    this.pressed = "",
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTapDown: (d) => setState(() => _pressed = true),
        onTap: widget.onPressed,
        onTapUp: (d) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: Stack(alignment: Alignment.center, children: <Widget>[
          MouseRegion(
            onEnter: (e) => _mouseEnter(true),
            onExit: (e) => _mouseEnter(false),
            child: Image.asset(
              _pressed
                  ? (widget.pressed == "" ? widget.normal : widget.pressed)
                  : _hover
                      ? (widget.hover == "" ? widget.normal : widget.hover)
                      : widget.normal,
              scale: .5,
            ),
          ),
          Text(
            widget.text,
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
