import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PropulsionCharacteristicContainer extends StatefulWidget {
  const PropulsionCharacteristicContainer(
      {super.key, required this.propulsionCharacteristic});

  final BluetoothCharacteristic? propulsionCharacteristic;

  @override
  State<PropulsionCharacteristicContainer> createState() =>
      _PropulsionCharacteristicContainerState();
}

class _PropulsionCharacteristicContainerState
    extends State<PropulsionCharacteristicContainer> {
  final ValueModel _valueModel = ValueModel();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Especificações de lançamento'),
          content: PropulsionTextField(valueModel: _valueModel),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancelar'),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                widget.propulsionCharacteristic?.write([03, _valueModel.value]);
                Navigator.pop(context, 'OK');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.red,
      child: const Icon(
        size: 72,
        Icons.rocket_launch,
        color: Colors.white,
      ),
    );
  }
}

class PropulsionTextField extends StatefulWidget {
  const PropulsionTextField({super.key, required this.valueModel});

  final ValueModel valueModel;

  @override
  State<PropulsionTextField> createState() => _PropulsionTextFieldState();
}

class _PropulsionTextFieldState extends State<PropulsionTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: TextField(
        onChanged: (value) {
          widget.valueModel.setValue(int.parse(value));
        },
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: const InputDecoration(labelText: "Delay(segundos)"),
      ),
    );
  }
}

class ValueModel extends ChangeNotifier {
  int _value = 0;
  int get value => _value;

  void setValue(int value) {
    _value = value;
    notifyListeners();
  }
}
