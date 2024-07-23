import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BuzzCharacteristicContainer extends StatefulWidget {
  const BuzzCharacteristicContainer({
    super.key,
    required this.buzzCharacteristic,
    required this.isBuzzActive
  });

  final BluetoothCharacteristic? buzzCharacteristic;
  final bool isBuzzActive;

  @override
  State<BuzzCharacteristicContainer> createState() =>
      _BuzzCharacteristicContainerState();
}

class _BuzzCharacteristicContainerState
    extends State<BuzzCharacteristicContainer> {
  bool isLoading = false;
  late List<bool> isSelected = [widget.isBuzzActive];

  handleOnPress(int index) {
    setState(() => isLoading = true);
    widget.buzzCharacteristic?.write([0, isSelected[index] == true ? 0 : 1],
        withoutResponse: true).whenComplete(() {
      isLoading = false;
      isSelected[index] = !isSelected[index];
      setState(() {});
    });
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
              isLoading
                  ? const CircularProgressIndicator()
                  : ToggleButtons(
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      onPressed: handleOnPress,
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
