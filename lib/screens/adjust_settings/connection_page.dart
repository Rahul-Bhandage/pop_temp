
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pop_lights_app/screens/adjust_settings/adjust_settings_home.dart';
import 'package:pop_lights_app/utilities/app_colors.dart';
import '../../main.dart';
import '../../modals/group_model.dart';
import '../../modals/pop_lights_model.dart';
import '../../utilities/app_utils.dart';
import '../../utilities/database_helper.dart';
import '../../utilities/size_config.dart';
import '../user_account.dart';
import 'disconnection_page.dart';



class ConnectDevices extends StatefulWidget {

  static String routeName = "screens/adjust_settings/connection_page";

  const ConnectDevices({Key? key}) : super(key: key);

  @override
  State<ConnectDevices> createState() => _ConnectDevices();
}
class BluetoothCh {
  final String characteristic;

  BluetoothCh(this.characteristic);

// Add any additional properties or methods as needed
}

class _ConnectDevices extends State<ConnectDevices> {
  double t=0;
  bool chgen=false;
  double brightnessLevel = 0.0;
  int warmthLever = 0;
  int timerState = 0;
  int selectedIndex = 0;
  bool isCustomTimer = false;
  String selectedValue = "";
  int dropDownIndex = 0;
  int groupPopLights = 0;
  bool isToggled = false;
  bool isTog = false;
  int i = 0;
  int con_time=1;
  int discoveredCount=0;
  bool flagDiscoverServices = false;


  BluetoothCharacteristic? ch,chr;
  List<BluetoothCharacteristic> ch1=[],ch2=[];
  List<Map<String, dynamic>> ch_group=[];
  bool _showOverlay = false;
  List<GroupModel> groupsList = [];
  List<PopLightModel> popLightsList = [];
  List<ScanResult> discoveredBluetoothDevicesList = [];
  List<ScanResult> foundPopLightsList = [];
  List<BluetoothCh> bluetoothCharacteristics=[];


  final Map<DeviceIdentifier, ValueNotifier<bool>> isConnectingOrDisconnecting = {};
  late StreamSubscription<FGBGType> subscription;

  Timer? _timer,_counter;
  int sec_counter=0;
  final DateTime now = DateTime.now();

  @override
  void initState() {

    super.initState();
    sec_counter=0;

    // _counter=Timer.periodic(Duration(seconds: 1), (timer) {
    //   setState(() {
    //     sec_counter++;
    //   });

    // });
  }
  @override
  void dispose() {
    // _counter?.cancel();
    super.dispose();
  }

//
  @override
  Widget build(BuildContext context) {
    final Args =
    (ModalRoute.of(context)!.settings.arguments ?? <String, List<ScanResult>>{}) as Map;
    discoveredBluetoothDevicesList = Args['disclist'];
    ch1 =Args['ch'];
    timer_function();
    SizeConfig().init(context);
    //   return  FutureBuilder<List<Map<String, dynamic>>>(
    //       future: DatabaseHelper.getch(),
    //   builder: (context, snapshot) {
    //   switch (snapshot.connectionState) {
    //     case ConnectionState.none:
    //       return Container();
    //
    //     case ConnectionState.waiting:
    //       return Container();
    //
    //     case ConnectionState.active:
    //       return Container();
    //
    //     case ConnectionState.done:
    //       ch_group=snapshot.data!;
    //       List<Map<String, dynamic>> data = ch_group; // Your list of data
    //
    // // Your list of data
    //
    //   List<BluetoothCh> bluetoothCharacteristics = data.map((item) {
    //   return BluetoothCh(item['characteristic']);
    //   }).toList();
    //   print("print ch2 $bluetoothCharacteristics");
    // for(BluetoothCh abc in bluetoothCharacteristics)
    //   {
    //     ch2[].
    //     ch2.add(abc.characteristic as BluetoothCharacteristic?);
    //     print("ch we got ${abc.characteristic}");
    //   }

    return WillPopScope(
      onWillPop: () async {

        Navigator.pushReplacementNamed(context, DisconnectDevices.routeName,
            arguments: {'ch': ch1, "disclist": foundPopLightsList});
        return true;
      },
      child:
      Stack(
        children: [
          Container(

            width: double.infinity, // Fills the width of the parent
            height: double.infinity,
            child: SvgPicture.asset("assets/connecting.svg",fit: BoxFit.fill,),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.06,
              ),

              // Text(
              //   "timer:${sec_counter}",
              //   style: TextStyle(fontSize: 20, color: Colors.red),
              // ),

              Container(

                  alignment: Alignment(0.0, 0.5),
                  child: CircularProgressIndicator(

                    color: primaryColor,


                  )
              ),

            ],
          ),
        ],
      ),


    );
    // }});






  }


  connection(ScanResult bluetoothDevice) async{
    print("Conection:--------------------------------------------------");

      if (bluetoothDevice.device.localName == 'POP_Light') {
        print("connection with pop in comparision ");
        print("device iam connecting with $bluetoothDevice");
        isConnectingOrDisconnecting[
        bluetoothDevice.device.remoteId] ??= ValueNotifier(true);
        isConnectingOrDisconnecting[bluetoothDevice.device.remoteId]!
            .value = true;
        await bluetoothDevice.device
            .connect(timeout:Duration(seconds: 1))
            .catchError((e) {
          final snackBar =
          snackBarFail(prettyException("Connect Error:", e));
          snackBarKeyC.currentState?.removeCurrentSnackBar();
          snackBarKeyC.currentState?.showSnackBar(snackBar);
        }).then((v) {
          isConnectingOrDisconnecting[bluetoothDevice
              .device.remoteId] ??= ValueNotifier(false);
          isConnectingOrDisconnecting[
          bluetoothDevice.device.remoteId]!
              .value = false;
        });
       await callDiscoverServices(bluetoothDevice);

    }
  }


   callDiscoverServices(ScanResult r) async {
    print(
        "in callDiscoverServices-----------------------------------------------");

    try {
      await r.device.discoverServices();

    } catch (e) {
      print(e.toString());
    }
  }

  startScanner() async
  { bool present=false;
  try{
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if(r.device.localName=="POP_Light")

          for (int index=0;index<discoveredBluetoothDevicesList.length;index++){
            if(discoveredBluetoothDevicesList[index]?.device.remoteId==r?.device.remoteId || r==null) {
              present == true;
            }}
        if(present==false)
        {
          discoveredBluetoothDevicesList.add(r);
        }
        print('${r.device.localName} found! rssi: ${r.rssi}');
      }
    });
// Start scanning
    FlutterBluePlus.startScan(timeout: Duration(milliseconds: 2));
// Stop scanning
    await Future.delayed(Duration(milliseconds: 500));

    // Stop scanning
    await FlutterBluePlus.stopScan();
    con_time=discoveredBluetoothDevicesList.length+con_time;
    await timer_function();
    if(FlutterBluePlus.isScanning==false)
    {
      print("Stoped scanning");
    }
  }
  catch (e) {
    final snackBar = snackBarFail(prettyException("Start Scan Error:", e));
    snackBarKeyB.currentState?.removeCurrentSnackBar();
    snackBarKeyB.currentState?.showSnackBar(snackBar);
  }
  }
  timer_function() async
  {
    for(ScanResult BluetoothDevice in discoveredBluetoothDevicesList) {
      print("found list ${BluetoothDevice.device.remoteId}");
      await connection(BluetoothDevice);
    }
    if(ch1.isNotEmpty)
      {
        Navigator.pushReplacementNamed(context, AdjustSettingsHome.routeName,
            arguments: {'ch': ch1, "disclist": discoveredBluetoothDevicesList});
      }
    else
      {
        Navigator.pushReplacementNamed(context, DisconnectDevices.routeName,
            arguments: {'ch': ch1, "disclist": discoveredBluetoothDevicesList});
      }

  }


}
