import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
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
    final url =
        Uri.parse('https://atnd.ak4.jp/api/cooperation/techfirm/stamps');

    final response = await http.post(url, body: {
      'token': '$akashiToken',
      'start_date': '20210501000000',
      'end_date': '20210531000000'
    });

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // final response = await http.get(
    //     'https://api.github.com/search/repositories?q=' +
    //         searchWord +
    //         '&sort=stars&order=desc');
    //
    //
    // if (response.statusCode == 200) {
    //   List<GithubRepository> list = [];
    //   Map<String, dynamic> decoded = json.decode(response.body);
    //   for (var item in decoded['items']) {
    //     list.add(GithubRepository.fromJson(item));
    //   }
    //   // return list;
    // } else {
    //   throw Exception('Fail to search repository');
    // }
  }

  @override
  Widget build(BuildContext context) {
    final items = ['ログアウト'];
    searchRepositories();
    final _pageList = <Widget>[getRoomsPage(), const Center()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム選択'),
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
