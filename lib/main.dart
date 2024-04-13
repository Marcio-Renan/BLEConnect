import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_aplication_1/device_screen.dart';
import 'dart:io' show Platform;

bool bleSupported = false;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  bleSupported = await FlutterBluePlus.isSupported;
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({super.key});

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = bleSupported
        ? _adapterState == BluetoothAdapterState.on 
        ? const ScanScreen() : BluetoothOffScreen(adapterState: _adapterState) : const BLENotSupported();

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
          ),
        ),
      home: screen,
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }
}

//
// This observer listens for Bluetooth Off and dismisses the DeviceScreen
//
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Pop the current route if Bluetooth is off
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}

class ScanScreen extends StatefulWidget{
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>{
  StreamSubscription<List<ScanResult>>? _onScanResultsSubscription;
  StreamSubscription<bool>? _isScanningSubscription;

  List<ScanResult>? scanResult = [];
  bool isScanning = false;

  @override
  initState(){
    super.initState();
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((scanStatus){
      isScanning = scanStatus;
      if(mounted){
        setState((){});
      }
    });
    _onScanResultsSubscription = FlutterBluePlus.onScanResults.listen((results) {
        if (results.isNotEmpty) {
            scanResult = results;
            if(mounted){
              setState(() {});
            }
        }
      },
      onError: (e) => debugPrint(e),
    );
  }

  @override
  void dispose() {
    _onScanResultsSubscription?.cancel();
    _isScanningSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async{
          !isScanning ?
          await FlutterBluePlus.startScan(
            timeout: const Duration(seconds:15),
            ) :
          FlutterBluePlus.stopScan();
        },
        icon: Icon(
          isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
        ),
        label: const Text('Scan'),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child:  Icon(
              Icons.bluetooth,
              size: 400,
              color: Theme.of(context).colorScheme.primary,
            ),
            ),
          ListView.builder(
            itemCount: scanResult?.length,
            itemBuilder: (BuildContext context, int index){
              return DeviceInformation(scanResult: scanResult?[index]);
            }
          ),
        ],
      ),
    );
  }
}

class DeviceInformation extends StatefulWidget {
  const DeviceInformation({
    super.key,
    required this.scanResult,
  });

  final ScanResult? scanResult;
  
  @override
  State<DeviceInformation> createState() => _DeviceInformationState();
}

class _DeviceInformationState extends State<DeviceInformation>{
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  @override
  initState(){
    super.initState();
    _connectionStateSubscription = widget.scanResult?.device.connectionState.listen((state){
      if(mounted){
        setState((){});
      }
    });
  }

  @override
  dispose(){
    _connectionStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: 98,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Icon(
                    Icons.devices_other,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${widget.scanResult?.device.advName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        '${widget.scanResult?.device.remoteId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ConnectButton(device: widget.scanResult?.device),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectButton extends StatelessWidget {
  const ConnectButton({
    super.key,
    required this.device,
  });

  final BluetoothDevice? device;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceScreen(device: device),
          settings: const RouteSettings(name: '/DeviceScreen'),
          ),
        );
      },
      child: const Row(
        children: <Widget>[
          Icon(
            Icons.cable,
          ),
          SizedBox(
            width:5,
          ),
          Text('Configurar'),
        ],
      ),
    );
  }
}

class BluetoothOffScreen extends StatefulWidget{
  const BluetoothOffScreen({super.key, required this.adapterState});

  final BluetoothAdapterState adapterState;

  @override
  State<BluetoothOffScreen> createState() => _BluetoothOffScreenState();
}

class _BluetoothOffScreenState extends State<BluetoothOffScreen>{
  

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled_outlined,
              color: Colors.redAccent,
              size: 400,
            ),
            AlertDialog(
              content: const SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text('O Bluetooth está desligado, ligue-o para acessar o aplicativo.'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Icon(
                    Icons.bluetooth,

                  ),
                  onPressed: () async{
                    if(Platform.isAndroid){
                      try{
                        await FlutterBluePlus.turnOn();
                      } catch(e){
                        debugPrint(e.toString());
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BLENotSupported extends StatelessWidget{
  const BLENotSupported({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled_outlined,
              color: Theme.of(context).colorScheme.secondary,
              size: 400,
            ),
            const AlertDialog(
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text('Esse dispositivo não possui suporte a Bluetooth Low Energy, tente usar outro celular.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}