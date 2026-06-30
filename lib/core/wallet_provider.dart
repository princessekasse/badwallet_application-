import 'package:flutter/material';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum WalletState { loading, loaded, error }

class WalletProvider extends ChangeNotifier {
  final String baseUrl = "http://10.0.2.2:8080";
  final _storage = const FlutterSecureStorage(); 
  
  WalletState _state = WalletState.loading;
  WalletState get state => _state;
  
  String _balance = "0";
  String get balance => _balance;
  
  List<dynamic> _transactions = [];
  List<dynamic> get transactions => _transactions;
  
  List<dynamic> _unpaidBills = [];
  List<dynamic> get unpaidBills => _unpaidBills;
  
  String _currentPhone = "";
  String get currentPhone => _currentPhone;
  
  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  Future<bool> login(String phone) async {
    _state = WalletState.loading;
    _errorMessage = "";
    notifyListeners();
    try {
      await _storage.write(key: "phone", value: phone);
      _currentPhone = phone;
      await fetchAllData(phone);
      return true;
    } catch (e) {
      _state = WalletState.error;
      _errorMessage = "Erreur de connexion au serveur.";
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchAllData(String phone) async {
    _state = WalletState.loading;
    notifyListeners();
    try {
      await fetchBalance(phone);
      await fetchTransactions(phone);
      await fetchUnpaidBills();
      _state = WalletState.loaded;
    } catch (e) {
      _state = WalletState.error;
      _errorMessage = "Impossible de récupérer les informations de votre compte.";
    }
    notifyListeners();
  }

  Future<void> fetchBalance(String phone) async {
    final response = await http.get(Uri.parse('$baseUrl/wallets/$phone/balance'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _balance = data['balance'].toString();
    } else {
      throw Exception();
    }
  }

  Future<void> fetchTransactions(String phone) async {
    final response = await http.get(Uri.parse('$baseUrl/wallets/$phone/transactions'));
    if (response.statusCode == 200) {
      _transactions = json.decode(response.body);
    } else {
      throw Exception();
    }
  }

  Future<void> fetchUnpaidBills() async {
    final response = await http.get(Uri.parse('$baseUrl/external/factures/$_currentPhone'));
    if (response.statusCode == 200) {
      _unpaidBills = json.decode(response.body);
    } else {
      _unpaidBills = [
        {"id": "1", "provider": "SENELEC", "amount": 28000, "checked": false},
        {"id": "2", "provider": "WOYAFAL", "amount": 15000, "checked": false},
        {"id": "3", "provider": "RAPIDO", "amount": 10000, "checked": false},
        {"id": "4", "provider": "ISM", "amount": 250000, "checked": false},
      ];
    }
  }

  Future<bool> makeTransfer(String recipient, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wallets/transfer'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "sender": _currentPhone,
          "recipient": recipient,
          "amount": amount
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchAllData(_currentPhone);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> payBills(List<String> billIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wallets/pay-factures'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "phone": _currentPhone,
          "billIds": billIds
        }),
      );
      if (response.statusCode == 200) {
        await fetchAllData(_currentPhone);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}