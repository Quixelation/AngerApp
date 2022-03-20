part of vertretungsplan;

class _VpCreds {
  final bool providedCreds;
  final String creds;
  final bool loadedCreds;
  _VpCreds(
    this.providedCreds,
    this.creds, {
    required this.loadedCreds,
  });
  @override
  String toString() => '_VpCreds(providedCreds: $providedCreds, creds: $creds)';
}

BehaviorSubject<_VpCreds> _vpCreds =
    BehaviorSubject.seeded(_VpCreds(false, "", loadedCreds: false));

_vpSaveCreds(String creds) async {
  var db = getIt.get<AppManager>().db;

  AppManager.stores.data.record("vpcreds").put(db, {
    "key": "vpcreds",
    "value": creds,
  });

  _vpCreds.add(_VpCreds(true, creds, loadedCreds: true));
}

_vpLogout() {
  var db = getIt.get<AppManager>().db;

  AppManager.stores.data.record("vpcreds").delete(db);

  _vpCreds.add(_VpCreds(false, "", loadedCreds: true));
}

void _vpLoadCreds() async {
  var db = getIt.get<AppManager>().db;

  var creds = await AppManager.stores.data.record("vpcreds").get(db);

  if (creds == null) {
    _vpCreds.add(_VpCreds(false, "", loadedCreds: true));
  } else {
    _vpCreds.add(_VpCreds(true, creds["value"].toString(), loadedCreds: true));
  }
}

void vpUnloadCreds__DEVELOPER_ONLY() {
  _vpCreds.add(_VpCreds(false, "", loadedCreds: false));
}
