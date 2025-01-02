import 'package:flutter/material.dart';

class Vote extends StatefulWidget {
  const Vote({super.key});

  @override
  State<Vote> createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("투표"),
        )
    );
  }
}
