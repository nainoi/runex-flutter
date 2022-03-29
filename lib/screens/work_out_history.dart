// ignore_for_file: prefer_const_constructors

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:runex/databases/databases.dart';
import 'package:runex/screens/screens.dart';
import 'package:runex/screens/widgets/widgets.dart';
import 'package:runex/services/firestore_database/firestore_database.dart';
import 'package:runex/utils/datetime_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class WorkOutHistory extends StatefulWidget {
  const WorkOutHistory({Key? key}) : super(key: key);

  @override
  _WorkOutHistoryState createState() => _WorkOutHistoryState();
}

class _WorkOutHistoryState extends State<WorkOutHistory> {
  late SharedPreferences prefs;
  late bool _selectedAlreadySend = true;
  late bool _isLoading = false;
  late List<Runex> runexDb = [];
  late List runexFirestore = [];
  late List<MonthAndYear> runexMothAndYearDb = [];
  late List<MonthAndYear> runexMothAndYearFirestore = [];
  Flushbar pageRefreshedSnackbar = Flushbar(
    message: 'Page Refreshed',
    icon: Icon(Icons.check_circle_outline_rounded,
        size: 28, color: Colors.green[300]),
    duration: Duration(seconds: 2),
    margin: EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
  );

  _alertErrorDialog() {
    return CustomDialog.customDialog1Actions(
        context,
        "เกิดข้อผิดพลาด",
        "กรุณาลองใหม่อีกครั้ง",
        "ตกลง",
        Colors.white,
        Colors.amber,
        Colors.transparent, () {
      Navigator.pop(context);
    });
  }

  Future<void> _getRunexAndLocation() async {
    try {
      prefs = await SharedPreferences.getInstance();
      final providerId = prefs.getString("providerID") ?? '';
      if (providerId != '') {
        setState(() {
          _isLoading = true;
        });
        final _runexDb =
            await RunexDatabase.instance.readByProviderId(providerId);
        final mothAndYearDb =
            await RunexDatabase.instance.readByMonthAndYear(providerId);

        RunexFirestoreDatabase runexFirestoreDatabase =
            RunexFirestoreDatabase();
        final _runexFirestore =
            await runexFirestoreDatabase.readByProviderId(providerId);
        final monthAndYearFirestore =
            await runexFirestoreDatabase.readByMonthAndYear(providerId);
        setState(() {
          runexFirestore = _runexFirestore.data;
          runexDb = _runexDb;
          runexMothAndYearDb = mothAndYearDb;
          runexMothAndYearFirestore = monthAndYearFirestore.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      _alertErrorDialog();
    }
  }

  @override
  void initState() {
    super.initState();
    _getRunexAndLocation();
  }

  _formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  ExpansionPanel _buildExpansionPanelFirestore(MonthAndYear item) {
    return ExpansionPanel(
        isExpanded: item.isExpanded,
        backgroundColor: Colors.transparent,
        canTapOnHeader: true,
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ExpandedHeader(
            runCount: item.runexCount.toString(),
            dateTime: item.monthAndYear,
            distance: item.distanceTotal.toStringAsFixed(2),
            time: _formatTime((item.timeTotal * 3600).round()),
            cal: "0.00",
          );
        },
        body: SizedBox(
          height: item.runexCount > 5 ? 400 : 100 * (item.runexCount * 1.0),
          child: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(Duration(seconds: 2), () {
                _getRunexAndLocation();
                pageRefreshedSnackbar.show(context);
              });
            },
            color: Colors.amber[400],
            child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  if (runexFirestore[index]['month_and_year'] ==
                      item.monthAndYear) {
                    return ExpandedBody(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => WorkOutResult(
                                      runexId: 0,
                                      isSend: true,
                                      runexFirestore: runexFirestore[index],
                                    )));
                      },
                      distance: runexFirestore[index]['distance_total_km']
                          .toStringAsFixed(2),
                      startTime: runexFirestore[index]['start_time'],
                    );
                  }
                  return Container();
                },
                itemCount: runexFirestore.length),
          ),
        ));
  }

  ExpansionPanel _buildExpansionPanelDb(MonthAndYear item) {
    return ExpansionPanel(
        isExpanded: item.isExpanded,
        backgroundColor: Colors.transparent,
        canTapOnHeader: true,
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ExpandedHeader(
            runCount: item.runexCount.toString(),
            dateTime: item.monthAndYear,
            distance: item.distanceTotal.toString(),
            time: _formatTime((item.timeTotal * 3600).round()),
            cal: "0.00",
          );
        },
        body: SizedBox(
          height: item.runexCount > 5 ? 400 : 100 * (item.runexCount * 1.0),
          child: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(Duration(seconds: 2), () {
                _getRunexAndLocation();
                pageRefreshedSnackbar.show(context);
              });
            },
            color: Colors.amber[400],
            child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  if (runexDb[index].monthAndYear == item.monthAndYear) {
                    return ExpandedBody(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => WorkOutResult(
                                      runexId: runexDb[index].id!,
                                      isSend: false,
                                    )));
                      },
                      distance: runexDb[index].distanceKm!.toStringAsFixed(2),
                      startTime: runexDb[index].startTime,
                    );
                  } else {
                    return Container();
                  }
                },
                itemCount: runexDb.length),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text("ประวัติ"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedAlreadySend = true;
                    });
                  },
                  child: Text(
                    'ส่งผลแล้ว',
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(120, 20),
                      primary: _selectedAlreadySend
                          ? Colors.amber[400]
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0)))),
                ),
                SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedAlreadySend = false;
                    });
                  },
                  child: Text(
                    'ยังไม่ส่งผล',
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(120, 20),
                      primary: _selectedAlreadySend
                          ? Colors.grey
                          : Colors.amber[400],
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0)))),
                ),
              ],
            ),
          ),
          if (_selectedAlreadySend)
            if (_isLoading)
              CircularProgressIndicator(
                color: Colors.amber,
                // valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              )
            else
              ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    runexMothAndYearFirestore[index].isExpanded = !isExpanded;
                  });
                },
                children: runexMothAndYearFirestore
                    .map((e) => _buildExpansionPanelFirestore(e))
                    .toList(),
              )
          else if (!_selectedAlreadySend)
            if (_isLoading)
              CircularProgressIndicator(
                color: Colors.amber,
              )
            else
              ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    runexMothAndYearDb[index].isExpanded = !isExpanded;
                  });
                },
                children: runexMothAndYearDb
                    .map((e) => _buildExpansionPanelDb(e))
                    .toList(),
              )
        ],
      )),
    );
  }
}

class ExpandedBody extends StatelessWidget {
  final String startTime;
  final String distance;
  final VoidCallback onTap;

  const ExpandedBody(
      {Key? key,
      required this.startTime,
      required this.distance,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 18, 24, 0),
      child: GestureDetector(
        onTap: onTap,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.run_circle_outlined,
                    size: 45,
                    color: Colors.amber[400],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              DateTimeUtils.getFullDateInNumber(
                                  DateTime.parse(startTime)),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateTimeUtils.getFullTime(
                                    DateTime.parse(startTime)),
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              Text('$distance km',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 9),
                child: Divider(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandedHeader extends StatelessWidget {
  final String runCount;
  final String dateTime;
  final String distance;
  final String time;
  final String cal;
  const ExpandedHeader({
    Key? key,
    required this.runCount,
    required this.dateTime,
    required this.distance,
    required this.time,
    required this.cal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                color: Colors.grey[600]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  runCount,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                Text("ครั้ง",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateTime,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 5),
                Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    IconAndText(
                        title: distance, icon: Icons.run_circle_outlined),
                    SizedBox(width: 10),
                    IconAndText(title: time, icon: Icons.access_time),
                    SizedBox(width: 10),
                    // IconAndText(title: cal, icon: Icons.fireplace_outlined),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class IconAndText extends StatelessWidget {
  final String title;
  final IconData icon;
  const IconAndText({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.amber[400],
        ),
        SizedBox(width: 5),
        Text(title,
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w400))
      ],
    );
  }
}
