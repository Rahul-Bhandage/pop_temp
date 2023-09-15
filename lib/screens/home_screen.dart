import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pop_lights_app/modals/pop_lights_model.dart';
import 'package:pop_lights_app/screens/adjust_settings/disconnection_page.dart';
import 'package:pop_lights_app/screens/adjust_settings/scan_file.dart';
import 'package:pop_lights_app/screens/light_syncing.dart';
import 'package:pop_lights_app/screens/user_account.dart';
import 'package:pop_lights_app/screens/user_account_tabviews/app_about.dart';
import 'package:pop_lights_app/utilities/app_utils.dart';
import 'package:pop_lights_app/utilities/bluetooth_controller.dart';
import 'package:pop_lights_app/utilities/database_helper.dart';
import 'package:pop_lights_app/utilities/size_config.dart';
import 'package:drop_shadow/drop_shadow.dart';
import '../main.dart';
import '../modals/poplightColorList.dart';
import '../modals/poplight_colors_model.dart';
import '../modals/selected_status.dart';
import '../utilities/app_colors.dart';
import 'Having trouble.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "screens/home_screen";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SelectedStatus> selectedStatusList = [];
  List<ScanResult> discoveredBluetoothDevicesList = [];
  List<PopLightModel> unsyncedpop=[];
  List<BluetoothCharacteristic> ch1=[];
  String popname='',popId='';
  String clrid='';
  bool present=false;

  @override
  void initState() {
    super.initState();

    print("Init called!");

    try {
      if (FlutterBluePlus.isScanningNow == false) {
        FlutterBluePlus.startScan(
            timeout: const Duration(seconds: 2), androidUsesFineLocation: false);
      }
    } catch (e) {
      final snackBar = snackBarFail(prettyException("Start Scan Error:", e));
      snackBarKeyB.currentState?.removeCurrentSnackBar();
      snackBarKeyB.currentState?.showSnackBar(snackBar);
    }
    DatabaseHelper.UnsyncedPopLights().then((value){
      for(int index=0;index<value!.length;index++)
        unsyncedpop.add(value[index]);
    });

  }
  @override
  void dispose() {
    // dispose_disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final Args=(ModalRoute.of(context)!.settings.arguments?? <int,List<dynamic>> {}) as Map;
    // discoveredBluetoothDevicesList=Args["disclist"];
    ch1=Args["ch"];

    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Scaffold(
            backgroundColor: primaryColor,
            body: Stack(children: [
              ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: getProportionateWidth(47.5),
                        top: getProportionateHeight(20.0),
                        right: getProportionateWidth(47.5)),
                    child: loadSVG("assets/home_screen_text_1.svg"),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: getProportionateHeight(30.0), bottom: getProportionateHeight(20.0)),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        loadSVG("assets/ellipse_4.svg"),
                        loadSVG("assets/ellipse_3.svg"),
                        loadSVG("assets/ellipse_2.svg"),
                        loadSVG("assets/ellipse_1.svg"),
                        loadSVG("assets/bt_vector.svg"),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0.0,
                child: StreamBuilder<List<ScanResult>>(
                  stream: FlutterBluePlus.scanResults,
                  initialData: const [],
                  builder: (c, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      // print("ConnectionState.none");

                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "SEARCHING FOR DEVICES...",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: getProportionateHeight(getProportionateHeight(18.0)),
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                height: getProportionateHeight(10.0),
                              ),
                              loadSVG("assets/no_devices_found.svg"),
                              SizedBox(
                                height: getProportionateHeight(20.0),
                              ),
                              loadSVG("assets/no_pop_lights_found_button.svg"),
                              SizedBox(
                                height: getProportionateHeight(20.0),
                              ),
                              Center(
                                  child: Text(
                                    "Make sure your bluetooth & Poplights \n are turned on and in range.",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: getProportionateHeight(16.0)),
                                  )),
                              SizedBox(
                                height: getProportionateHeight(30.0),
                              ),
                              Center(
                                  child: GestureDetector(
                                    onTap: () async {
                                      Navigator.pushReplacementNamed(context, HavingTrouble.routeName, arguments: {
                                        "popid": 4,
                                        "disclist": discoveredBluetoothDevicesList
                                      });
                                    },
                                    child: Text(
                                      "Having trouble?",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: getProportionateHeight(14.0)),
                                    ),
                                  )),
                              SizedBox(
                                height: getProportionateHeight(25.0),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // print("Try again...");
                                  if (FlutterBluePlus.isScanningNow == false) {
                                    FlutterBluePlus.startScan(
                                        timeout: const Duration(seconds: 15),
                                        androidUsesFineLocation: false);
                                  }
                                },
                                child: DropShadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: const Offset(3, 3),
                                  spread: 1,
                                  child: loadSVG("assets/try_again_button.svg"),
                                ),
                              ),
                              SizedBox(
                                height: getProportionateHeight(15.0),
                              ),

                              SizedBox(
                                height: getProportionateHeight(20.0),
                              ),
                            ],
                          ),
                        );

                      case ConnectionState.waiting:
                      // print("ConnectionState.waiting");

                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: getProportionateHeight(425.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "SEARCHING FOR DEVICES...",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: getProportionateHeight(getProportionateHeight(18.0)),
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                height: getProportionateHeight(10.0),
                              ),
                              SizedBox(
                                  width: getProportionateWidth(50.0),
                                  height: getProportionateHeight(50.0),
                                  child: Center(
                                    child: loadSVG("assets/home_search_icon.svg"),
                                  )),
                              //searching_squigly_lines
                              SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: getProportionateHeight(250.0),
                                  child: Center(
                                    child: loadSVG("assets/searching_squigly_lines.svg"),
                                  )),
                            ],
                          ),
                        );

                      case ConnectionState.active:
                      // print("ConnectionState.active");

                        List<ScanResult> tmpr = snapshot.data!;
                        discoveredBluetoothDevicesList.clear();
                        for (int index = 0; index < tmpr.length; index++) {
                          if (tmpr[index].device.localName == "POP_Light") {
                            discoveredBluetoothDevicesList.add(tmpr[index]);
                          }
                        }

                        if (discoveredBluetoothDevicesList.isNotEmpty) {
                          if (discoveredBluetoothDevicesList.length != selectedStatusList.length) {
                            selectedStatusList = List<SelectedStatus>.generate(
                                discoveredBluetoothDevicesList.length,
                                    (i) => SelectedStatus(unselected));
                          }
                          // print("selectedStatusList length: ${selectedStatusList.length}");
                        }

                        // print("dicovered in homw$discoveredBluetoothDevicesList");
                        return (discoveredBluetoothDevicesList.isEmpty)
                            ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "SEARCHING FOR DEVICES...",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: getProportionateHeight(getProportionateHeight(18.0)),
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                height: getProportionateHeight(20.0),
                              ),

                              loadSVG("assets/no_devices_found.svg"),
                              SizedBox(
                                height: getProportionateHeight(20.0),
                              ),
                              loadSVG("assets/no_pop_lights_found_button.svg"),
                              SizedBox(
                                height: getProportionateHeight(20.0),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 50,right:50),
                                child: Center(

                                    child: Text(
                                      textAlign: TextAlign.center,
                                      "Make sure your bluetooth & Poplights are turned on and in range.",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: getProportionateHeight(16.0)
                                          ,overflow: TextOverflow.visible),
                                    )),
                              ),
                              SizedBox(
                                height: getProportionateHeight(60.0),
                              ),
                              Center(
                                  child: GestureDetector(
                                    onTap: () async {
                                      Navigator.pushReplacementNamed(context, HavingTrouble.routeName, arguments: {
                                        "popid": 4,
                                        "disclist": discoveredBluetoothDevicesList,
                                        "ch":ch1
                                      });

                                    },
                                    child: Text(
                                      "Having trouble?",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: getProportionateHeight(14.0)),
                                    ),
                                  )),
                              SizedBox(
                                height: getProportionateHeight(15.0),
                              ),
                              GestureDetector(
                                onTap: () {
                                  print("Try again...");
                                  if (FlutterBluePlus.isScanningNow == false) {
                                    FlutterBluePlus.startScan(
                                        timeout: const Duration(seconds: 15),
                                        androidUsesFineLocation: false);
                                  }
                                },
                                child: DropShadow(
                                  opacity: 0.4,
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                  spread: 1,
                                  child: loadSVG("assets/try_again_button.svg"),
                                ),
                              ),
                              SizedBox(
                                height: getProportionateHeight(55.0),
                              ),
                              // GestureDetector(
                              //     onTap: () async {
                              //       print("Home is pressed");
                              //       Navigator.pushNamed(context, UserAccount.routeName,
                              //           arguments: {
                              //             "popid": 0,
                              //             "disclist": discoveredBluetoothDevicesList
                              //           });
                              //     },
                              //     child: Text(
                              //       "HOME",
                              //       style: TextStyle(
                              //           color: Colors.black,
                              //           fontWeight: FontWeight.w600,
                              //           decoration: TextDecoration.underline,
                              //           fontSize: getProportionateHeight(14.0)),
                              //     )),
                              SizedBox(
                                height: getProportionateHeight(20.0),
                              ),
                            ],
                          ),
                        )
                            :
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: getProportionateHeight(385.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: getProportionateHeight(0.0),
                                ),
                                Text(
                                  "SEARCHING FOR DEVICES...",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: getProportionateHeight(
                                          getProportionateHeight(18.0)),
                                      fontWeight: FontWeight.w900),
                                ),
                                SizedBox(
                                  height: getProportionateHeight(10.0),
                                ),
                                SizedBox(
                                    width: getProportionateWidth(30.0),
                                    height: getProportionateHeight(50.0),
                                    child: Center(
                                      child: Image.asset('assets/devices_found.png'),
                                    )),
                                SizedBox(
                                  height: getProportionateHeight(1.0),
                                ),
                                SizedBox(
                                  height: getProportionateHeight(200.0),
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(top: 14),
                                    children: List.generate(
                                        discoveredBluetoothDevicesList.length, (index) {

                                      is_present(discoveredBluetoothDevicesList[index]);


                                      ScanResult model =
                                      discoveredBluetoothDevicesList[index];
                                      popname='';popId='';clrid="";
                                      for(int i=0;i<unsyncedpop.length;i++)
                                        if(discoveredBluetoothDevicesList[index].device.remoteId.toString()==unsyncedpop[i].popLightId) {
                                          popname = unsyncedpop[i].popLightName;
                                          popId= unsyncedpop[i].popLightId.toString();
                                          // print("I matched ${unsyncedpop[i].popLightId.toString()}");
                                        }

                                      return GestureDetector(
                                        onTap: () {
                                          print("On tap written");

                                          setState(() {
                                            if (selectedStatusList[index].selection ==
                                                unselected) {
                                              selectedStatusList[index] =
                                                  SelectedStatus(selected);
                                            } else {
                                              selectedStatusList[index] =
                                                  SelectedStatus(unselected);
                                            }
                                          });
                                        },
                                        child: Container(
                                            width: getProportionateWidth(87.0),
                                            height: getProportionateHeight(50.0),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2), // Shadow color
                                                  blurRadius: 4.0, // Spread of the shadow
                                                  offset:
                                                  Offset(0, 4), // Offset of the shadow
                                                ),
                                              ],
                                              color: (selectedStatusList[index].selection ==
                                                  selected)
                                                  ? highlightColor
                                                  : (selectedStatusList[index].selection ==
                                                  unselected)
                                                  ? secondaryColor
                                                  : bntColor,
                                              borderRadius: BorderRadius.circular(6.0),
                                              border: Border.all(
                                                  style: BorderStyle.solid,
                                                  color: Colors.black),
                                            ),
                                            margin: EdgeInsets.only(
                                                left: getProportionateWidth(90.0),
                                                right: getProportionateWidth(90.0),
                                                bottom: getProportionateHeight(10.0)),
                                            child: Center(
                                                child: Text(
                                                  popname==""?
                                                  model.device.localName.isEmpty
                                                      ? model.device.remoteId.toString()
                                                      : model.device.localName
                                                      :popname,
                                                  style: TextStyle(
                                                      color:
                                                      (selectedStatusList[index].selection ==
                                                          selected)
                                                          ? bntColor
                                                          : (selectedStatusList[index]
                                                          .selection ==
                                                          unselected)
                                                          ? bntColor
                                                          : highlightColor,
                                                      fontSize: getProportionateHeight(14.0),
                                                      fontWeight: FontWeight.w600),
                                                ))),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                GestureDetector(
                                  // splashColor: Colors.red, // Customize the splash color
                                  // highlightColor: Colors.black12, // Customize the highlight color
                                  child: Container(
                                      width: getProportionateWidth(80.0),
                                      height: getProportionateHeight(40.0),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.2), // Shadow color
                                              blurRadius: 4.0, // Spread of the shadow
                                              offset: Offset(2, 4), // Offset of the shadow
                                            ),
                                          ],
                                          color: secondaryColor,
                                          border: Border.all(
                                              style: BorderStyle.solid, color: Colors.black),
                                          borderRadius: BorderRadius.circular(6.0)),
                                      margin: EdgeInsets.only(
                                          top: getProportionateHeight(15.0),
                                          bottom: getProportionateHeight(15.0)),
                                      child: Center(
                                          child: Text(
                                            "ADD",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: getProportionateHeight(16.0),
                                                fontWeight: FontWeight.w600),
                                          ))),

                                  onTap: () async {
                                    for (int i = 0; i < selectedStatusList.length; i++) {
                                      if (selectedStatusList[i].selection == selected) {
                                        setState(() {
                                          selectedStatusList[i] = SelectedStatus(added);
                                        });
                                      }
                                    }

                                    print("Crossed first for loop");

                                    for (int index = 0;
                                    index < selectedStatusList.length;
                                    index++) {
                                      if (selectedStatusList[index].selection == added) {
                                        List<PopLightModel>? popLightsModelList =
                                        await DatabaseHelper.getAllPopLights();
                                        //
                                        // print(
                                        //     "popLightsModelList: ${popLightsModelList!.length}");
                                        popname='';popId='';clrid='';

                                        for(int i = 0 ;i<unsyncedpop.length;i++)
                                          if(discoveredBluetoothDevicesList[index].device.remoteId.toString()==unsyncedpop[i].popLightId.toString()) {
                                            popname =
                                                unsyncedpop[i].popLightName;
                                            popId = unsyncedpop[i].popLightId
                                                .toString();
                                            clrid = unsyncedpop[i]
                                                .colorid;

                                            // print(
                                            //     "I matched while adding ${unsyncedpop[i]
                                            //         .popLightId.toString()}");
                                          }


                                        await DatabaseHelper.addPopLight(PopLightModel(
                                            popLightId: discoveredBluetoothDevicesList[index]
                                                .device
                                                .remoteId
                                                .toString(),
                                            groupId: 0,
                                            popLightName:popname!=""?popname:
                                            discoveredBluetoothDevicesList[index]
                                                .device
                                                .localName
                                                .isEmpty
                                                ? discoveredBluetoothDevicesList[index]
                                                .device
                                                .remoteId
                                                .toString()
                                                : discoveredBluetoothDevicesList[index]
                                                .device
                                                .localName
                                            ,
                                            isOn: 0,
                                            brightness: 0,
                                            glow: 0,
                                            timer: 0,
                                            colorid: clrid!=""?clrid:'assets/VermillionRedLight.png'));

                                      }
                                    }
                                  },
                                ),

                              ]),
                        );

                      case ConnectionState.done:
                      // print("DONE is also called!");

                        break;
                    }

                    return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          "assets/squiggly_line.png",
                          fit: BoxFit.fill,
                        ));
                  },
                ),
              ),
              SizedBox(
                height: getProportionateHeight(20.0),
              ),
              Align(
                alignment: Alignment(0, 0.96),


                child: GestureDetector(
                  onTap: () async {
                    // for(ScanResult r in discoveredBluetoothDevicesList)
                    //   await disconnection(r);


                    Navigator.pushReplacementNamed(context, DisconnectDevices.routeName, arguments: {
                      // "popid": 0,
                      "disclist": discoveredBluetoothDevicesList,
                      'ch':ch1
                    });
                  },

                  child: Text(
                    "HOME",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: getProportionateHeight(14.0)),
                  ),
                ),),
            ])));



  }
  connection(ScanResult bluetoothDevice) async {


    if (bluetoothDevice.device.localName == 'POP_Light')
    {
      bool present=false;
      for (int index=0;index<ch1.length;index++){
        if(ch1[index].remoteId==bluetoothDevice.device.remoteId) {
          present == true;

        }}
      if(!present){
        print("connection with pop in comparision ");
        print("device iam connecting with $bluetoothDevice");


        isConnectingOrDisconnecting[
        bluetoothDevice.device.remoteId] ??= ValueNotifier(true);
        isConnectingOrDisconnecting[bluetoothDevice.device.remoteId]!
            .value = true;
        await bluetoothDevice.device
            .connect(timeout: Duration(seconds: 1))
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
        await stream(bluetoothDevice);
      }
    }




    // }
  }

  disconnection(ScanResult bluetoothDevice) async {
    print("disConection:--------------------------------------------------");
    // for (ScanResult bluetoothDevice in discoveredBluetoothDevicesList) {
    //   if (!foundPopLightsList.contains(bluetoothDevice))
    //     foundPopLightsList.add(bluetoothDevice);
    // }
    // for (ScanResult bluetoothDevice in discoveredBluetoothDevicesList) {
    if (bluetoothDevice.device.localName == 'POP_Light') {

      print("connection with pop in comparision ");
      print("device iam connecting with $bluetoothDevice");


      isConnectingOrDisconnecting[
      bluetoothDevice.device.remoteId] ??= ValueNotifier(true);
      isConnectingOrDisconnecting[bluetoothDevice.device.remoteId]!
          .value = true;
      await bluetoothDevice.device
          .disconnect(timeout: 1)
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
    // }
  }

  stream(ScanResult r) async {
    print("In Stream ---------------------------------------------------------------");
    // for(ScanResult r in discoveredBluetoothDevicesList){
    List<BluetoothService> services = await r.device.discoverServices(timeout:1);
    // print("Services in stream $services");
    services.forEach((service) async {
      BluetoothCharacteristic? chh,chhh;
      // print("services we got .......${service}");
      if (service.serviceUuid.toString().toUpperCase().contains("FFB0") == true) {
        for (BluetoothCharacteristic bc in service.characteristics) {
          if (bc.characteristicUuid.toString().toUpperCase().contains("FFB1") == true) {
            chh=bc;

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
        if(chh!=null) {
          ch1.add(chh);
        }
        chh=chhh;
      }
    });

    print("Length of ch ${ch1.length}");
  }
  is_present(ScanResult r)async
  {
    bool present=false;
    for (int i=0;i<ch1.length;i++){
      if(ch1[i]?.remoteId==r?.device.remoteId ) {
        present == true;
      }}
    if(!present){
      await  connection(r);
    }
  }

// dispose_disconnect() async{
//   for (ScanResult bluetoothDevice in discoveredBluetoothDevicesList) {
//     isConnectingOrDisconnecting[bluetoothDevice.device.remoteId] ??= ValueNotifier(true);
//     isConnectingOrDisconnecting[bluetoothDevice.device.remoteId]!.value = true;
//     await bluetoothDevice.device.disconnect(timeout:1).catchError((e) {
//       final snackBar = snackBarFail(prettyException("Connect Error:", e));
//       snackBarKeyC.currentState?.removeCurrentSnackBar();
//       snackBarKeyC.currentState?.showSnackBar(snackBar);
//     }).then((v) {
//       isConnectingOrDisconnecting[bluetoothDevice.device.remoteId] ??= ValueNotifier(false);
//       isConnectingOrDisconnecting[bluetoothDevice.device.remoteId]!.value = false;
//     });
//   }
// }


}