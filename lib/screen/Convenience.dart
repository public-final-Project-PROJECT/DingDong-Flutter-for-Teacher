import 'package:flutter/material.dart';

class Convenience extends StatefulWidget {
  const Convenience({super.key});

  @override
  State<Convenience> createState() => _ConvenienceState();
}

class _ConvenienceState extends State<Convenience> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("편의기능"),
        )
    );
  }
}
