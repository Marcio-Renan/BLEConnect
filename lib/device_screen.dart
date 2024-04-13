import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget{
  const DeviceScreen({super.key, required this.device});

  final BluetoothDevice? device;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen>{
  List<BluetoothService>? services;
  List<BluetoothCharacteristic>? deviceCharacteristics;
  BluetoothCharacteristic? buzzCharacteristic;
  bool buzzActive = false;
  bool _loading = false;
  List<bool>isSelected = [false];

  @override
  dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          TextButton.icon(
            icon: (widget.device?.isConnected ?? false) ? const Icon(Icons.link_off) : _loading ? const CircularProgressIndicator() : const Icon(Icons.link),
            label: (widget.device?.isConnected ?? false) ? const Text('Desconectar') : const Text('Conectar'),
            onPressed: _loading ? null : () async{
              try{
                setState((){_loading = true;});
                (widget.device?.isConnected ?? false) ? await widget.device?.disconnect() : await widget.device?.connect();
                if((widget.device?.isConnected??false)){
                  dynamic connectionStateSubscription = widget.device?.connectionState.listen((BluetoothConnectionState state) async{
                    if(state == BluetoothConnectionState.connected){
                      services = await widget.device?.discoverServices();
                      services?.forEach((service) {
                      for(var characteristic in service.characteristics){
                        if(characteristic.uuid == Guid('beb5483e-36e1-4688-b7f5-ea07361b26a8')){
                          buzzCharacteristic = characteristic;
                        }
                        deviceCharacteristics?.add(characteristic);
                      }
                      });
                    }
                    if(state == BluetoothConnectionState.disconnected){
                      buzzCharacteristic = null;
                      deviceCharacteristics = [];
                    }
                    _loading = false;
                    setState(() {});
                  });
                  widget.device?.cancelWhenDisconnected(connectionStateSubscription, delayed: true, next: true);
                }
              } catch(e){
                debugPrint("Erro ao conectar/desconectar");
              }
            }
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: Text((widget.device?.advName ?? 'null')),
      ),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: (deviceCharacteristics?.isEmpty ?? true) ? null : Column(
        children: [
          Padding(
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
                        buzzActive && (widget.device?.isConnected??false) ? await buzzCharacteristic?.write([0x00, 0x00]) : await buzzCharacteristic?.write([0x01, 0x01]);
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
          ),
        ],
      ),
      floatingActionButton: !(widget.device?.isConnected??false) ? null : FloatingActionButton.large(
        backgroundColor: Colors.red,
        onPressed: (){

        },
        child: const Icon(
          Icons.rocket_launch,
          size: 60,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}