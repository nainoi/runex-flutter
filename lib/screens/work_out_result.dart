// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WorkOutResult extends StatefulWidget {
  const WorkOutResult({Key? key}) : super(key: key);

  @override
  _WorkOutResultState createState() => _WorkOutResultState();
}

class _WorkOutResultState extends State<WorkOutResult> {
  final Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        centerTitle: true,
        title: Text('สรุปผล'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.file_upload_outlined))
        ],
      ),
      body: Column(
        children: [
          Flexible(
              flex: 3,
              child: Container(
                // color: Colors.white,
                child: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              )),
          Flexible(
              flex: 1,
              child: Container(
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [_RunDetail()],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _RunDetail extends StatelessWidget {
  const _RunDetail({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Text('ระยะทาง(km)',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w400)),
          Text('0.02',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
