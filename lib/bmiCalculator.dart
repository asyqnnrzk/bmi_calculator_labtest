import 'dart:math';
import 'package:bmi_calculator/model/bmi.dart';
import 'package:bmi_calculator/controller/request.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CalculateBmi());
}

class CalculateBmi extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: bmi(),
    );
  }
}

class bmi extends StatefulWidget {

  @override
  State<bmi> createState() => _bmiState();
}

class _bmiState extends State<bmi> {

  final List<BMI> bmis = [];
  final TextEditingController nameEditingController = TextEditingController();
  final TextEditingController heightEditingController = TextEditingController();
  final TextEditingController weightEditingController = TextEditingController();
  double bmi = 0.0;
  gender? selectedGender;

  String _calculate(){

    String height = heightEditingController.text.trim();
    String weight = weightEditingController.text.trim();

    try {
      if(height.isNotEmpty && weight.isNotEmpty){
        double h = double.parse(height);
        double w = double.parse(weight);

        bmi = w / pow(h / 100, 2);
      }
      return bmi.toStringAsFixed(2);
    } catch (ex) {
      return 'Error';
    }
  }

  void _showMessage(){

    String msg;

    if (selectedGender == gender.male) {
      if (bmi < 18.5) {
        msg = 'Underweight. Careful during strong wind!';
      } else if (bmi >= 18.5 && bmi <= 24.9) {
        msg = 'That’s ideal! Please maintain';
      } else if (bmi >= 25.0 && bmi <= 29.9) {
        msg = 'Overweight! Work out please';
      } else {
        msg = 'Whoa Obese! Dangerous mate!';
      }

    } else {
      if (bmi < 16.0) {
        msg = 'Underweight. Careful during strong wind!';
      } else if (bmi >= 16.0 && bmi <= 22.0) {
        msg = 'That’s ideal! Please maintain';
      } else if (bmi >= 22.0 && bmi <= 27.0) {
        msg = 'Overweight! Work out please';
      } else {
        msg = 'Whoa Obese! Dangerous mate!';
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      )
    );
  }

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      RequestController req = RequestController(
          path: "/api/timezone/Asia/Kuala_Lumpur",
          server: "http://worldtimeapi.org"
      );
      req.get().then((value){
        dynamic res = req.result();
      });
      bmis.addAll(await BMI.loadAll());

      setState((){
        _calculate();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: nameEditingController,
                decoration: const InputDecoration(
                  labelText: 'Your Fullname',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: heightEditingController,
                decoration: const InputDecoration(
                  labelText: 'height in cm; 170',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: weightEditingController,
                decoration: const InputDecoration(
                  labelText: 'weight in KG',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.only(right: 320.0),
                child: Text('Your BMI: ${_calculate()}'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 320.0, top: 50.0),
              child: Text('BMI Value'),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Gender(),
            ),
            ElevatedButton(
              onPressed: (){
                //calculate BMI
                String calculatedBmi = _calculate();

                if(calculatedBmi != 'Error'){
                  setState(() {
                    bmi = double.parse(calculatedBmi);
                  });
                  _showMessage();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Yep. Error.'),
                    )
                  );
                }
              },
              child: const Text('Calculate BMI and Save')
            )
          ],
        ),
      ),
    );
  }
}

enum gender {male, female}

class Gender extends StatefulWidget {
  const Gender({super.key});

  @override
  State<Gender> createState() => _GenderState();
}

class _GenderState extends State<Gender> {
  gender? _gender = gender.male;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Male'),
          leading: Radio<gender>(
            value: gender.male,
            groupValue: _gender,
            onChanged: (gender? value){
              setState(() {
                _gender = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Female'),
          leading: Radio<gender>(
            value: gender.female,
            groupValue: _gender,
            onChanged: (gender? value){
              setState(() {
                _gender = value;
              });
            },
          ),
        )
      ],
    );
  }
}