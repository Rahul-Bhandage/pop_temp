import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pop_lights_app/screens/user_account_tabviews/my_pop_lights.dart';

import '../utilities/size_config.dart';

class DeletedSuccessfully extends StatefulWidget {

  static String routeName = "screens/deleted_successfully";

  List<ScanResult> BluetoothDevicesList=[];
  List<BluetoothCharacteristic> ch1=[];
  DeletedSuccessfully({Key? key, required this.BluetoothDevicesList,required this.ch1}) : super(key: key);


  @override
  State<DeletedSuccessfully> createState() => _DeletedSuccessfullyState();
}

class _DeletedSuccessfullyState extends State<DeletedSuccessfully> {

  @override
  void initState() {

    super.initState();

    Timer(const Duration(seconds: 1), () {


              MyPopLights( BluetoothDevicesList: widget.BluetoothDevicesList ,ch1:widget.ch1);
          });

  }



  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);
    return Container(
      
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        
        image: DecorationImage(image: AssetImage("assets/group_deleted_successfully.jpg"), fit: BoxFit.fill),

      ),
    );

  }

}
