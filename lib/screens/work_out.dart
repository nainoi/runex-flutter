// ignore_for_file: prefer_const_constructors, unnecessary_new
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:runex/screens/screens.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:runex/databases/databases.dart';
import 'dart:convert' as convert;
import 'package:runex/models/models.dart';

convert.JsonEncoder encoder = new convert.JsonEncoder.withIndent("     ");

class WorkOut extends StatefulWidget {
  const WorkOut({Key? key}) : super(key: key);

  @override
  _WorkOutState createState() => _WorkOutState();
}

class _WorkOutState extends State<WorkOut> {
  // Fetch location in background state variables
  late SharedPreferences prefs;

  late bool _canDisplayMap = false;

  late bool _isStartedRun = false;
  late bool _isPaused = false;

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _isStartedRun = prefs.getBool('_isStartedRun') ?? false;
    _isPaused = prefs.getBool('_isPaused') ?? false;
    _runexId = prefs.getInt('_runexId') ?? 0;
    if (_isStartedRun) {
      _refreshPolyLines();
    }
  }

  late int _runexId = 0;
  late String _odometer;
  late dynamic _content;

  // Google map and Polyline state variables
  GoogleMapController? controller;
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  PolylineId? selectedPolyline;
  final List<LatLng> points = <LatLng>[];
  late LatLng _target = LatLng(15.8700, 100.9925);

  _timer() {
    Timer(const Duration(seconds: 1), () {
      setState(() {
        _canDisplayMap = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
    _timer();
    _content = '';
    _odometer = 0.00.toStringAsFixed(2);

    // 1.  Listen to events (See docs for all 12 available events).
    bg.BackgroundGeolocation.onLocation(_onLocation);
    bg.BackgroundGeolocation.onProviderChange(_onProviderChange);

    // 2.  Configure the plugin
    bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        reset: true));
  }

  // Fetch location in background functions
  _startRun() async {
    try {
      bg.BackgroundGeolocation.start();
      await bg.BackgroundGeolocation.setOdometer(0.0);
      _onClickGetCurrentPosition();
      await RunexDatabase.instance
          .create(Runex(timestamp: DateTime.now().toString(), isSaved: false));
      _refreshRunex();
      prefs.setBool('_isStartedRun', true);
      setState(() {
        _isStartedRun = true;
      });
    } catch (e) {
      // Alert somrthing
    }
  }

  _pauseRun() {
    prefs.setBool('_isPaused', true);
    setState(() {
      _isPaused = true;
    });
  }

  _unpause() {
    prefs.setBool('_isPaused', false);
    setState(() {
      _isPaused = false;
    });
  }

  _stopRun() async {
    prefs.setBool('_isStartedRun', false);
    prefs.setBool('_isPaused', false);
    setState(() {
      _isStartedRun = false;
      _isPaused = false;
      points.clear();
    });
    bg.BackgroundGeolocation.stop().then((bg.State state) {
      // reset odometer
      bg.BackgroundGeolocation.setOdometer(0.0);
      bg.BackgroundGeolocation.destroyLocations();
      setState(() {
        _odometer = '0.0';
      });
    });
    prefs.remove('_runexId');
    prefs.remove('_isStartedRun');
    prefs.remove('_isPaused');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WorkOutResult()));
  }

  _refreshRunex() async {
    final runexList = await RunexDatabase.instance.read();
    prefs.setInt('_runexId', runexList.length);
    final id = prefs.getInt('_runexId');
    setState(() {
      _runexId = id!;
    });
  }

  // Manually fetch the current position.
  void _onClickGetCurrentPosition() {
    bg.BackgroundGeolocation.getCurrentPosition(
            persist: false, // <-- do not persist this location
            desiredAccuracy: 0, // <-- desire best possible accuracy
            timeout: 30000, // <-- wait 30s before giving up.
            samples: 3 // <-- sample 3 location before selecting best.
            )
        .then((bg.Location location) {
      dynamic data = convert.jsonDecode(encoder.convert(location.toMap()));
      _target = LatLng(data['coords']['latitude'], data['coords']['longitude']);
      controller?.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: _target, bearing: 270.0, tilt: 30.0, zoom: 17.0)));
    }).catchError((error) {
      print('[getCurrentPosition] ERROR: $error');
    });
  }

  void _onLocation(bg.Location location) async {
    String odometerKM = (location.odometer / 1000.0).toStringAsFixed(2);
    if (mounted) {
      setState(() {
        _content = encoder.convert(location.toMap());
        _odometer = odometerKM;
      });
    }
    dynamic data = convert.jsonDecode(_content);
    if (_runexId > 0 && _isStartedRun && !_isPaused && data['is_moving']) {
      try {
        final _runexId = prefs.getInt('_runexId');
        final id = await LocationDatabase.instance.create(
          Location(
              latitude: data['coords']['latitude'],
              longitude: data['coords']['longitude'],
              timestamp: data['timestamp'],
              runexId: _runexId!),
        );
        _updatePolyLines(
            id, data['coords']['latitude'], data['coords']['longitude']);
      } catch (e) {
        // Alert
      }
    }
  }

  void _onProviderChange(bg.ProviderChangeEvent event) {
    setState(() {
      _content = encoder.convert(event.toMap());
    });
  }

  // Google map and Polyline functions
  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPolylineTapped(PolylineId polylineId) {
    setState(() {
      selectedPolyline = polylineId;
    });
  }

  void _refreshPolyLines() async {
    _onClickGetCurrentPosition();
    List<Location> location =
        await LocationDatabase.instance.readByRunexId(_runexId);
    for (var i = 0; i < location.length; i++) {
      setState(() {
        points.add(_createLatLng(location[i].latitude, location[i].longitude));
      });
      final String polylineIdVal = 'polyline_id_$i';
      final PolylineId polylineId = PolylineId(polylineIdVal);

      final Polyline polyline = Polyline(
        polylineId: polylineId,
        consumeTapEvents: true,
        color: Colors.orange,
        width: 10,
        points: points,
        onTap: () {
          _onPolylineTapped(polylineId);
        },
      );

      setState(() {
        polylines[polylineId] = polyline;
      });
    }
  }

  void _updatePolyLines(int id, double lat, double lng) async {
    setState(() {
      points.add(_createLatLng(lat, lng));
    });

    final String polylineIdVal = 'polyline_id_$id';
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.orange,
      width: 10,
      points: points,
      onTap: () {
        _onPolylineTapped(polylineId);
      },
    );

    setState(() {
      polylines[polylineId] = polyline;
    });
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Runex'),
        ),
        body: Column(
          children: [
            Flexible(
                flex: 1,
                child: Container(
                  child: _canDisplayMap
                      ? GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(15.8700, 100.9925),
                            zoom: 7.0,
                          ),
                          polylines: Set<Polyline>.of(polylines.values),
                          onMapCreated: _onMapCreated,
                        )
                      : null,
                )),
            Flexible(
              flex: 1,
              child: Container(
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
                  child: Center(
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            Text(
                              'ระยะทาง(km)',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              _odometer,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 45,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              RunDetail(
                                  title: 'ระยะเวลา', subTitle: '00:00:00'),
                              RunDetail(
                                  title: 'Pace(min/km)', subTitle: '00:00'),
                              RunDetail(title: 'แคลอรี่(cal)', subTitle: '0'),
                            ],
                          ),
                        ),
                        !_isStartedRun && !_isPaused
                            ? RunButton(
                                onTap: () {
                                  _startRun();
                                },
                                title: 'จับเวลา',
                                icon: Icons.play_circle_fill_outlined,
                                iconColor: Colors.yellow,
                              )
                            : _isStartedRun && !_isPaused
                                ? RunButton(
                                    onTap: () {
                                      _pauseRun();
                                    },
                                    title: 'พักจับเวลา',
                                    icon: Icons.pause_circle_filled_outlined,
                                    iconColor: Colors.yellow,
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      RunButton(
                                        onTap: () {
                                          _stopRun();
                                        },
                                        title: 'จบการจับเวลา',
                                        icon: Icons.stop_circle_outlined,
                                        iconColor: Colors.white,
                                      ),
                                      RunButton(
                                        onTap: () {
                                          _unpause();
                                        },
                                        title: 'จับเวลาต่อ',
                                        icon: Icons.play_circle_fill_outlined,
                                        iconColor: Colors.yellow,
                                      )
                                    ],
                                  )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class RunButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final IconData icon;
  final Color iconColor;
  const RunButton({
    Key? key,
    required this.onTap,
    required this.title,
    required this.iconColor,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(
            icon,
            size: 100,
            color: iconColor,
          ),
        ),
        SizedBox(height: 8),
        Text(title,
            style: TextStyle(
                color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w400))
      ],
    );
  }
}

class RunDetail extends StatelessWidget {
  final String title;
  final String subTitle;
  const RunDetail({
    Key? key,
    required this.title,
    required this.subTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        Text(title,
            style: TextStyle(
                color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w400)),
        SizedBox(height: 8),
        Text(subTitle,
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
