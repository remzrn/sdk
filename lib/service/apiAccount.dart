import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:polkawallet_sdk/consts/settings.dart';
import 'package:polkawallet_sdk/service/api.dart';

class ApiAccount {
  ApiAccount(this.apiRoot);

  final PolkawalletApi apiRoot;

  final String keyTypeMnemonic = 'mnemonic';
  final String keyTypeRawSeed = 'rawSeed';
  final String keyTypeKeystore = 'keystore';

//  Future<void> initAccounts() async {
//    if (apiRoot.storage.keyPairs.val.length > 0) {
//      String accounts = jsonEncode(apiRoot.storage.keyPairs.val);
//
//      String ss58 = jsonEncode(network_ss58_map.values.toSet().toList());
//      Map keys =
//          await apiRoot.evalJavascript('account.initKeys($accounts, $ss58)');
//      store.account.setPubKeyAddressMap(Map<String, Map>.from(keys));
//
//      // get accounts icons
//      getPubKeyIcons(store.account.accountList.map((i) => i.pubKey).toList());
//    }
//
//    // and contacts icons
//    List<AccountData> contacts =
//        List<AccountData>.of(store.settings.contactList);
//    getAddressIcons(contacts.map((i) => i.address).toList());
//    // set pubKeyAddressMap for observation accounts
//    contacts.retainWhere((i) => i.observation);
//    List<String> observations = contacts.map((i) => i.pubKey).toList();
//    if (observations.length > 0) {
//      encodeAddress(observations);
//      getPubKeyIcons(observations);
//    }
//  }
//
//  /// encode addresses to publicKeys
//  Future<void> encodeAddress(List<String> pubKeys) async {
//    String ss58 = jsonEncode(network_ss58_map.values.toSet().toList());
//    Map res = await apiRoot.evalJavascript(
//      'account.encodeAddress(${jsonEncode(pubKeys)}, $ss58)',
//      allowRepeat: true,
//    );
//    if (res != null) {
//      store.account.setPubKeyAddressMap(Map<String, Map>.from(res));
//    }
//  }
//
//  /// decode addresses to publicKeys
//  Future<Map> decodeAddress(List<String> addresses) async {
//    Map res = await apiRoot
//        .evalJavascript('account.decodeAddress(${jsonEncode(addresses)})');
//    if (res != null) {
//      store.account.setPubKeyAddressMap(Map<String, Map>.from(
//          {store.settings.endpoint.ss58.toString(): res}));
//    }
//    return res;
//  }
//
//  Future<void> changeCurrentAccount({
//    String pubKey,
//    bool fetchData = false,
//  }) async {
//    String current = pubKey;
//    if (pubKey == null) {
//      if (store.account.accountListAll.length > 0) {
//        current = store.account.accountListAll[0].pubKey;
//      } else {
//        current = '';
//      }
//    }
//    store.account.setCurrentAccount(current);
//
//    // refresh balance
//    store.assets.clearTxs();
//    store.assets.loadAccountCache();
//    if (fetchData) {
//      webApi.assets.fetchBalance();
//    }
//    if (store.settings.endpoint.info == networkEndpointAcala.info) {
//      store.acala.setTransferTxs([], reset: true);
//      store.acala.loadCache();
//    } else {
//      // refresh user's staking info if network is kusama or polkadot
//      store.staking.clearState();
//      store.staking.loadAccountCache();
//      if (fetchData) {
//        webApi.staking.fetchAccountStaking();
//      }
//    }
//  }
//
//  Future<void> fetchAccountsBonded(List<String> pubKeys) async {
//    if (pubKeys.length > 0) {
//      List res = await apiRoot.evalJavascript(
//          'account.queryAccountsBonded(${jsonEncode(pubKeys)})');
//      store.account.setAccountsBonded(res);
//    }
//  }
//
//  Future<Map> estimateTxFees(Map txInfo, List params, {String rawParam}) async {
//    String param = rawParam != null ? rawParam : jsonEncode(params);
//    print(txInfo);
//    Map res = await apiRoot.evalJavascript(
//        'account.txFeeEstimate(${jsonEncode(txInfo)}, $param)',
//        allowRepeat: true);
//    return res;
//  }
//
//  Future<dynamic> _testSendTx() async {
//    Completer c = new Completer();
//    void onComplete(res) {
//      c.complete(res);
//    }
//
//    Timer(Duration(seconds: 6), () => onComplete({'hash': '0x79867'}));
//    return c.future;
//  }
//
//  Future<dynamic> sendTx(
//      Map txInfo, List params, String pageTile, String notificationTitle,
//      {String rawParam}) async {
//    String param = rawParam != null ? rawParam : jsonEncode(params);
//    String call = 'account.sendTx(${jsonEncode(txInfo)}, $param)';
////    print(call);
//    Map res = await apiRoot.evalJavascript(call, allowRepeat: true);
//
//    if (res['hash'] != null) {
//      String hash = res['hash'];
//      NotificationPlugin.showNotification(
//        int.parse(hash.substring(0, 6)),
//        notificationTitle,
//        '$pageTile - ${txInfo['module']}.${txInfo['call']}',
//      );
//    }
//    return res;
//  }
//
  /// Generate a set of new mnemonic.
  Future<String> generateAccount() async {
    final Map<String, dynamic> acc = await apiRoot.evalJavascript(
      'account.gen()',
      allowRepeat: true,
    );
    return acc['mnemonic'];
  }

  /// Import account from mnemonic/rawSeed/keystore.
  Future<Map<String, dynamic>> importAccount({
    @required String keyType,
    @required String key,
    @required String password,
    String cryptoType = 'sr25519',
    String derivePath = '',
  }) async {
    String code =
        'account.recover("$keyType", "$cryptoType", \'$key$derivePath\', "$password")';
    code = code.replaceAll(RegExp(r'\t|\n|\r'), '');
    final Map<String, dynamic> acc = await apiRoot.evalJavascript(
      code,
      allowRepeat: true,
    );
    return acc;
  }

//  Future<dynamic> checkAccountPassword(AccountData account, String pass) async {
//    String pubKey = account.pubKey;
//    print('checkpass: $pubKey, $pass');
//    return apiRoot.evalJavascript(
//      'account.checkPassword("$pubKey", "$pass")',
//      allowRepeat: true,
//    );
//  }
//
//  Future<List> fetchAccountsIndex(List addresses) async {
//    if (addresses == null || addresses.length == 0) {
//      return [];
//    }
//    addresses
//        .retainWhere((i) => !store.account.accountIndexMap.keys.contains(i));
//    if (addresses.length == 0) {
//      return [];
//    }
//
//    var res = await apiRoot.evalJavascript(
//      'account.getAccountIndex(${jsonEncode(addresses)})',
//      allowRepeat: true,
//    );
//    store.account.setAccountsIndex(res);
//    return res;
//  }
//
//  Future<List> getPubKeyIcons(List keys) async {
//    keys.retainWhere((i) => !store.account.pubKeyIconsMap.keys.contains(i));
//    if (keys.length == 0) {
//      return [];
//    }
//    List res = await apiRoot.evalJavascript(
//        'account.genPubKeyIcons(${jsonEncode(keys)})',
//        allowRepeat: true);
//    store.account.setPubKeyIconsMap(res);
//    return res;
//  }
//
//  Future<List> getAddressIcons(List addresses) async {
//    addresses
//        .retainWhere((i) => !store.account.addressIconsMap.keys.contains(i));
//    if (addresses.length == 0) {
//      return [];
//    }
//    List res = await apiRoot.evalJavascript(
//        'account.genIcons(${jsonEncode(addresses)})',
//        allowRepeat: true);
//    store.account.setAddressIconsMap(res);
//    return res;
//  }
//
//  Future<String> checkDerivePath(
//      String seed, String path, String pairType) async {
//    String res = await apiRoot.evalJavascript(
//      'account.checkDerivePath("$seed", "$path", "$pairType")',
//      allowRepeat: true,
//    );
//    return res;
//  }
//
//  Future<Map> queryRecoverable(String address) async {
////    address = "J4sW13h2HNerfxTzPGpLT66B3HVvuU32S6upxwSeFJQnAzg";
//    Map res = await apiRoot
//        .evalJavascript('api.query.recovery.recoverable("$address")');
//    if (res != null) {
//      res['address'] = address;
//    }
//    store.account.setAccountRecoveryInfo(res);
//
//    if (res != null && List.of(res['friends']).length > 0) {
//      getAddressIcons(res['friends']);
//    }
//    return res;
//  }
//
//  Future<List> queryRecoverableList(List<String> addresses) async {
//    List queries =
//        addresses.map((e) => 'api.query.recovery.recoverable("$e")').toList();
//    final List ls = await apiRoot.evalJavascript(
//      'Promise.all([${queries.join(',')}])',
//      allowRepeat: true,
//    );
//
//    List res = [];
//    ls.asMap().forEach((k, v) {
//      if (v != null) {
//        v['address'] = addresses[k];
//      }
//      res.add(v);
//    });
//
//    return res;
//  }
//
//  Future<List> queryActiveRecoveryAttempts(
//      String address, List<String> addressNew) async {
//    List queries = addressNew
//        .map((e) => 'api.query.recovery.activeRecoveries("$address", "$e")')
//        .toList();
//    final res = await apiRoot.evalJavascript(
//      'Promise.all([${queries.join(',')}])',
//      allowRepeat: true,
//    );
//    return res;
//  }
//
//  Future<List> queryActiveRecoveries(
//      List<String> addresses, String addressNew) async {
//    List queries = addresses
//        .map((e) => 'api.query.recovery.activeRecoveries("$e", "$addressNew")')
//        .toList();
//    final res = await apiRoot.evalJavascript(
//      'Promise.all([${queries.join(',')}])',
//      allowRepeat: true,
//    );
//    return res;
//  }
//
//  Future<List> queryRecoveryProxies(List<String> addresses) async {
//    List queries =
//        addresses.map((e) => 'api.query.recovery.proxy("$e")').toList();
//    final res = await apiRoot.evalJavascript(
//      'Promise.all([${queries.join(',')}])',
//      allowRepeat: true,
//    );
//    return res;
//  }
//
//  Future<Map> parseQrCode(String data) async {
//    final res = await apiRoot.evalJavascript('account.parseQrCode("$data")');
//    print('rawData: $data');
//    return res;
//  }
//
//  Future<Map> signAsync(String password) async {
//    final res = await apiRoot.evalJavascript('account.signAsync("$password")');
//    return res;
//  }
//
//  Future<Map> makeQrCode(Map txInfo, List params, {String rawParam}) async {
//    String param = rawParam != null ? rawParam : jsonEncode(params);
//    final Map res = await apiRoot.evalJavascript(
//      'account.makeTx(${jsonEncode(txInfo)}, $param)',
//      allowRepeat: true,
//    );
//    return res;
//  }
//
//  Future<Map> addSignatureAndSend(
//    String signed,
//    Map txInfo,
//    String pageTile,
//    String notificationTitle,
//  ) async {
//    final String address = store.account.currentAddress;
//    final Map res = await apiRoot.evalJavascript(
//      'account.addSignatureAndSend("$address", "$signed")',
//      allowRepeat: true,
//    );
//
//    if (res['hash'] != null) {
//      String hash = res['hash'];
//      NotificationPlugin.showNotification(
//        int.parse(hash.substring(0, 6)),
//        notificationTitle,
//        '$pageTile - ${txInfo['module']}.${txInfo['call']}',
//      );
//    }
//    return res;
//  }
//
//  Future<Map> signAsExtension(String password, Map args) async {
//    final String call = args['msgType'] == WalletExtensionSignPage.signTypeBytes
//        ? 'signBytesAsExtension'
//        : 'signTxAsExtension';
//    final res = await apiRoot.evalJavascript(
//      'account.$call("$password", ${jsonEncode(args['request'])})',
//      allowRepeat: true,
//    );
//    return res;
//  }
}