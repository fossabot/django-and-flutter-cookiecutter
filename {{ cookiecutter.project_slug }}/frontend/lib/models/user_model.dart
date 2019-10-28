import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Login loginFromJson(String str) {
  final jsonData = json.decode(str);
  return Login.fromJson(jsonData);
}

String loginToJson(Login data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Login {
  String email;
  String password;

  Login({
    this.email,
    this.password,
  });

  factory Login.fromJson(Map<String, dynamic> json) => new Login(
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
      };
}

PasswordReset passwordResetFromJson(String str) {
  final jsonData = json.decode(str);
  return PasswordReset.fromJson(jsonData);
}

String passwordResetToJson(PasswordReset data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class PasswordReset {
  String email;

  PasswordReset({
    this.email,
  });

  factory PasswordReset.fromJson(Map<String, dynamic> json) => new PasswordReset(
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
      };
}

PasswordResetConfirm passwordResetConfirmFromJson(String str) {
  final jsonData = json.decode(str);
  return PasswordResetConfirm.fromJson(jsonData);
}

String passwordResetConfirmToJson(PasswordResetConfirm data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class PasswordResetConfirm {
  String newPassword1;
  String newPassword2;
  String uid;
  String token;

  PasswordResetConfirm({
    this.newPassword1,
    this.newPassword2,
    this.uid,
    this.token,
  });

  factory PasswordResetConfirm.fromJson(Map<String, dynamic> json) => new PasswordResetConfirm(
        newPassword1: json["new_password1"],
        newPassword2: json["new_password2"],
        uid: json["uid"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "new_password1": newPassword1,
        "new_password2": newPassword2,
        "uid": uid,
        "token": token,
      };
}

Registration registrationFromJson(String str) {
  final jsonData = json.decode(str);
  return Registration.fromJson(jsonData);
}

String registrationToJson(Registration data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Registration {
  String email;
  String password1;
  String password2;
  String name;

  Registration({
    this.email,
    this.password1,
    this.password2,
    this.name,
  });

  factory Registration.fromJson(Map<String, dynamic> json) => new Registration(
        email: json["email"],
        password1: json["password1"],
        password2: json["password2"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "password1": password1,
        "password2": password2,
        "name": name,
      };
}

class UserModel extends Model {
  final storage = new FlutterSecureStorage();

  SharedPreferences prefs;

  String _token;

  String get token => _token;

  String _errMessage;

  String get errMessage => _errMessage;

  set errMessageNull(bool nullify) {
    if (nullify) {
      _errMessage = null;
    }
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  String baseUrl = 'https://yourbasedomain.com';
  String loginUrl = '/auth/login/';
  String logoutUrl = '/auth/logout/';
  String passwordResetUrl = '/auth/password/reset/';
  String registerUrl = '/auth/registration/';

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    initUser();
  }

  initUser() async {
    startLoading();
    prefs = await SharedPreferences.getInstance();
    _token = await storage.read(key: 'token');
    if (_token != null) {
      _isSignedIn = true;
    }
    stopLoading();
  }

  String email() {
    return prefs.getString('email');
  }

  String name() {
    return prefs.getString('name');
  }

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void caughtExc(exc) {
    print(exc);
    _errMessage = exc.toString();
    if (exc is PlatformException) {
      _errMessage = exc.message;
    }
    notifyListeners();
  }

  Map<String, String> authHeader() {
    return {'Authorization': 'Token $_token'};
  }

  Map<String, String> jsonHeader() {
    return {'Content-Type': 'application/json'};
  }

  sendLogout() async {
    final client = http.Client();
    try {
      await retry(
        () async {
          await client
              .post('$baseUrl$logoutUrl', headers: {}..addAll(authHeader())..addAll(jsonHeader()))
              .timeout(Duration(seconds: 5));
        },
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
    } finally {
      client.close();
    }
  }

  signout() async {
    startLoading();
    await sendLogout();
    await storage.delete(key: 'token');
    _token = null;
    _isSignedIn = false;
    notifyListeners();
    stopLoading();
  }

  loginWithEmailAndPassword(String email, String password) async {
    startLoading();
    final client = http.Client();
    final login = new Login(email: email, password: password);
    try {
      final resp = await retry(
        () async {
          final response = await client
              .post('$baseUrl$loginUrl', body: loginToJson(login), headers: {}..addAll(jsonHeader()))
              .timeout(Duration(seconds: 5));
          return response;
        },
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      if (resp.statusCode == 200) {
        var jsonResponse = json.decode(resp.body);
        _token = jsonResponse['key'];
        await storage.write(key: 'token', value: _token);
        _isSignedIn = true;
        prefs.setString('email', email);
      } else {
        caughtExc(resp.body.toString());
        signout();
      }
    } catch (err) {
      caughtExc(err);
      signout();
    } finally {
      client.close();
      stopLoading();
      notifyListeners();
    }
  }

  createUserWithEmailAndPassword(String name, String email, String password) async {
    startLoading();
    final client = http.Client();
    final registration = new Registration(email: email, password1: password, password2: password, name: name);
    try {
      final resp = await retry(
        () async {
          final response = await client
              .post('$baseUrl$registerUrl', body: registrationToJson(registration), headers: {}..addAll(jsonHeader()))
              .timeout(Duration(seconds: 5));
          return response;
        },
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      if (resp.statusCode == 201) {
        var jsonResponse = json.decode(resp.body);
        _token = jsonResponse['key'];
        await storage.write(key: 'token', value: _token);
        _isSignedIn = true;
        prefs.setString('email', email);
        prefs.setString('name', name);
      } else {
        caughtExc(resp.body.toString());
        signout();
      }
    } catch (err) {
      caughtExc(err);
      signout();
    } finally {
      client.close();
      stopLoading();
      notifyListeners();
    }
  }

  sendPasswordResetEmail(String email) async {
    final client = http.Client();
    final passwordReset = new PasswordReset(email: email);
    try {
      await retry(
        () async {
          final response = await client
              .post('$baseUrl$passwordResetUrl',
                  body: passwordResetToJson(passwordReset), headers: {}..addAll(jsonHeader()))
              .timeout(Duration(seconds: 5));
          return response;
        },
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
    } catch (err) {
      caughtExc(err);
    } finally {
      client.close();
    }
  }
}
