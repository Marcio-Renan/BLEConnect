import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BuzzCharacteristicContainer extends StatefulWidget {
  const BuzzCharacteristicContainer({
    super.key,
    required this.buzzCharacteristic,
  });

  final BluetoothCharacteristic? buzzCharacteristic;

  @override
  State<BuzzCharacteristicContainer> createState() => _BuzzCharacteristicContainerState();
}

class _BuzzCharacteristicContainerState extends State<BuzzCharacteristicContainer> {
  bool buzzActive = false;
  List<bool>isSelected = [false];

  @override
  Widget build(BuildContext context) {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                'Ativar Buzzer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              ToggleButtons(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                onPressed: (int index) async{
                  buzzActive ? await widget.buzzCharacteristic?.write([0x00, 0x00]) : await widget.buzzCharacteristic?.write([0x01, 0x01]);
                  isSelected[index] = !isSelected[index];
                  setState((){
                    buzzActive = !buzzActive;
                  });
                },
                isSelected: isSelected,
                children: const [
                  Icon(
                    Icons.audiotrack,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}