import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pop_lights_app/screens/adjust_settings/adjust_settings_home.dart';
import 'package:pop_lights_app/screens/home_screen.dart';
import 'package:pop_lights_app/screens/sign_in_sign_up/splash_screen2.dart';
import 'package:pop_lights_app/utilities/database_helper.dart';
import '../../main.dart';
import '../../modals/group_model.dart';
import '../../modals/pop_lights_model.dart';
import '../../utilities/app_utils.dart';
import '../../utilities/size_config.dart';
import '../user_account.dart';



class scanScreen extends StatefulWidget {

  static String routeName = "screens/splash_screen";

  const scanScreen({Key? key}) : super(key: key);

  @override
  State<scanScreen> createState() => _scanScreen();
}

class _scanScreen extends State<scanScreen> {
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
  int discoveredCount=0;
  bool flagDiscoverServices = false;

  BluetoothCharacteristic? ch,chr;
  List<BluetoothCharacteristic?> ch1=[];
  bool _showOverlay = true;
  List<GroupModel> groupsList = [];
  List<PopLightModel> popLightsList = [];
  List<ScanResult> discoveredBluetoothDevicesList = [];
  List<ScanResult> foundPopLightsList = [];

  final Map<DeviceIdentifier, ValueNotifier<bool>> isConnectingOrDisconnecting = {};
  late StreamSubscription<FGBGType> subscription;



  @override
  void initState() {

    super.initState();



    Timer(const Duration(seconds: 1), () {
      print('object');

      for (int i = 0; i < 2; i++) {

        if (i == 1) {

          Timer(const Duration(seconds: 1), () {

            for (int i = 0; i < 2; i++) {

              if (i == 2 - 1) {
                connection();
                // Navigator.pushReplacementNamed(context, SplashScreen2.routeName);
              }

            }
          });

          // Timer(const Duration(seconds: 2), () {
          //
          //   for (int i = 0; i < 2; i++) {
          //
          //     if (i == 2 - 1) {
          //       callDiscoverServices();
          //       // Navigator.pushReplacementNamed(context, SplashScreen2.routeName);
          //     }
          //
          //   }
          // });

          Timer(const Duration(seconds: 3), () {

            for (int i = 0; i <2; i++) {

              if (i == 2 - 1) {
                stream();
                // Navigator.pushReplacementNamed(context, SplashScreen2.routeName);
              }

            }
          });

          // Navigator.pushReplacementNamed(context, SplashScreen2.routeName);
        }

      }
      // if(chgen){

      // }

    });

    Timer(const Duration(seconds: 5), () {

      print("---------------------------------------------------------------------------------------");

      print("---------------------------------------------------------------------------------------");

      print("---------------------------------------------------------------------------------------");
      if(ch1!=[]) {

        print("ch list we are sending $ch1");
        Navigator.pushReplacementNamed(context, AdjustSettingsHome.routeName,
            arguments: {'ch': ch1, "disclist": foundPopLightsList});



      } else
        Navigator.pushReplacementNamed(context, UserAccount.routeName,arguments:  {"popid":0,"disclist":discoveredBluetoothDevicesList});

    });

  }
  @override
  void dispose() {
    ch1=[];
    super.dispose();
  }
//
  @override
  Widget build(BuildContext context) {
    discoveredBluetoothDevicesList = ModalRoute.of(context)!.settings.arguments as List<ScanResult>;
    SizeConfig().init(context);

    return

      Container(


        decoration:  BoxDecoration(

          image: DecorationImage(image: AssetImage("assets/scan_bg.jpg"),
            fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),




        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "",
              style: TextStyle(fontSize: 20,),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.3,
            ),
            Container(

                alignment: Alignment(0.0,-0.5),
                child:CircularProgressIndicator(

                  color: Colors.red,


                )
            ),
          ],
        ),);






  }


  int cou=-1;
  stream() async {
    print("In Stream ---------------------------------------------------------------");
    for(ScanResult r in foundPopLightsList){
      List<BluetoothService> services = await r.device.discoverServices();
      // print("Services in stream $services");
      services.forEach((service) {
        BluetoothCharacteristic? chh,chhh;
        // print("services we got .......${service}");
        if (service.serviceUuid.toString().toUpperCase().contains("FFB0") == true) {
          for (BluetoothCharacteristic bc in service.characteristics) {
            if (bc.characteristicUuid.toString().toUpperCase().contains("FFB1") == true) {
              chh=bc;
              // print("characterstic are $bc");
            }
          }
        }
        bool present=false;
        for (int index=0;index<ch1.length;index++)
        if(ch1[index]?.remoteId==chh?.remoteId && chh==null) {
          present == true;
          chh=chhh;
        }
        if(!present){
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
    for (ScanResult bluetoothDevice in foundPopLightsList) {
      if (bluetoothDevice.device.localName == 'POP_Light') {
        // print("connection with pop in comparision ");


        if(!foundPopLightsList.contains(bluetoothDevice))
          foundPopLightsList.add(bluetoothDevice);
          // print("device iam connecting with $bluetoothDevice");

        isConnectingOrDisconnecting[
        bluetoothDevice.device.remoteId] ??= ValueNotifier(true);
        isConnectingOrDisconnecting[bluetoothDevice.device.remoteId]!
            .value = true;
        await bluetoothDevice.device
            .connect(timeout: Duration(seconds: 35))
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
      for(int x=0;x<foundPopLightsList.length;x++){
        await foundPopLightsList[x].device.discoverServices();
        // print("Discovered Device $x");
      }
    }catch(e){
      print(e.toString());
      Fluttertoast.showToast(
          msg: "",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}