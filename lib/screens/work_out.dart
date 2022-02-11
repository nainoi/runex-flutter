// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class WorkOut extends StatefulWidget {
  const WorkOut({Key? key}) : super(key: key);

  @override
  _WorkOutState createState() => _WorkOutState();
}

class _WorkOutState extends State<WorkOut> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(child: Center(
          child: Column(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Text('Work out page',)
            ],
          ),
        )),
      ),
    );
  }
}
