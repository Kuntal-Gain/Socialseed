class TestModel {
  final String name;
  final int age;

  TestModel({required this.name, required this.age});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(name: json['name'], age: json['age']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age};
  }
}
