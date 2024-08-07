import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BmpCharacteristicContainer extends StatefulWidget {
  const BmpCharacteristicContainer(
      {super.key, required this.bmpCharacteristic});

  final BluetoothCharacteristic? bmpCharacteristic;

  @override
  State<BmpCharacteristicContainer> createState() =>
      _BmpCharacteristicContainerState();
}

class _BmpCharacteristicContainerState extends State<BmpCharacteristicContainer> {
  late StreamSubscription<List<int>>? onValueReceivedSubscription;
  List<int> values = [95, 95, 95, 95, 95, 95];

  @override
  initState() {
    super.initState();
    widget.bmpCharacteristic?.setNotifyValue(true).whenComplete(() {
      onValueReceivedSubscription = widget.bmpCharacteristic?.onValueReceived.listen((value) {
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
    String altitude = utf8.decode(values);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text(
              'Altitude',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            Text(
              '$altitude metros',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}