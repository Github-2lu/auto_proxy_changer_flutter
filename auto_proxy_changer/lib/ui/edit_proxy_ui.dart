import 'package:auto_proxy_changer/model/proxy_model.dart';
import 'package:flutter/material.dart';

class EditProxyUi extends StatefulWidget {
  const EditProxyUi(
      {required this.proxy,
      required this.proxies,
      required this.onEditProxy,
      required this.onRemoveProxy,
      super.key});

  final ProxyModel proxy;
  final List<ProxyModel> proxies;
  final Function onEditProxy;
  final Function onRemoveProxy;

  @override
  State<EditProxyUi> createState() {
    return _EditProxyUiState();
  }
}

class _EditProxyUiState extends State<EditProxyUi> {
  late final _nameController = TextEditingController(text: widget.proxy.name);
  late final _hostController = TextEditingController(text: widget.proxy.host);
  late final _portController = TextEditingController(text: widget.proxy.port);
  late final _usernameController =
      TextEditingController(text: widget.proxy.username);
  late final _passwordController =
      TextEditingController(text: widget.proxy.password);
  late final _noProxyController =
      TextEditingController(text: widget.proxy.noProxy);

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _noProxyController.dispose();
    super.dispose();
  }

  void _submitEditedProxy() {

    var submitError = false;
    Widget errorContent = const Text('');

    final isOthersNotValid = _hostController.text.trim().isEmpty ||
        _portController.text.trim().isEmpty ||
        _noProxyController.text.trim().isEmpty;

    final isUsernameNotEntered = _usernameController.text.isEmpty && _passwordController.text.isNotEmpty;

    bool isInt(String str){
      try{
        final num = int.parse(str);
        if(num>=0){
          return true;
        }
        else{return false;}
      }
      catch(e){
        return false;
      }
    }

    final isportValid = isInt(_portController.text);

    if(isOthersNotValid){
      submitError = true;
      errorContent = const Text('enter host and port and No_Proxy to add new proxy.');
    }
    else if(!isportValid){
      submitError = true;
      errorContent = const Text('enter a valid +ve number as port');
    }
    else if(_noProxyController.text.split(' ').length>1){
      submitError = true;
      errorContent = const Text('enter No_Proxy without any Space is between two proxies');
    }
    else if(isUsernameNotEntered){
      submitError = true;
      errorContent = const Text('cannot enter password without username');
    }

    if (submitError) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cannot add new proxy'),
          content: errorContent,
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Close'))
          ],
        ),
      );
      return;
    }
    widget.onEditProxy(ProxyModel(
        name: _nameController.text,
        host: _hostController.text,
        port: _portController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        noProxy: _noProxyController.text));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Name: '),
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    // border: OutlineInputBorder(),
                    hintText: 'Ex: Hostel Aruba',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Text('Host: '),
              Expanded(
                child: TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    // border: OutlineInputBorder(),
                    hintText: 'Ex: 10.32.0.1',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Text('Port: '),
              Expanded(
                child: TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    // border: OutlineInputBorder(),
                    hintText: 'Ex: 8080',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Text('Username: '),
              Expanded(
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    // border: OutlineInputBorder(),
                    hintText: 'Ex: sudip.com',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Text('Password: '),
              Expanded(
                child: TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    // border: OutlineInputBorder(),
                    hintText: 'Ex:0902',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Text('No_Proxy: '),
              Expanded(
                child: TextFormField(
                  controller: _noProxyController,
                  decoration: const InputDecoration(
                    // border: OutlineInputBorder(),
                    hintText: 'localhost,127.0.0.1',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                onPressed: _submitEditedProxy,
                child: const Text('Save'),
              ),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  onPressed: () {
                    widget.onRemoveProxy(widget.proxy);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
