import 'dart:convert';

List<String> jsonToList(String json) {
  List<dynamic> dynamicList = jsonDecode(json);
  List<String> stringList = [];

  dynamicList.forEach((element) {
    stringList.add(element);
  });
  return stringList;
}
