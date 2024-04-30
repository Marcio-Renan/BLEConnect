import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MpuCharacteristicContainer extends StatefulWidget {
  const MpuCharacteristicContainer(
      {super.key, required this.mpuCharacteristic});

  final BluetoothCharacteristic? mpuCharacteristic;

  @override
  State<MpuCharacteristicContainer> createState() =>
      _BmpCharacteristicContainerState();
}

class _BmpCharacteristicContainerState
    extends State<MpuCharacteristicContainer> {
  late StreamSubscription<List<int>>? onValueReceivedSubscription;
  List<int> values = [95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95];

  @override
  initState(){
    super.initState();
    widget.mpuCharacteristic?.setNotifyValue(true).whenComplete(() {
      onValueReceivedSubscription =
          widget.mpuCharacteristic?.onValueReceived.listen((value) {
        values = value;
        setState((){});
      });
    });
  }

  @override
  dispose() {
    super.dispose();
    onValueReceivedSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String decodedValues = utf8.decode(values);
    String yaw = decodedValues.substring(0, 6);
    String pitch = decodedValues.substring(6, 12);
    String roll = decodedValues.substring(12, 18);


    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const Text(
                  'Angulação',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                Text(
                  'Yaw: $yaw, Pitch: $pitch, Row: $roll',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}