// ignore_for_file: prefer_const_constructors
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class WorkOut extends StatefulWidget {
  const WorkOut({Key? key}) : super(key: key);

  @override
  _WorkOutState createState() => _WorkOutState();
}

class _WorkOutState extends State<WorkOut> {
  late bool _startedRunex = false;
  late List _latitude = [];
  late List _longitude = [];

  final LocationSettings _locationSettings =
      LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 1);

  Future<void> _startRunex() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permission are permanently demied, we cannot request permission.');
    } else if (permission == LocationPermission.denied) {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission are denied');
      }
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (serviceEnabled && !_startedRunex) {
      setState(() {
        _startedRunex = true;
      });
      // late int count = 0;
      StreamSubscription<Position> positionStream =
          Geolocator.getPositionStream(locationSettings: _locationSettings)
              .listen((Position? position) {
        setState(() {
          _latitude.add(position?.latitude.toDouble());
          _longitude.add(position?.longitude.toDouble());
        });
      });
    }
  }

  Future<void> _pauseRunex() async {
    if (_startedRunex) {
      setState(() {
        _startedRunex = false;
      });
    }
  }

  Future<void> _saveRunex() async {
    setState(() {
      _latitude = [];
      _longitude = [];
      _startedRunex = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            child: Center(
          child: Column(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Text(
                'Work out page', style: TextStyle(fontSize: 28),
              ),
              SizedBox(height: 100),
              Text(
                  'Latitude count: ${_latitude.length}\tLongitude count: ${_longitude.length}'),
              SizedBox(height: 20),
              Container(
                  height: 500,
                  child: ListView.builder(
                      itemCount: _latitude.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              'Latitude: ${_latitude[index]}\tLongitude: ${_longitude[index]}'),
                        );
                      })),
              !_startedRunex
                  ? TextButton(
                      onPressed: () {
                        _startRunex();
                      },
                      child: Column(
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          Icon(
                            Icons.play_arrow,
                            size: 30,
                          ),
                          Text('Start')
                        ],
                      ))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TextButton(
                        //     onPressed: () {
                        //       _pauseRunex();
                        //     },
                        //     child: Column(
                        //       // ignore: prefer_const_literals_to_create_immutables
                        //       children: [
                        //         Icon(
                        //           Icons.pause_circle_filled_outlined,
                        //           size: 30,
                        //         ),
                        //         Text('Pause')
                        //       ],
                        //     )),
                        TextButton(
                            onPressed: () {
                              _saveRunex();
                            },
                            child: Column(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                Icon(
                                  Icons.stop_circle,
                                  size: 30,
                                ),
                                Text('Save')
                              ],
                            )),
                      ],
                    )
            ],
          ),
        )),
      ),
    );
  }
}
