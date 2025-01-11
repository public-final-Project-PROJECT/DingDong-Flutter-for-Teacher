
import 'package:dio/dio.dart';

class AlertModel{

  Future<void> alertRegist() async{
    final dio = Dio();
    try{
      final response = await dio.post(
          "http://112.221.66.174:3013/api/alert/");

    }catch (e){
      print(e);

    }
  }

}