import 'package:bmi_calculator/bmiCalculator.dart';
import 'package:bmi_calculator/controller/sqlite_db.dart';

import '../controller/request.dart';

class BMI{
  static const String SQLiteTable = "bmis";
  String name;
  double height = 0.0;
  double weight = 0.0;
  String gender;
  String bmi_status;
  BMI(this.name, this.height, this.weight, this.gender, this.bmi_status);

  BMI.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        height = double.parse(json['height'] as dynamic),
        weight = double.parse(json['weight'] as dynamic),
        gender = json['gender'] as String,
        bmi_status = json['bmi_status'] as String;

  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() =>
      {'name': name, 'height': height, 'weight': weight, 'gender': gender, 'bmi_status': bmi_status};

  Future<bool> save() async{
    await SQLiteDB().insert(SQLiteTable, toJson());
    RequestController req = RequestController(path: "/api/bmi.php");
    req.setBody(toJson());
    await req.post();
    if(req.status() == 200){
      return true;
    }
    else
      {
        if(await SQLiteDB().insert(SQLiteTable, toJson()) != 0){
          return true;
        }
        else
          return false;
      }
  }

  static Future<List<BMI>> loadAll() async {
    // API operation
    List<BMI> result = [];
    RequestController req = RequestController(path: "/api/bmi.php");
    await req.get();
    if (req.status() == 200 && req.result() != null) {
      for (var item in req.result()) {
        result.add(BMI.fromJson(item));
      }
    }
    else
      {
        List<Map<String, dynamic>> result = await SQLiteDB().queryAll(SQLiteTable);
        List<BMI> bmis = [];
        for(var item in result){
          result.add(BMI.fromJson(item) as Map<String, dynamic>);
        }
      }
    return result;
  }
}