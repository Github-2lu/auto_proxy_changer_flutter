import 'package:flutter/material.dart';
import 'package:auto_proxy_changer/model/proxy_model.dart';
import 'package:auto_proxy_changer/ui/edit_proxy_ui.dart';

class SingleProxyInfoUi extends StatelessWidget {
  const SingleProxyInfoUi(
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
  Widget build(BuildContext context) {
    // return Card(
    //   child: Row(
    //     children: [
    //       const Spacer(),
    //       Column(children: [
    //         Text('Name: ${proxy.name}'),
    //         Text('host: ${proxy.host}'),
    //         Text('port: ${proxy.port}'),
    //         Text('Username: ${proxy.username}'),
    //         Text('Password: ${proxy.password}'),
    //         Text('NoProxy: ${proxy.noProxy}')
    //       ]),
    //       const Spacer(),
    //       IconButton(
    //           onPressed: () {
    //             showModalBottomSheet(
    //                 context: context,
    //                 builder: (ctx) => EditProxyUi(
    //                     proxy: proxy,
    //                     proxies: proxies,
    //                     onEditProxy: onEditProxy,
    //                     onRemoveProxy: onRemoveProxy));
    //           },
    //           icon: const Icon(Icons.settings))
    //     ],
    //   ),
    // );

    return ListTile(
      // shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 1), borderRadius: BorderRadius.circular(5)),
      title: Text('WiFi Name => ${proxy.name}'),
      subtitle: proxy.username == ''
          ? Text('proxy => http://${proxy.host}:${proxy.port}')
          : Text(
              'proxy => ${proxy.username}:${proxy.password}@${proxy.host}:${proxy.port}'),
      trailing: IconButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (ctx) => EditProxyUi(
                  proxy: proxy,
                  proxies: proxies,
                  onEditProxy: onEditProxy,
                  onRemoveProxy: onRemoveProxy));
        },
        icon: const Icon(Icons.settings),
      ),
    );
  }
}
