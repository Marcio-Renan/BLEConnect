import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_aplication_1/components/bmp_container.dart';
import 'package:flutter_aplication_1/components/buzz_container.dart';
import 'package:flutter_aplication_1/components/filesystem_container.dart';
import 'package:flutter_aplication_1/components/mpu_container.dart';
import 'package:flutter_aplication_1/components/propulsion_container.dart';
import 'package:flutter_aplication_1/components/servo_container.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key, required this.device});

  final BluetoothDevice? device;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<BluetoothService>? services;
  List<BluetoothCharacteristic>? deviceCharacteristics;
  StreamSubscription<BluetoothConnectionState>? connectionStateSubscription;
  BluetoothCharacteristic? utilsCharacteristic;
  BluetoothCharacteristic? bmpCharacteristic;
  BluetoothCharacteristic? mpuCharacteristic;
  bool _loading = false;

  @override
  initState() {
    super.initState();
    connectionStateSubscription = widget.device?.connectionState
        .listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.connected) {
        services = await widget.device?.discoverServices();
        services?.forEach((service) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid ==
                Guid('beb5483e-36e1-4688-b7f5-ea07361b26a8')) {
              utilsCharacteristic = characteristic;
            }
            if (characteristic.uuid == Guid('cba1d466-344c-4be3-ab3f-189f80dd7518')){
              bmpCharacteristic = characteristic;
            }
            if (characteristic.uuid == Guid("f78ebbff-c8b7-4107-93de-889a6a06d408")){
              mpuCharacteristic = characteristic;
            }
            deviceCharacteristics?.add(characteristic);
          }
        });
      }
      if (state == BluetoothConnectionState.disconnected) {
        utilsCharacteristic = null;
        mpuCharacteristic = null;
        bmpCharacteristic = null;
        deviceCharacteristics = [];
      }
      _loading = false;
      setState(() {});
    });
  }

  @override
  dispose() {
    super.dispose();
    connectionStateSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          TextButton.icon(
              icon: (widget.device?.isConnected ?? false)
                  ? const Icon(Icons.link_off)
                  : _loading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.link),
              label: (widget.device?.isConnected ?? false)
                  ? const Text('Desconectar')
                  : const Text('Conectar'),
              onPressed: _loading
                  ? null
                  : () async {
                      try {
                        setState(() {
                          _loading = true;
                        });
                        (widget.device?.isConnected ?? false)
                            ? await widget.device?.disconnect()
                            : await widget.device?.connect();
                      } catch (e) {
                        debugPrint("Erro ao conectar/desconectar");
                      }
                    }),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: Text((widget.device?.advName ?? 'null')),
      ),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Column(
        children: [
          if (bmpCharacteristic != null)
            BmpCharacteristicContainer(bmpCharacteristic: bmpCharacteristic),
          if (mpuCharacteristic != null)
            MpuCharacteristicContainer(mpuCharacteristic: mpuCharacteristic),
          if (utilsCharacteristic != null) ...[
            BuzzCharacteristicContainer(buzzCharacteristic: utilsCharacteristic),
            FileSystemCharacteristicContainer(filesystemCharacteristic: utilsCharacteristic),
            ServoCharacteristicContainer(servoCharacteristic: utilsCharacteristic),
          ],
        ],
      ),
      floatingActionButton: utilsCharacteristic != null ? PropulsionCharacteristicContainer(propulsionCharacteristic: utilsCharacteristic) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

