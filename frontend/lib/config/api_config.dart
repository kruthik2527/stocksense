class ApiConfig {
  // Change this to your backend URL.
  // Android emulator -> use 10.0.2.2 instead of localhost
  // iOS simulator / physical device on same network -> use your machine's LAN IP
  static const String baseUrl = 'http://10.78.207.127:5000/api';

  static const String auth = '$baseUrl/auth';
  static const String products = '$baseUrl/products';
  static const String warehouses = '$baseUrl/warehouses';
  static const String stockMoves = '$baseUrl/stock-moves';
  static const String dashboard = '$baseUrl/dashboard';
}