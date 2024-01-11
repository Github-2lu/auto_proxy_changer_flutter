import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:auto_proxy_changer/model/proxy_model.dart';
import 'package:auto_proxy_changer/ui/new_proxy_ui.dart';
import 'package:auto_proxy_changer/ui/single_proxy_info_ui.dart';
import 'package:auto_proxy_changer/ui/password_taker_ui.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  List<ProxyModel> proxies = [];
  final supportedDEs = ["gnome", "plasma"];

  late String homeDir;
  late String autoProxyFolderPath;
  late String proxiesFilepath;
  late String autoProxyChangerConfigFilePath;
  late String autoStartGnomeDesktopFilePath;
  late String autoStartKdeDesktopFilePath;
  late String autoProxyShellFilePath;
  late String autoStartSystemFolderPath;
  late String autoStartSystemFilePath;
  late String sudoProxyPassFilePath;
  late String sudoControlShellFilePath;
  late String autoStartControlShellFilePath;
  late String removeProxyShellFilePath;
  final String sudoProxyPassSystemFilePath = "/etc/sudoers.d/sudo_proxy_pass";

  late File proxiesFile;
  late File autoProxyChangerConfigFile;
  late File autoStartGnomeDesktopFile;
  late File autoStartKdeDesktopFile;

  late String desktopSession;

  bool fileExists = true;

  bool autoStartEnabled = false;
  bool sudoProxyEnabled = false;
  bool initSutoStartEnable = false;
  bool initSudoProxyEnable = false;

  String sudoPassword = '';
  late bool isCommandRunSuccessful;

  void _addProxy(ProxyModel proxy) {
    setState(() {
      proxies.add(proxy);
    });
    final String encodedProxiesJson =
        jsonEncode(proxies.map((proxy) => proxy.toJson()).toList());
    proxiesFile.writeAsString(encodedProxiesJson);
  }

  void _editproxy(ProxyModel editedProxy) {
    var index = 0;
    for (final proxy in proxies) {
      if (proxy.name == editedProxy.name) {
        break;
      }
      index++;
    }
    setState(() {
      proxies[index] = editedProxy;
    });
    final String encodedProxiesJson =
        jsonEncode(proxies.map((proxy) => proxy.toJson()).toList());
    proxiesFile.writeAsString(encodedProxiesJson);
  }

  void _removeProxy(ProxyModel proxy) {
    setState(() {
      proxies.remove(proxy);
    });
    final String encodedProxiesJson =
        jsonEncode(proxies.map((proxy) => proxy.toJson()).toList());
    proxiesFile.writeAsString(encodedProxiesJson);
  }

  runShell(String command, List<String> arguments) async {
    var res = await Process.run(command, arguments, runInShell: true);
    // print(res.stdout.toString());
    print('result: ${res.stdout.toString()}');
    if (res.stdout.toString().contains("SUCCESS")) {
      // print("yes");
      // isCommandRunSuccessful = true;
      return true;
    }
    return false;
  }

  void _changeAutoProxyChangerConfigFile(
      {bool? autoStartEnable, bool? sudoProxyEnable}) async {
    print('$autoStartEnable $sudoProxyEnable');
    isCommandRunSuccessful = false;
    if (autoStartEnable != null && sudoProxyEnable != null) {
      print('$autoStartEnable , $autoStartEnabled');
      if (autoStartEnable != autoStartEnabled) {
        if (autoStartEnable) {
          if (desktopSession == "plasma") {
            isCommandRunSuccessful = await runShell('bash', [
              autoStartControlShellFilePath,
              'sed',
              autoStartKdeDesktopFilePath,
              autoStartSystemFilePath
            ]);
            print('cp $autoStartKdeDesktopFilePath $autoStartSystemFilePath');
            print('success $isCommandRunSuccessful in autostart');
          } else if (desktopSession == "gnome") {
            isCommandRunSuccessful = await runShell('bash', [
              autoStartControlShellFilePath,
              'sed',
              autoStartGnomeDesktopFilePath,
              autoStartSystemFilePath
            ]);
          }
        } else {
          isCommandRunSuccessful = await runShell('bash',
              [autoStartControlShellFilePath, 'rm', autoStartSystemFilePath]);
        }
      }

      if (sudoProxyEnable != sudoProxyEnabled) {
        if (sudoProxyEnable) {
          print(sudoProxyEnable);
          // runShell('rm', ['-f', autoStartSystemFilePath]);
          isCommandRunSuccessful = await runShell("bash", [
            sudoControlShellFilePath,
            'cp',
            sudoPassword,
            sudoProxyPassFilePath,
            sudoProxyPassSystemFilePath
          ]);
          print('sudorun:$isCommandRunSuccessful');
        } else {
          print(sudoProxyEnable);
          isCommandRunSuccessful = await runShell("bash", [
            sudoControlShellFilePath,
            'rm',
            sudoPassword,
            sudoProxyPassSystemFilePath
          ]);
        }
      }
      print(isCommandRunSuccessful);

      if (isCommandRunSuccessful) {
        setState(() {
          autoStartEnabled = autoStartEnable;
          sudoProxyEnabled = sudoProxyEnable;
        });

        final autoStartConfigObj = AutoProxyChangerConfigClass(
            autoStartEnabled: autoStartEnabled,
            sudoProxyEnabled: sudoProxyEnabled);

        // print(autoStartConfigObj.toJson());
        String encodedAutoStartCofig = jsonEncode(autoStartConfigObj.toJson());
        autoProxyChangerConfigFile.writeAsString(encodedAutoStartCofig);
        // print(encodedAutoStartCofig);
      }
    }
  }

  void _getSudoPassword(String inputSudoPassword) {
    sudoPassword = inputSudoPassword;
    print(sudoPassword);
    _changeAutoProxyChangerConfigFile(
        autoStartEnable: autoStartEnabled,
        sudoProxyEnable: initSudoProxyEnable);
    sudoPassword = '';
    print(sudoPassword);
  }

  Future<bool> _checkFiles() async {
    if (Platform.environment['HOME'] == null) {
      return false;
    }

    if (!supportedDEs.contains(Platform.environment['DESKTOP_SESSION'])) {
      return false;
    }

    desktopSession = Platform.environment['DESKTOP_SESSION']!;

    homeDir = Platform.environment['HOME']!;
    autoProxyFolderPath = "$homeDir/.autoproxy";
    proxiesFilepath = "$autoProxyFolderPath/proxies.json";
    autoProxyChangerConfigFilePath =
        "$autoProxyFolderPath/auto_proxy_changer_conf.json";
    autoProxyShellFilePath = "$autoProxyFolderPath/auto_proxy.sh";
    autoStartGnomeDesktopFilePath =
        "$autoProxyFolderPath/auto_start_gnome.desktop";
    autoStartKdeDesktopFilePath = "$autoProxyFolderPath/auto_start_kde.desktop";
    autoStartSystemFolderPath = "$homeDir/.config/autostart";
    autoStartSystemFilePath =
        "$autoStartSystemFolderPath/auto_proxy_start.desktop";
    sudoControlShellFilePath = "$autoProxyFolderPath/sudo_control.sh";
    autoStartControlShellFilePath =
        "$autoProxyFolderPath/auto_start_control.sh";
    removeProxyShellFilePath = "$autoProxyFolderPath/remove_proxy.sh";
    sudoProxyPassFilePath = "$autoProxyFolderPath/sudo_proxy_pass";

    bool proxiesFileExist = await File(proxiesFilepath).exists();
    bool autoProxyShellFileExist = await File(autoProxyShellFilePath).exists();
    bool autoStartConfigFileExist =
        await File(autoProxyChangerConfigFilePath).exists();
    bool autoStartGnomeDesktopFileExist =
        await File(autoStartGnomeDesktopFilePath).exists();
    bool autoStartKdeDesktopFileExist =
        await File(autoStartKdeDesktopFilePath).exists();
    bool sudoControlShellFileExist =
        await File(sudoControlShellFilePath).exists();
    bool autoStartControlShellFileExist =
        await File(autoStartControlShellFilePath).exists();
    bool removeProxyShellFileExist =
        await File(removeProxyShellFilePath).exists();
    bool sudoProxyPassFileExist = await File(sudoProxyPassFilePath).exists();

    return proxiesFileExist &&
        autoProxyShellFileExist &&
        autoStartConfigFileExist &&
        autoStartGnomeDesktopFileExist &&
        autoStartKdeDesktopFileExist &&
        sudoControlShellFileExist &&
        sudoProxyPassFileExist &&
        removeProxyShellFileExist &&
        autoStartControlShellFileExist;
  }

  void _openFilePointers() {
    proxiesFile = File(proxiesFilepath);
    autoProxyChangerConfigFile = File(autoProxyChangerConfigFilePath);
    autoStartGnomeDesktopFile = File(autoStartGnomeDesktopFilePath);
    autoStartKdeDesktopFile = File(autoStartKdeDesktopFilePath);
  }

  Future<List<ProxyModel>> _getProxies() async {
    List<ProxyModel> startProxyList = [];
    try {
      // proxiesFile = File(proxiesFilepath);

      String proxiesFileContent = await proxiesFile.readAsString();
      List<dynamic> jsonObj = jsonDecode(proxiesFileContent);
      for (final jsonProxy in jsonObj) {
        startProxyList.add(ProxyModel.fromJson(jsonProxy));
      }
    } catch (e) {}

    return startProxyList;
  }

  Future<AutoProxyChangerConfigClass> _getautoProxyChangerConfig() async {
    var initAutoProxyChangerConfigObj = AutoProxyChangerConfigClass(
        autoStartEnabled: false, sudoProxyEnabled: false);
    try {
      final autoProxyChangerConfigString =
          await autoProxyChangerConfigFile.readAsString();
      final autoProxyChangerConfigJson =
          jsonDecode(autoProxyChangerConfigString);
      // print(autoStartConfigJson);
      final autoProxyChangerConfigObj =
          AutoProxyChangerConfigClass.fromJson(autoProxyChangerConfigJson);
      // print(autoStartConfig.autoStartEnabled);
      initAutoProxyChangerConfigObj = autoProxyChangerConfigObj;
    } catch (e) {}
    return initAutoProxyChangerConfigObj;
  }

  @override
  void initState() {
    _checkFiles().then((value) {
      setState(() {
        fileExists = value;
      });
    });
    _openFilePointers();
    _getProxies().then((value) {
      setState(() {
        proxies = value;
      });
    });
    _getautoProxyChangerConfig().then((autoProxyChangerConfigObj) {
      setState(() {
        autoStartEnabled = autoProxyChangerConfigObj.autoStartEnabled;
        sudoProxyEnabled = autoProxyChangerConfigObj.sudoProxyEnabled;
        print('autoStart: $autoStartEnabled, sudo: $sudoProxyEnabled');
        // print('$autoStartEnabled, $sudoProxyEnabled');
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget listVieworNot = proxies.isEmpty
        ? const Center(
            child: Text(
                'No proxies here. To add click Add New Proxes Buttonbelow'))
        : Expanded(
            child: ListView.builder(
              itemCount: proxies.length,
              itemBuilder: (context, index) => SingleProxyInfoUi(
                  proxy: proxies[index],
                  proxies: proxies,
                  onEditProxy: _editproxy,
                  onRemoveProxy: _removeProxy),
            ),
          );
    if (!fileExists) {
      return AlertDialog(
        title: Text("All files are not in $homeDir/.autoProxy folder"),
        content: const Text('Reinstalling the app may solve the problem.'),
      );
    }

    return Column(children: [
      listVieworNot,
      // const Spacer(),
      const SizedBox(
        height: 40,
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
        onPressed: () {
          showModalBottomSheet(
              // isScrollControlled:true,
              context: context,
              builder: (ctx) => NewProxyUi(
                    onAddProxy: _addProxy,
                    proxies: proxies,
                  ));
        },
        child: const Text('Add New Proxy'),
      ),
      const SizedBox(
        height: 10,
      ),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
          onPressed: () {
            Process.run('bash', [removeProxyShellFilePath]);
          },
          child: const Text('Remove proxy settings')),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
              'Auto start autoproxychanger app at startup in background (reboot required): '),
          Checkbox(
              value: autoStartEnabled,
              onChanged: (value) {
                _changeAutoProxyChangerConfigFile(
                    autoStartEnable: value, sudoProxyEnable: sudoProxyEnabled);
                print('value: $value');
              }),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
              'Add proxy settings for sudo users too (sudo password and reboot required) : '),
          Checkbox(
              value: sudoProxyEnabled,
              onChanged: (value) {
                showDialog(
                    context: context,
                    builder: (ctx) =>
                        PasswordTakerUi(onGetSudoPassword: _getSudoPassword));
                initSudoProxyEnable = value!;
              }),
        ],
      ),
      // const Spacer(),
      const SizedBox(
        height: 10,
      )
    ]);
  }
}
