import 'dart:convert';

import 'package:githo/models/used_classes/step.dart';

List<String> jsonToStringList(String json) {
  List<dynamic> dynamicList = jsonDecode(json);
  List<String> stringList = [];

  dynamicList.forEach((element) {
    stringList.add(element);
  });
  return stringList;
}

List<StepClass> jsonToStepList(String json) {
  List<dynamic> dynamicList = jsonDecode(json);
  List<StepClass> stepList = <StepClass>[];

  dynamicList.forEach((element) {
    stepList.add(element);
  });
  return stepList;
}
