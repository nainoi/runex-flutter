// ignore_for_file: prefer_const_constructors, unnecessary_new
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

late ValueNotifier _positionStreamSubscription =
    ValueNotifier(StreamSubscription<Position>);
final LocationSettings _locationSettings =
    LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 1);

late ValueNotifier _latitude = ValueNotifier(<double>[]);
late ValueNotifier _longitude = ValueNotifier(<double>[]);

Future<void> _startRunex() async {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "fetchBackground":
        print('######################### Call task #########################');
        _positionStreamSubscription.value =
            Geolocator.getPositionStream(locationSettings: _locationSettings)
                .listen((Position? position) {
          _latitude.value.add(position?.latitude.toDouble());
          _longitude.value.add(position?.longitude.toDouble());
          print('Position: ${position?.latitude.toString()}');
        });
        print('Value: ${_positionStreamSubscription.value}');
        // Position userLocation = await Geolocator.getCurrentPosition(
        //     desiredAccuracy: LocationAccuracy.high);
        // notify.Notification notification = new notify.Notification();
        // notification.showNotificationWithoutSound(userLocation);

        // break;
    }
    return Future.value(true);
  });
}

class WorkOut extends StatefulWidget {
  const WorkOut({Key? key}) : super(key: key);

  @override
  _WorkOutState createState() => _WorkOutState();
}

class _WorkOutState extends State<WorkOut> {
  late bool _startedRunex = false;

  void _run() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permission are permanently denied, we cannot request permission.');
    }
    Workmanager().initialize(_startRunex, isInDebugMode: true);

    // Workmanager().registerPeriodicTask("1", "fetchBackground",
    //     frequency: Duration(minutes: 1));
    Workmanager().registerOneOffTask('1', 'fetchBackground');
    setState(() {
      _startedRunex = true;
    });
  }

  Future<void> _pauseRunex() async {
    if (!_positionStreamSubscription.value!.isPaused) {
      setState(() {
        _startedRunex = false;
        //  _positionStreamSubscription.value = _positionStreamSubscription.value?.pause();
      });
      print(
          '_positionStreamSubscription.value = : ${_positionStreamSubscription.value!.isPaused}');
    }
  }

  Future<void> _resumeRunex() async {
    if (_positionStreamSubscription.value!.isPaused) {
      setState(() {
        _startedRunex = false;
        //  _positionStreamSubscription.value = _positionStreamSubscription.value?.resume();
      });
      print(
          '_positionStreamSubscription.value = : ${_positionStreamSubscription.value!.isPaused}');
    }
  }

  Future<void> _saveRunex() async {
    setState(() {
      // _latitude = [];
      // _longitude = [];
      _startedRunex = false;
      // _positionStreamSubscription.value = _positionStreamSubscription.value?.pause();
    });
    print(
        '_positionStreamSubscription.value = : ${_positionStreamSubscription.value!.isPaused}');
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
                'Work out page',
                style: TextStyle(fontSize: 28),
              ),
              SizedBox(height: 100),
              ValueListenableBuilder<dynamic>(
                  valueListenable: _latitude,
                  builder: (context, value, widget) {
                    return _latitude.value.length > 0
                        ? Container(
                            height: 500,
                            child: ListView.builder(
                                itemCount: _latitude.value.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                        'Latitude: ${_latitude.value[index]}\tLongitude: ${_longitude.value[index]}'),
                                  );
                                }))
                        : Text('Nothin');
                  }),
              !_startedRunex
                  ? TextButton(
                      onPressed: () {
                        _run();
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
