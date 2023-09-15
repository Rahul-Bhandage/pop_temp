
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pop_lights_app/screens/adjust_settings/adjust_settings_home.dart';
import '../../main.dart';
import '../../modals/group_model.dart';
import '../../modals/pop_lights_model.dart';
import '../../utilities/app_utils.dart';
import '../../utilities/database_helper.dart';
import '../../utilities/size_config.dart';
import '../user_account.dart';



class ScanDevices extends StatefulWidget {

  static String routeName = "screens/adjust_settings/scan_for_devices";

  const ScanDevices({Key? key}) : super(key: key);

  @override
  State<ScanDevices> createState() => _ScanDevices();
}
class BluetoothCh {
  final String characteristic;

  BluetoothCh(this.characteristic);

// Add any additional properties or methods as needed
}

class _ScanDevices extends State<ScanDevices> {
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
  List<BluetoothCharacteristic?> ch1=[],ch2=[];
  List<Map<String, dynamic>> ch_group=[];
  bool _showOverlay = false;
  List<GroupModel> groupsList = [];
  List<PopLightModel> popLightsList = [];
  List<ScanResult> discoveredBluetoothDevicesList = [];
  List<ScanResult> foundPopLightsList = [];
  List<BluetoothCh> bluetoothCharacteristics=[];


  final Map<DeviceIdentifier, ValueNotifier<bool>> isConnectingOrDisconnecting = {};
  late StreamSubscription<FGBGType> subscription;

  Timer? _timer, _timer1, _timer2, _timer3;

  @override
  void initState() {

    super.initState();
    startScanner();

  }
  @override
  void dispose() {
    ch1=[];
    _timer1?.cancel();
    _timer2?.cancel();
    _timer3?.cancel();
    _timer?.cancel();
    super.dispose();
  }

//
  @override
  Widget build(BuildContext context) {
    discoveredBluetoothDevicesList = ModalRoute.of(context)!.settings.arguments as List<ScanResult>;

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
        await disconnect();
        Navigator.pushReplacementNamed(context, UserAccount.routeName,
            arguments: {"popid": 0, "disclist": foundPopLightsList});
        return true;
      },

      child:

      Container(


        decoration: BoxDecoration(

          image: DecorationImage(image: AssetImage("assets/scan_bg.jpg"),
            fit: BoxFit.fill,
            // colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),


        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "",
              style: TextStyle(fontSize: 20,),
            ),
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.3,
            ),
            Container(

                alignment: Alignment(0.0, -0.5),
                child: CircularProgressIndicator(

                  color: Colors.red,


                )
            ),
          ],
        ),),
    );
    // }});






  }


  int cou=-1;
  stream() async {
    print("In Stream ---------------------------------------------------------------");
    for(ScanResult r in discoveredBluetoothDevicesList){;
    List<BluetoothService> services = await r.device.discoverServices();
    print("Services in stream $services");
    services.forEach((service) {
      BluetoothCharacteristic? chh,chhh;
      print("services we got .......${service}");
      if (service.serviceUuid.toString().toUpperCase().contains("FFB0") == true) {
        for (BluetoothCharacteristic bc in service.characteristics) {
          if (bc.characteristicUuid.toString().toUpperCase().contains("FFB1") == true) {
            chh=bc;
            // DatabaseHelper.insertch(bc);
            print("characterstic are $bc");
          }
        }
      }
      bool present=false;
      for (int index=0;index<ch1.length;index++)
        if(ch1[index]?.remoteId==chh?.remoteId || chh==null) {
          present == true;
          chh=chhh;
        }
      if(ch1==[]&& chh!=null)
        ch1=[chh];
      if(!present){
        if(chh!=null)
          ch1.add(chh);
        chh=chhh;
      }

    });

    }
    if(ch1.length>1){
      chgen=true;
    }


  }

  connection() async{
    print("Conection:--------------------------------------------------");
    // for (ScanResult bluetoothDevice in discoveredBluetoothDevicesList) {
    //   if (!foundPopLightsList.contains(bluetoothDevice))
    //     foundPopLightsList.add(bluetoothDevice);
    // }
    for (ScanResult bluetoothDevice in discoveredBluetoothDevicesList) {
      if (bluetoothDevice.device.localName == 'POP_Light') {
        print("connection with pop in comparision ");
        print("device iam connecting with $bluetoothDevice");


        isConnectingOrDisconnecting[
        bluetoothDevice.device.remoteId] ??= ValueNotifier(true);
        isConnectingOrDisconnecting[bluetoothDevice.device.remoteId]!
            .value = true;
        await bluetoothDevice.device
            .connect()
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
        // print("device iam connected with $bluetoothDevice");



      }
    }
  }


  void callDiscoverServices() async {
    print("in callDiscoverServices-----------------------------------------------");

    try {
      for(int x=0;x<discoveredBluetoothDevicesList.length;x++){
        await discoveredBluetoothDevicesList[x].device.discoverServices();
        print("Discovered Device $x");
      }
    }catch(e){
      print(e.toString());
      //   Fluttertoast.showToast(
      //       msg: "",
      //       toastLength: Toast.LENGTH_SHORT,
      //       gravity: ToastGravity.BOTTOM,
      //       timeInSecForIosWeb: 1,
      //       backgroundColor: Colors.red,
      //       textColor: Colors.white,
      //       fontSize: 16.0);
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
  timer_function()
  {
    print("found list $discoveredBluetoothDevicesList");
    _timer1= Timer( Duration(seconds: 0), () {
      connection();// Navigator.pushReplacementNamed(context, SplashScreen2.routeName);
    });
    // _timer2=Timer( Duration(seconds: con_time*3), () {
    //             callDiscoverServices();
    //       });
    _timer3= Timer(Duration(seconds: con_time*2), () {
      stream();
    });
    _timer=Timer( Duration(seconds:con_time*5), () {

      print("---------------------------------------------------------------------------------------");

      print("---------------------------------------------------------------------------------------");

      print("---------------------------------------------------------------------------------------");
      if(ch1!=[]) {

        print("ch list we are sending $ch1");
        Navigator.pushReplacementNamed(context, AdjustSettingsHome.routeName,
            arguments: {'ch': ch1, "disclist": discoveredBluetoothDevicesList});



      } else
        Navigator.pushReplacementNamed(context, UserAccount.routeName,arguments:  {"popid":0,"disclist":discoveredBluetoothDevicesList});

    });

  }
  disconnect() async{
    for (ScanResult bluetoothDevice in foundPopLightsList) {
      isConnectingOrDisconnecting[bluetoothDevice.device.remoteId] ??= ValueNotifier(true);
      isConnectingOrDisconnecting[bluetoothDevice.device.remoteId]!.value = true;
      await bluetoothDevice.device.disconnect().catchError((e) {
        final snackBar = snackBarFail(prettyException("Connect Error:", e));
        snackBarKeyC.currentState?.removeCurrentSnackBar();
        snackBarKeyC.currentState?.showSnackBar(snackBar);
      }).then((v) {
        isConnectingOrDisconnecting[bluetoothDevice.device.remoteId] ??= ValueNotifier(false);
        isConnectingOrDisconnecting[bluetoothDevice.device.remoteId]!.value = false;
      });
    }
  }

}