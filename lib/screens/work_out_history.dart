// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:runex/databases/databases.dart';
import 'package:runex/screens/screens.dart';
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
  late int _selectHeaderIndex = 0;
  late bool _isLoading = false;
  late List<Runex> runexDb = [];
  late List runexFirestore = [];
  late List<MonthAndYear> runexMothAndYearDb = [];
  late List<MonthAndYear> runexMothAndYearFirestore = [];

  Future<void> _getRunexAndLocation() async {
    prefs = await SharedPreferences.getInstance();
    final providerId = "ABCD1234"; //prefs.getString("providerID");
    final _runexDb = await RunexDatabase.instance.readByProviderId(providerId);
    final mothAndYearDb =
        await RunexDatabase.instance.readByMonthAndYear(providerId);

    RunexFirestoreDatabase runexFirestoreDatabase = RunexFirestoreDatabase();
    final _runexFirestore =
        await runexFirestoreDatabase.readByProviderId(providerId);
    final monthAndYearFirestore =
        await runexFirestoreDatabase.readByMonthAndYear(providerId);
    setState(() {
      runexFirestore = _runexFirestore.data;
      runexDb = _runexDb;
      _selectedAlreadySend = _runexFirestore.success ? true : false;
      runexMothAndYearDb = mothAndYearDb;
      runexMothAndYearFirestore = monthAndYearFirestore.data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getRunexAndLocation();
  }

  ExpansionPanel _buildExpansionPanelFirestore(
      MonthAndYear item, int selectHeaderIndex) {
    late int runexCount = 0;
    var runexCountMap = Map();
    var distanceMap = {};
    for (var i = 0; i < runexFirestore.length; i++) {
      runexCount += 1;
      if (!runexCountMap.keys.contains(item.monthAndYear)) {
        runexCountMap[item.monthAndYear] = 1;
      } else {
        runexCountMap[item.monthAndYear] += 1;
      }
    }
    return ExpansionPanel(
        isExpanded: item.isExpanded,
        backgroundColor: Colors.transparent,
        canTapOnHeader: true,
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ExpandedHeader(
            runCount: runexCount.toString(),
            dateTime: item.monthAndYear,
            distance: "0.00",
            time: "00:00:00",
            cal: "0.00",
          );
        },
        body: SizedBox(
          height: 200,
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
                    distance:
                        runexFirestore[index]['distance_total_km'].toString(),
                    startTime: runexFirestore[index]['start_time'],
                  );
                }
                return Container();
              },
              itemCount: runexFirestore.length),
        ));
  }

  ExpansionPanel _buildExpansionPanelDb(
      MonthAndYear item, int selectHeaderIndex) {
    late int runexCount = 0;
    var runexCountMap = {};
    var distanceMap = {};
    for (var i = 0; i < runexDb.length; i++) {
      runexCount += 1;
      if (!runexCountMap.keys.contains(item.monthAndYear)) {
        runexCountMap[item.monthAndYear] = 1;
      } else {
        runexCountMap[item.monthAndYear] += 1;
      }
    }
    return ExpansionPanel(
        isExpanded: item.isExpanded,
        backgroundColor: Colors.transparent,
        canTapOnHeader: true,
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ExpandedHeader(
            runCount: runexCount.toString(),
            dateTime: item.monthAndYear,
            distance: "0.00",
            time: "00:00:00",
            cal: "0.00",
          );
        },
        body: SizedBox(
          height: 200,
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
                    distance: runexDb[index].distanceKm.toString(),
                    startTime: runexDb[index].startTime,
                  );
                } else {
                  return Container();
                }
              },
              itemCount: runexDb.length),
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
          _selectedAlreadySend
              ? ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      runexMothAndYearFirestore[index].isExpanded = !isExpanded;
                      _selectHeaderIndex = index;
                    });
                  },
                  children: runexMothAndYearFirestore
                      .map((e) =>
                          _buildExpansionPanelFirestore(e, _selectHeaderIndex))
                      .toList(),
                )
              : ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      runexMothAndYearDb[index].isExpanded = !isExpanded;
                      _selectHeaderIndex = index;
                    });
                  },
                  children: runexMothAndYearDb
                      .map((e) => _buildExpansionPanelDb(e, _selectHeaderIndex))
                      .toList(),
                ),
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
      padding: const EdgeInsets.fromLTRB(40, 16, 16, 16),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              Icons.run_circle_outlined,
              size: 45,
              color: Colors.amber[400],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      DateTimeUtils.getFullDateInNumber(
                          DateTime.parse(startTime)),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateTimeUtils.getFullTime(DateTime.parse(startTime)),
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      SizedBox(width: 50),
                      Text('$distance km',
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  )
                ],
              ),
            )
          ],
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
                      fontWeight: FontWeight.w500),
                ),
                Text("ครั้ง",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
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
