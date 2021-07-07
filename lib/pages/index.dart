import 'dart:async';
import 'dart:convert' as convert;

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ring/pages/auth.dart';
import 'package:ring/pages/call.dart';
import 'package:ring/utils/settings.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value
  // final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  // bool _validateError = false;

  int _selectedIndex = 0;

  int nowAtendType = -1;

  String date = "XXXX/XX/XX: ";

  ClientRole? _role = ClientRole.Broadcaster;

  static final googleLogin = GoogleSignIn(scopes: ['email']);

  @override
  void dispose() {
    // dispose input controller
    // _channelController.dispose();
    super.dispose();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getApiData() async {
    final snapshot = await FirebaseFirestore.instance.collection('rooms').get();
    print(snapshot.docs.first.data());
    return snapshot.docs;
  }

  void searchRepositories() async {
    final f = NumberFormat('00');
    final now = DateTime.now();
    final month = f.format(now.month);
    final day = f.format(now.month);

    date = '2021/$month/$day: ';

    final url = Uri.https(
        'atnd.ak4.jp', '/api/cooperation/techfirm/stamps', <String, dynamic>{
      'token': '$akashiToken',
      'start_date': '2021$month${day}000000',
      'end_date': '2021$month${day}235900'
    });

    final response = await http.get(url);

    final jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    var stampLength = jsonResponse['response']['stamps'].length as int;

    if (stampLength > 0) {
      print(jsonResponse['response']['stamps'][stampLength - 1]);
      nowAtendType =
          jsonResponse['response']['stamps'][stampLength - 1]['type'] as int;
    } else {
      nowAtendType = -1;
    }
  }

  void sendAkashiPost(int type) async {
    // POSTする場合
    final url =
        Uri.parse('https://atnd.ak4.jp/api/cooperation/techfirm/stamps');

    final response =
        await http.post(url, body: {'token': '$akashiToken', 'type': '$type'});

    final jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    print(jsonResponse);
    bool isSuccess = jsonResponse['success'] as bool;

    if (isSuccess) {
      setState(() {
        nowAtendType = type;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('AKASHIとの通信に失敗しました。'),
        duration: Duration(seconds: 2),
      ));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ['ログアウト'];
    searchRepositories();
    final _pageList = <Widget>[getRoomsPage(), getAttendancePage()];
    final _pageTitles = ['通話', '勤怠'];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_pageTitles[_selectedIndex]),
        actions: <Widget>[
          PopupMenuButton<String>(
            // initialValue: _selectedValue,
            onSelected: (String s) async {
              if (s == 'ログアウト') {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn(scopes: [
                  'email',
                ]).signOut();
                await Navigator.of(context)
                    .pushReplacement(MaterialPageRoute<AuthPage>(
                        settings: const RouteSettings(name: "/auth"),
                        builder: (context) {
                          return AuthPage();
                        }));
              }
            },
            itemBuilder: (BuildContext context) {
              return items.map((String s) {
                return PopupMenuItem(
                  value: s,
                  child: Text(s),
                );
              }).toList();
            },
          )
        ],
      ),
      body: _pageList[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: '通話',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: '勤怠',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget getRoomsPage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 700,
        child: Column(
          children: <Widget>[
            // Row(
            //   children: <Widget>[
            //     FutureBuilder<
            //             List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            //         future: getApiData(),
            //         builder: (context, snapshot) {
            //           if (!snapshot.hasData) {
            //             return const CircularProgressIndicator();
            //           }
            //           if (snapshot.data == null || snapshot.data!.isEmpty) {
            //             return const Text('No Data');
            //           } else {
            //             print(snapshot.data![0].get('name').toString());
            //             return Expanded(
            //                 child: ListView.builder(
            //               shrinkWrap: true,
            //               physics: NeverScrollableScrollPhysics(),
            //               itemCount: snapshot.data!.length,
            //               itemBuilder: (context, index) {
            //                 return Text(
            //                     snapshot.data![index].get('name').toString());
            //               },
            //             ));
            //           }
            //         }),
            //   ],
            // ),
            Column(
              children: [
                ListTile(
                  title: Text(ClientRole.Broadcaster.toString()),
                  leading: Radio(
                    value: ClientRole.Broadcaster,
                    groupValue: _role,
                    onChanged: (ClientRole? value) {
                      setState(() {
                        _role = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text(ClientRole.Audience.toString()),
                  leading: Radio(
                    value: ClientRole.Audience,
                    groupValue: _role,
                    onChanged: (ClientRole? value) {
                      setState(() {
                        _role = value;
                      });
                    },
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onJoin,
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blueAccent),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      child: const Text('Join'),
                    ),
                  ),
                  // Expanded(
                  //   child: RaisedButton(
                  //     onPressed: onJoin,
                  //     child: Text('Join'),
                  //     color: Colors.blueAccent,
                  //     textColor: Colors.white,
                  //   ),
                  // )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getAttendancePage() {
    print(akshiUser.name);
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            SizedBox(
              height: 75,
              width: 75,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(akshiUser.photoURL),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              akshiUser.name,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$date${getAtendString(nowAtendType)}',
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    onPressAtendButton(11);
                  },
                  child: const Text(
                    '出勤',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    onPressAtendButton(12);
                  },
                  child: const Text(
                    '退勤',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onPressAtendButton(int atendType) {
    if (atendType == 11 && nowAtendType == 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('既に出勤しています。'),
        duration: Duration(seconds: 2),
      ));
    } else if (atendType == 12 && nowAtendType == 12) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('既に退勤しています。'),
        duration: Duration(seconds: 2),
      ));
    } else if (atendType == 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('出勤しました。'),
        duration: Duration(seconds: 2),
      ));
      sendAkashiPost(11);
    } else if (atendType == 12) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('退勤しました。'),
        duration: Duration(seconds: 2),
      ));
      sendAkashiPost(12);
    }
  }

  String getAtendString(int atendType) {
    switch (atendType) {
      case 11:
        return '出勤済み';
      case 12:
        return '退勤済み';
      default:
        return '未出勤';
    }
  }

  // タップ時の処理
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> onJoin() async {
    // update input validation
    // setState(() {
    //   _channelController.text.isEmpty
    //       ? _validateError = true
    //       : _validateError = false;
    // });
    // if (_channelController.text.isNotEmpty) {
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute<CallPage>(
        builder: (context) => CallPage(
          channelName: 'test',
          role: _role,
        ),
      ),
    );
    // }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}

class DateFormat {}
