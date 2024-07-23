import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FileSystemCharacteristicContainer extends StatefulWidget {
  const FileSystemCharacteristicContainer({
    super.key,
    required this.filesystemCharacteristic,
    required this.isWriting,
  });

  final BluetoothCharacteristic? filesystemCharacteristic;
  final bool isWriting;

  @override
  State<FileSystemCharacteristicContainer> createState() =>
      _FileSystemCharacteristicContainerState();
}

class _FileSystemCharacteristicContainerState
    extends State<FileSystemCharacteristicContainer> {
  late bool isWriting = widget.isWriting;
  bool isWriteButtonLoading = false;

  handleWriteButtonPress(){
    setState(() => isWriteButtonLoading = true);
    widget.filesystemCharacteristic?.write([2, 1, isWriting ? 0 : 1]).whenComplete((){
      isWriting = !isWriting;
      isWriteButtonLoading = false;
      setState((){});
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
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const Text(
                  'Arquivo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.filesystemCharacteristic?.write([2, 0]);
                      },
                      child: const Text(
                        "Formatar",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isWriting ? Colors.green : Colors.red,
                      ),
                      onPressed: isWriteButtonLoading ? null : handleWriteButtonPress,
                      child: Text(
                        isWriting ? "Escrevendo" : "Escrever?",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.filesystemCharacteristic?.write([2, 2]);
                      },
                      child: const Text(
                        "Ler",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
