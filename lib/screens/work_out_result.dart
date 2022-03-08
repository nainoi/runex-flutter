// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:runex/databases/databases.dart';
import 'package:runex/models/models.dart';
import 'package:runex/screens/widgets/widgets.dart';
import 'package:runex/services/firestore_database/firestore_database.dart';
import 'package:runex/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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
  late List<LocationModel> _locations = [];
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
  late SharedPreferences prefs;
  late String providerId = '';
  ScreenshotController screenshotController = ScreenshotController();

  intiPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      providerId = prefs.getString("providerID") ?? '';
    });
  }

  _getRunexAndLocationDb() async {
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

  _getLocationFirestor() async {
    LocationFirestoreDatabase locationFirestoreDatabase =
        LocationFirestoreDatabase();
    final locationFirestor =
        await locationFirestoreDatabase.readByRunexDocId(providerId);
    if (locationFirestor.success) {
      final List locationList = locationFirestor.data;
      if (locationList.isNotEmpty) {
        _controller?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(
                    locationList[0]['latitude'], locationList[0]['longitude']),
                bearing: 270.0,
                tilt: 30.0,
                zoom: 17.0)));

        for (var i = 0; i < locationList.length; i++) {
          setState(() {
            points.add(_createLatLng(
                locationList[i]['latitude'], locationList[i]['longitude']));
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
                  await locationFirestoreDatabase.create(LocationModel(
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
            List<LocationModel> locations =
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
            CustomDialog.customDialog1Actions(
                context,
                "ส่งผลสำเร็จ",
                "การส่งผลการวิ่งเสร็จสมบูรณ์",
                "ตกลง",
                Colors.white,
                Colors.amber,
                Colors.transparent, () {
              setState(() {
                _isLoading = false;
              });
              Navigator.pop(context);
              Navigator.pop(context);
            });
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
    intiPrefs();
    if (!widget.isSend) {
      _getRunexAndLocationDb();
    } else {
      _getLocationFirestor();
    }
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
  }

  late Uint8List imageFromMap;
  late XFile imageFromDevice;
  late bool _isSelectedImageFromDevice = false;

  _sharePopUp() async {
    final uin8list = await _controller?.takeSnapshot();
    final base64image = base64Encode(uin8list!);
    setState(() {
      imageFromMap = base64Decode(base64image);
    });

    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
              heightFactor: 0.85,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close_rounded)),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "แชร์",
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                      flex: 4,
                      child: RepaintBoundary(
                        key: _globalkey,
                        child: Screenshot(
                          controller: screenshotController,
                          child: Stack(children: [
                            ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.center,
                                    colors: [
                                      Colors.black38,
                                      Colors.transparent
                                    ],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.colorBurn,
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: _isSelectedImageFromDevice
                                        ? Image.file(File(imageFromDevice.path),
                                            fit: BoxFit.cover)
                                        : Image.memory(imageFromMap,
                                            fit: BoxFit.fill))),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(Assets.eventaLogoDesktop,
                                            height: 100, width: 100),
                                        GestureDetector(
                                          onTap: () {
                                            _pickImage();
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(50)),
                                                border: Border.all(
                                                    color: Colors.white),
                                                color: Colors.grey[300]),
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              size: 20,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          // ignore: prefer_const_literals_to_create_immutables
                                          children: [
                                            Text(
                                              'ระยะทาง',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              'ระยะเวลา',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _locations.isNotEmpty &&
                                                      !widget.isSend
                                                  ? "${_runex[0].distanceKm!.toStringAsFixed(2)}(km)"
                                                  : widget.isSend
                                                      ? "${widget.runexFirestore['distance_total_km'].toStringAsFixed(2)}(km)"
                                                      : "0.00(km)",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _runex.isNotEmpty &&
                                                      !widget.isSend
                                                  ? _formatTime(
                                                      ((_runex[0].timeHrs)! *
                                                              3600)
                                                          .round())
                                                  : widget.isSend
                                                      ? _formatTime(
                                                          (widget.runexFirestore[
                                                                      'time_total_hours'] *
                                                                  3600)
                                                              .round())
                                                      : '00:00:00',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          _runex.isNotEmpty && !widget.isSend
                                              ? DateTimeUtils
                                                  .getFullDateAndFullTime(
                                                      DateTime.parse(
                                                          _runex[0].startTime))
                                              : widget.isSend
                                                  ? DateTimeUtils
                                                      .getFullDateAndFullTime(
                                                          DateTime.parse(widget
                                                              .runexFirestore[
                                                                  'start_time']
                                                              .toString()))
                                                  : '00:00:00',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    )
                                  ]),
                            ),
                          ]),
                        ),
                      )),
                  Flexible(
                      flex: 2,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "แชร์",
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _shareToFacebook,
                                child: Text(
                                  'แชร์ภาพ',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                    fixedSize: Size(300, 50),
                                    primary: Colors.blue[900],
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)))),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _saveImage,
                                child: Text(
                                  'บันทึกภาพลงอุปกรณ์',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                    fixedSize: Size(300, 50),
                                    primary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.grey),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)))),
                              ),
                            ],
                          ),
                        ),
                      ))
                ],
              ));
        });
  }

  Future<bool> _requestPermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    } else {
      await Permission.storage.request();
      if (await Permission.storage.isDenied) {
        return false;
      } else {
        return true;
      }
    }
  }

  final GlobalKey _globalkey = new GlobalKey();

  void _saveImage() async {
    try {
      RenderRepaintBoundary boundary = _globalkey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData?.buffer.asUint8List();
      String fileName = (DateTime.now().microsecondsSinceEpoch).toString();
      await ImageGallerySaver.saveImage(Uint8List.fromList(pngBytes!),
          quality: 100, name: fileName);
    } catch (err) {}
  }

  _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      setState(() {
        imageFromDevice = file;
        _isSelectedImageFromDevice = true;
      });
      _sharePopUp();
    }
  }

  _shareToFacebook() async {
    try {
      await screenshotController.capture().then((image) async {
        final directory = await getApplicationDocumentsDirectory();
        DateTime dateTime = DateTime.now();
        Timestamp timestamp = Timestamp.fromDate(dateTime);
        final file =
            await File('${directory.path}/share_${timestamp.seconds}.png')
                .create();
        await file.writeAsBytes(image!);
        await Share.shareFiles([file.path]);
      });
    } catch (err) {}
  }

  Widget _body() {
    return Consumer<ConnectivityProvider>(builder: (context, model, child) {
      return model.isOnline
          ? Column(
              children: [
                Flexible(
                    flex: 3,
                    child: Stack(children: [
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
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(15.8700, 100.9925),
                            zoom: 7.0,
                          ),
                          polylines: Set<Polyline>.of(polylines.values),
                          onMapCreated: (GoogleMapController controller) async {
                            _controller = controller;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                child: Image.asset(Assets.eventaLogoDesktop,
                                    height: 100, width: 100),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    // ignore: prefer_const_literals_to_create_immutables
                                    children: [
                                      Text(
                                        'ระยะทาง',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      Text(
                                        'ระยะเวลา',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _locations.isNotEmpty && !widget.isSend
                                            ? "${_runex[0].distanceKm!.toStringAsFixed(2)}(km)"
                                            : widget.isSend
                                                ? "${widget.runexFirestore['distance_total_km'].toStringAsFixed(2)}(km)"
                                                : "0.00(km)",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
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
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _runex.isNotEmpty && !widget.isSend
                                        ? DateTimeUtils.getFullDateAndFullTime(
                                            DateTime.parse(_runex[0].startTime))
                                        : widget.isSend
                                            ? DateTimeUtils
                                                .getFullDateAndFullTime(
                                                    DateTime.parse(widget
                                                        .runexFirestore[
                                                            'start_time']
                                                        .toString()))
                                            : '00:00:00',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              )
                            ]),
                      ),
                    ])),
                Flexible(
                    flex: 2,
                    child: Container(
                      color: Colors.grey[800],
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Column(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            _RunDetail(
                              title: 'ระยะทาง(km)',
                              subTitle: _locations.isNotEmpty && !widget.isSend
                                  ? _runex[0].distanceKm!.toStringAsFixed(2)
                                  : widget.isSend
                                      ? widget
                                          .runexFirestore['distance_total_km']
                                          .toStringAsFixed(2)
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
                              padding: const EdgeInsets.only(top: 3, bottom: 3),
                              child: Divider(
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0, bottom: 6),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!widget.isSend) {
                                    CustomDialog.customDialog2Actions(
                                        context,
                                        "ยืนยันการส่งผล",
                                        "คุณยืนยันที่จะส่งผลการวิ่ง?",
                                        "ยืนยัน",
                                        Colors.white,
                                        Colors.amber,
                                        Colors.transparent,
                                        () {
                                          Navigator.pop(context);
                                          _onProgress();
                                        },
                                        "ยกเลิก",
                                        Colors.grey,
                                        Colors.white,
                                        Colors.grey,
                                        () {
                                          Navigator.pop(context);
                                        });
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
            IconButton(
                onPressed: _sharePopUp, icon: Icon(Icons.file_upload_outlined))
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
