// import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:process_run/shell_run.dart';

class PasswordTakerUi extends StatefulWidget {
  const PasswordTakerUi({super.key, required this.onGetSudoPassword});

  final Function onGetSudoPassword;

  @override
  State<PasswordTakerUi> createState() {
    return _PasswordTakerUiState();
  }
}

class _PasswordTakerUiState extends State<PasswordTakerUi> {
  final _sudoPasswordController = TextEditingController();

  // void _runshell() async {
  //   await run('echo ${_sudoPasswordController.text} | sudo fdisk -l');
  // }

  // void _createSudoProxy(){
  //   new File('/etc/github/2lu').create(recursive: true);
  // }

  void _submitSudoPassword(){
    widget.onGetSudoPassword(_sudoPasswordController.text);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _sudoPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Sudo password'),
      content: TextFormField(controller: _sudoPasswordController),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel')),
        ElevatedButton(onPressed: _submitSudoPassword, child: const Text('Enter'))
      ],
    );
  }
}
