import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pop_lights_app/screens/user_account_tabviews/my_pop_lights.dart';

import '../../utilities/size_config.dart';
import '../Msg_Navigator.dart';
import '../user_account.dart';


class RemoveSuccessfully extends StatefulWidget {

  static String routeName = "screens/user_account_tabviews/rename_successful.dart";
  //
  // List<ScanResult> BluetoothDevicesList=[];
  const RemoveSuccessfully({Key? key}) : super(key: key);


  @override
  State<RemoveSuccessfully> createState() => _RemoveSuccessfullyState();
}

class _RemoveSuccessfullyState extends State<RemoveSuccessfully> {
  List<ScanResult> BluetoothDevicesList=[];
  List<BluetoothCharacteristic> ch1=[];
  List<String> tabTitlesList = ["Group 1", "Group 2", "Group 3"];
  @override
  void initState() {

    super.initState();

    Timer(const Duration(seconds: 2), () {
      for (int i = 0; i < tabTitlesList.length; i++) {
        print("in remove s......");
        if (i == tabTitlesList.length - 1) {
          Navigator.pushReplacementNamed(context, UserAccount.routeName,
              arguments:  {"popid":0,"disclist":BluetoothDevicesList,'ch':ch1});
        }

      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final Args = (ModalRoute
        .of(context)!
        .settings
        .arguments ?? <String, List<dynamic>>{}) as Map;
    BluetoothDevicesList=Args['disclist'];
    ch1=Args["ch"];   print("im inside remove s widigt");
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.2), // Shadow color
              blurRadius: 10.0, // Spread of the shadow
              offset:
              Offset(0, 4), // Offset of the shadow
            ),
          ]
      ),
      child: Container(

        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(





          image: DecorationImage(image: AssetImage("assets/remove_grp_success.png"), fit: BoxFit.fill),

        ),
      ),
    );

  }

}
