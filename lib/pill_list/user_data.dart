class User {

  String name;
  String properties;
  String instruction;
  String warming;
  String storage;
  String size;

  
  User({this.name, this.properties, this.instruction, this.warming, this.storage, this.size});
  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      name: parsedJson["name"] as String,
      properties: parsedJson["properties"] as String,
      instruction: parsedJson["instruction"] as String,
      warming: parsedJson["warming"] as String,
      storage: parsedJson["storage"] as String,
      size: parsedJson["size"] as String,
    );
  }
}
