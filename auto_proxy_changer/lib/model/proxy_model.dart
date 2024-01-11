class ProxyModel {
  ProxyModel(
      {required this.name,
      required this.host,
      required this.port,
      required this.username,
      required this.password,
      required this.noProxy});
  // final String id;
  final String name;
  final String host;
  final String port;
  final String username;
  final String password;
  final String noProxy;

  ProxyModel.fromJson(Map<String, dynamic> jsonData)
      : name = jsonData['name'],
        host = jsonData['host'],
        port = jsonData['port'],
        username = jsonData['username'],
        password = jsonData['password'],
        noProxy = jsonData['noProxy'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'host': host,
        'port': port,
        'username': username,
        'password': password,
        'noProxy': noProxy
      };
}

class AutoProxyChangerConfigClass {
  AutoProxyChangerConfigClass(
      {required this.autoStartEnabled, required this.sudoProxyEnabled});
  bool autoStartEnabled;
  bool sudoProxyEnabled;

  AutoProxyChangerConfigClass.fromJson(Map<String, dynamic> autoProxyChangerConfigJson)
      : autoStartEnabled =
            autoProxyChangerConfigJson['autoStartEnabled'] == "true" ? true : false,
        sudoProxyEnabled =
            autoProxyChangerConfigJson['sudoProxyEnabled'] == "true" ? true : false;

  Map<String, dynamic> toJson() =>
      {'autoStartEnabled': autoStartEnabled.toString(), 'sudoProxyEnabled':sudoProxyEnabled.toString()};
}
