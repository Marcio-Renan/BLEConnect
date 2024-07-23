import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ServoCharacteristicContainer extends StatefulWidget{
  const ServoCharacteristicContainer(
      {super.key, required this.servoCharacteristic});

  final BluetoothCharacteristic? servoCharacteristic;

  @override
  State<ServoCharacteristicContainer> createState() =>
      _ServoCharacteristicContainerState();
}

class _ServoCharacteristicContainerState extends State<ServoCharacteristicContainer> {
  double _currentSliderValue = 0;
  bool isMoving = false;

  onCurrentSliderValueChange(double value){
    setState((){
      _currentSliderValue = value;
    });
    if(!isMoving) {
      widget.servoCharacteristic?.write([1, value.round()]).whenComplete((){
      isMoving = false;
    });
      isMoving = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                'Posição do Servo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              Slider(
                min: 0,
                max: 180,
                divisions: 180,
                value: _currentSliderValue,
                label: _currentSliderValue.round().toString(),
                onChanged: onCurrentSliderValueChange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}