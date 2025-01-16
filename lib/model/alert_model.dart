import 'package:dio/dio.dart';

class AlertModel {
  Future<void> alertRegister() async {
    final dio = Dio();
    try {
      await dio.post("http://112.221.66.174:3013/api/alert/");
    } catch (e) {
      Exception (e);
    }
  }
}
