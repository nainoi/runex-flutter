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
  late bool _isLoading = false;
  late List<Runex> runexDb = [];
  late List runexFirestore = [];
  late List runexMothAndYear = [];

  Future<void> _getRunexAndLocation() async {
    prefs = await SharedPreferences.getInstance();
    final providerId = "ABCD1234"; //prefs.getString("providerID");
    final _runexDb = await RunexDatabase.instance.readByProviderId(providerId);
    final mothAndYear =
        await RunexDatabase.instance.readByMonthAndYear(providerId);

    RunexFirestoreDatabase runexFirestoreDatabase = RunexFirestoreDatabase();
    final _runexFirestore =
        await runexFirestoreDatabase.readByProviderId(providerId);
    setState(() {
      runexFirestore = _runexFirestore.data;
      runexDb = _runexDb;
      _selectedAlreadySend = _runexFirestore.success ? true : false;
      runexMothAndYear = mothAndYear;
    });
  }

  @override
  void initState() {
    super.initState();
    _getRunexAndLocation();
  }

  @override
  Widget build(BuildContext context) {
    final heightMax = MediaQuery.of(context).size.height;
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
            child: Container(
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
          ),
          // Container(
          //   height: heightMax,
          //   child: ListView.separated(
          //     itemCount: runexMothAndYear.length,
          //     separatorBuilder: (BuildContext context, int index) {
          //       return Divider();
          //     },
          //     itemBuilder: (BuildContext context, int index) {
          //       return Padding(
          //         padding: const EdgeInsets.all(16),
          //         child: GestureDetector(
          //           onTap: () {
          //             print('Clicked');
          //           },
          //           child: Row(
          //             children: [
          //               Container(
          //                 width: 65,
          //                 height: 65,
          //                 decoration: BoxDecoration(
          //                     borderRadius:
          //                         BorderRadius.all(Radius.circular(50.0)),
          //                     color: Colors.grey[600]),
          //                 child: Column(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     Text(
          //                       "10",
          //                       style: TextStyle(
          //                           color: Colors.white,
          //                           fontSize: 18,
          //                           fontWeight: FontWeight.w500),
          //                     ),
          //                     Text("ครั้ง",
          //                         style: TextStyle(
          //                           color: Colors.grey[400],
          //                           fontSize: 16,
          //                         ))
          //                   ],
          //                 ),
          //               ),
          //               Padding(
          //                 padding: const EdgeInsets.only(left: 16),
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     Text(runexMothAndYear[index]['month_and_year'],
          //                         style: TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 18,
          //                             fontWeight: FontWeight.w500)),
          //                     SizedBox(height: 5),
          //                     Row(
          //                       // ignore: prefer_const_literals_to_create_immutables
          //                       children: [
          //                         IconAndText(
          //                             title: "0.00",
          //                             icon: Icons.run_circle_outlined),
          //                         SizedBox(width: 16),
          //                         IconAndText(
          //                             title: "00:00:00",
          //                             icon: Icons.access_time),
          //                         SizedBox(width: 16),
          //                         IconAndText(
          //                             title: "0.00",
          //                             icon: Icons.fireplace_outlined),
          //                       ],
          //                     )
          //                   ],
          //                 ),
          //               )
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          _selectedAlreadySend && runexFirestore.isNotEmpty
              ? Container(
                  height: heightMax,
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: GestureDetector(
                            onTap: () {
                              print('Clicked');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => WorkOutResult(
                                            runexId: 0,
                                            isSend: true,
                                            runexFirestore:
                                                runexFirestore[index],
                                          )));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.run_circle_outlined,
                                  size: 60,
                                  color: Colors.amber[400],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          DateTimeUtils.getFullDate(
                                              DateTime.parse(
                                                  runexFirestore[index]
                                                      ['start_time'])),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        // ignore: prefer_const_literals_to_create_immutables
                                        children: [
                                          Text(
                                            DateTimeUtils.getFullTime(
                                                DateTime.parse(
                                                    runexFirestore[index]
                                                        ['start_time'])),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                          ),
                                          SizedBox(width: 50),
                                          Text(
                                              '${runexFirestore[index]['distance_total_km'].toString()} km',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14)),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 50, right: 16),
                          child: Divider(
                            color: Colors.grey,
                          ),
                        );
                      },
                      itemCount: runexFirestore.length),
                )
              : Container(
                  height: heightMax,
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: GestureDetector(
                            onTap: () {
                              print('Clicked');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => WorkOutResult(
                                            runexId: runexDb[index].id!,
                                            isSend: false,
                                          )));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.run_circle_outlined,
                                  size: 60,
                                  color: Colors.amber[400],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          DateTimeUtils.getFullDate(
                                              DateTime.parse(
                                                  runexDb[index].startTime)),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            DateTimeUtils.getFullTime(
                                                DateTime.parse(
                                                    runexDb[index].startTime)),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                          ),
                                          SizedBox(width: 50),
                                          Text(
                                              '${runexDb[index].distanceKm.toString()} km',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14)),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 50, right: 16),
                          child: Divider(color: Colors.grey),
                        );
                      },
                      itemCount: runexDb.length),
                ),
        ],
      )),
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
    return Container(
      child: Row(
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
      ),
    );
  }
}
