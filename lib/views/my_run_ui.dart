import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_run_record_app/models/run.dart';
import 'package:flutter_run_record_app/views/insert_run_ui.dart';
import 'package:flutter_run_record_app/views/up_del_run_ui.dart';

class MyRunUI extends StatefulWidget {
  const MyRunUI({super.key});

  @override
  State<MyRunUI> createState() => _MyRunUIState();
}

class _MyRunUIState extends State<MyRunUI> {
// สร้างตัวแปรที่เก็บข้อมูลการวิ่งที่ดึงมาจากฐานข้อมูลผ่าน API
  late Future<List<Run>> myRuns;

// สร้างเมธอดดึงข้อมูลการวิ่งจากฐานข้อมูลผ่าน API
  Future<List<Run>> fetchMyRuns() async {
    // โค้ดดึงข้อมูลจาก API
    try {
      final response = await Dio().get('http://10.1.1.83:3030/api/run');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['result'] as List<dynamic>;
        return data.map((json) => Run.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load runs');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load runs: ${e.message}');
    }
  }

  @override
  void initState() {
    // ตอนหน้าจอถูกเปิด ให้ไปดึงข้อมูล แล้วเก็บในตัวแปร myRuns
    myRuns = fetchMyRuns();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0E2148),
        title: const Text(
          'การวิ่งของฉัน',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Image.asset(
              'assets/images/running.png',
              width: 200,
            ),
            SizedBox(height: 20),
            FutureBuilder<List<Run>>(
              future: myRuns,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  // โค้ดส่วนนของการสร้าง  UI เมื่อโหลดข้อมูลสำเร็จ
                  List<Run> runs = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: runs.length,
                      itemBuilder: (context, index) {
                        Run run = runs[index];
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpDelRunUI(
                                  runId: run.runId,
                                  runLocation: run.runLocation,
                                  runDistance: run.runDistance,
                                  runTime: run.runTime,
                                ),
                              ),
                            ).then((value) {
                              setState(() {
                                // ดึงข้อมูลมาใหม่
                                myRuns = fetchMyRuns();
                              });
                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: Color(0xff7965C1),
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          title: Text(
                            'สถานที่วิ่ง: ' + run.runLocation!,
                          ),
                          subtitle: Text(
                            'ระยะทางวิ่ง: ' +
                                run.runDistance!.toString() +
                                ' km',
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: Color(0xff7965C1)),
                          tileColor: index % 2 == 0
                              ? Colors.white
                              : Color.fromARGB(255, 250, 240, 211),
                        );
                      },
                    ),
                  );
                } else {
                  return const Text('No runs found.');
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsertRunUI(),
            ),
          ).then((value) {
            // ดึงข้อมูลมาใหม่
            setState(() {
              myRuns = fetchMyRuns();
            });
          });
        },
        label: Text(
          'เพิ่มการวิ่ง',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        icon: Icon(Icons.add),
        backgroundColor: Color(0xff0E2148),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
