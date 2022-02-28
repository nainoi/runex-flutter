// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:runex/databases/databases.dart';
import 'package:runex/models/models.dart';
import 'package:runex/screens/widgets/widgets.dart';
import 'package:runex/services/firestore_database/firestore_database.dart';
import 'package:runex/utils/datetime_utils.dart';

class WorkOutResult extends StatefulWidget {
  final int runexId;
  final bool isSend;
  final dynamic? runexFirestore;
  const WorkOutResult(
      {Key? key,
      required this.runexId,
      required this.isSend,
      this.runexFirestore})
      : super(key: key);

  @override
  _WorkOutResultState createState() => _WorkOutResultState();
}

class _WorkOutResultState extends State<WorkOutResult> {
  late List<Location> _locations = [];
  late List<Runex> _runex = [];
  GoogleMapController? _controller;
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  PolylineId? selectedPolyline;
  final List<LatLng> points = <LatLng>[];
  late bool _isLoading = false;
  bool hasInternet = false;
  ConnectivityResult result = ConnectivityResult.none;
  late StreamSubscription subscription;
  late StreamSubscription internetSubscription;

  _getRunexAndLocation() async {
    final runex = await RunexDatabase.instance.readById(widget.runexId);
    final locations =
        await LocationDatabase.instance.readByRunexId(widget.runexId);

    if (mounted) {
      setState(() {
        _runex = runex;
        _locations = locations;
      });
    }
    if (_locations.isNotEmpty) {
      _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(_locations[0].latitude, _locations[0].longitude),
          bearing: 270.0,
          tilt: 30.0,
          zoom: 17.0)));
    }

    for (var i = 0; i < _locations.length; i++) {
      setState(() {
        points.add(
            _createLatLng(_locations[i].latitude, _locations[i].longitude));
      });
      final String polylineIdVal = 'polyline_id_$i';
      final PolylineId polylineId = PolylineId(polylineIdVal);

      final Polyline polyline = Polyline(
        polylineId: polylineId,
        consumeTapEvents: true,
        color: Colors.orange,
        width: 10,
        points: points,
      );
      setState(() {
        polylines[polylineId] = polyline;
      });
    }
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }

  _formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  Future _onSubmit() async {
    try {
      final isConnected = context.read<ConnectivityProvider>().isOnline;
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
        });
        RunexFirestoreDatabase runexFirestoreDatabase =
            new RunexFirestoreDatabase();
        FirestoreReturn response =
            await runexFirestoreDatabase.create(_runex[0]);
        if (response.success) {
          for (var i = 0; i < _locations.length; i++) {
            if (isConnected) {
              LocationFirestoreDatabase locationFirestoreDatabase =
                  new LocationFirestoreDatabase();
              FirestoreReturn locResponse =
                  await locationFirestoreDatabase.create(Location(
                      id: _locations[i].id,
                      runexId: 0,
                      odometer: _locations[i].odometer,
                      docId: response.data,
                      altitude: _locations[i].altitude,
                      heading: _locations[i].heading,
                      latitude: _locations[i].latitude,
                      accuracy: _locations[i].accuracy,
                      headingAccuracy: _locations[i].headingAccuracy,
                      altitudeAccuracy: _locations[i].altitudeAccuracy,
                      speedAccuracy: _locations[i].speedAccuracy,
                      speed: _locations[i].speed,
                      longitude: _locations[i].longitude,
                      timestamp: _locations[i].timestamp,
                      isMoveing: _locations[i].isMoveing,
                      confidence: _locations[i].confidence,
                      type: _locations[i].type,
                      isCharging: _locations[i].isCharging,
                      level: _locations[i].level));
              if (locResponse.success) {
                await LocationDatabase.instance.delete(_locations[i].id!);
              }
            } else {
              runningProgressDialog.hideDialog();
            }
          }
          if (isConnected) {
            List<Location> locations =
                await LocationDatabase.instance.readByRunexId(widget.runexId);
            if (locations.isEmpty) {
              FirestoreReturn updateRunexRes =
                  await runexFirestoreDatabase.update(response.data, true);
              if (updateRunexRes.success) {
                await RunexDatabase.instance.delete(_runex[0].id!);
              } else {
                await RunexDatabase.instance.update(Runex(
                    providerId: _runex[0].providerId,
                    monthAndYear: _runex[0].monthAndYear,
                    docId: response.data,
                    startTime: _runex[0].startTime,
                    isSaved: _runex[0].isSaved));
              }
            }
            runningProgressDialog.hideDialog();
            successProgressDialog = new ShowAlertDialog(
                context: context,
                title: "ส่งผลสำเร็จ",
                content: "",
                onPress: () {
                  successProgressDialog.hideDialog();
                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.pop(context);
                },
                actionText: "ตกลง");
            successProgressDialog.successDialog();
          } else {
            runningProgressDialog.hideDialog();
          }
        } else {}
      }
    } catch (e) {}
  }

  late ShowAlertDialog runningProgressDialog;
  late ShowAlertDialog successProgressDialog;
  late ShowAlertDialog internetAlert;

  void _onProgress() async {
    final isConnected = context.read<ConnectivityProvider>().isOnline;
    if (isConnected) {
      runningProgressDialog = new ShowAlertDialog(
          context: context,
          title: "กรุณารอสักครู่...",
          content: "กำลังส่งผลการวิ่ง",
          actionText: "",
          onPress: () {});
      runningProgressDialog.progressAlert();
      await _onSubmit();
    } else {}
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isSend) {
      _getRunexAndLocation();
    }
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
  }

  Widget _body() {
    return Consumer<ConnectivityProvider>(builder: (context, model, child) {
      return model.isOnline
          ? Column(
              children: [
                Flexible(
                    flex: 3,
                    child: Stack(
                        // color: Colors.white,
                        children: [
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [Colors.black38, Colors.transparent],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.colorBurn,
                            child: GoogleMap(
                              // mapType: MapType.terrain,
                              initialCameraPosition: const CameraPosition(
                                target: LatLng(15.8700, 100.9925),
                                zoom: 7.0,
                              ),
                              polylines: Set<Polyline>.of(polylines.values),
                              onMapCreated: (GoogleMapController controller) {
                                _controller = controller;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: [
                                    Text(
                                      'ระยะทาง',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 22),
                                    ),
                                    Text(
                                      _locations.isNotEmpty && !widget.isSend
                                          ? _runex[0].distanceKm.toString()
                                          : widget.isSend
                                              ? widget.runexFirestore[
                                                      'distance_total_km']
                                                  .toString()
                                              : "0.00(km)",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: [
                                    Text(
                                      'ระยะเวลา',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 22),
                                    ),
                                    Text(
                                      _runex.isNotEmpty && !widget.isSend
                                          ? _formatTime(
                                              ((_runex[0].timeHrs)! * 3600)
                                                  .round())
                                          : widget.isSend
                                              ? _formatTime((widget
                                                              .runexFirestore[
                                                          'time_total_hours'] *
                                                      3600)
                                                  .round())
                                              : '00:00:00',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Wrap(children: [
                                      Text(
                                        _runex.isNotEmpty && !widget.isSend
                                            ? _runex[0].startTime
                                            : widget.isSend
                                                ? DateTimeUtils.getFullDate(
                                                    DateTime.parse(widget
                                                        .runexFirestore[
                                                            'start_time']
                                                        .toString()))
                                                : '00:00:00',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ])),
                Flexible(
                    flex: 2,
                    child: Container(
                      color: Colors.grey[800],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            _RunDetail(
                              title: 'ระยะทาง(km)',
                              subTitle: _locations.isNotEmpty && !widget.isSend
                                  ? _runex[0].distanceKm.toString()
                                  : widget.isSend
                                      ? widget
                                          .runexFirestore['distance_total_km']
                                          .toString()
                                      : '0.00',
                            ),
                            _RunDetail(
                              title: 'ระยะเวลา',
                              subTitle: _runex.isNotEmpty && !widget.isSend
                                  ? _formatTime(
                                      ((_runex[0].timeHrs)! * 3600).round())
                                  : widget.isSend
                                      ? _formatTime((widget.runexFirestore[
                                                  'time_total_hours'] *
                                              3600)
                                          .round())
                                      : '00:00:00',
                            ),
                            _RunDetail(
                              title: '(min/km)',
                              subTitle: '00:00',
                            ),
                            _RunDetail(
                              title: 'แคลอรี่(cal)',
                              subTitle: '0.00',
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6, bottom: 6),
                              child: Divider(
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6, bottom: 6),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!widget.isSend) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                              title:
                                                  const Text("ยืนยันการส่งผล"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('ยกเลิก'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    _onProgress();
                                                  },
                                                  child: const Text('ยืนยัน'),
                                                ),
                                              ],
                                            ));
                                  }
                                },
                                child: Text(
                                  'ส่งผล',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                    fixedSize: Size(150, 50),
                                    primary: !widget.isSend
                                        ? Colors.amber[300]
                                        : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)))),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Icon(
                    Icons.wifi_off_outlined,
                    color: Colors.grey,
                    size: 100,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "ขาดการเชื่อมต่ออินเตอร์เน็ต",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  )
                ],
              ),
            );
    });
  }

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
        body: _body());
  }
}

class _RunDetail extends StatelessWidget {
  final String title;
  final String subTitle;
  const _RunDetail({
    Key? key,
    required this.title,
    required this.subTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w400)),
          Text(subTitle,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
