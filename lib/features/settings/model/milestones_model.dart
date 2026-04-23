enum MilestoneType {
  followers,
  posts,
  likes,
  streak,
  custom,
}

class MilestoneModel {
  final String? id;
  final String? label;
  final String? description;
  final int? maxValue;
  final MilestoneType? type;

  const MilestoneModel({
    required this.id,
    required this.label,
    required this.description,
    required this.maxValue,
    required this.type,
  });

  /// 🔁 From JSON
  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: json['id'] ?? "",
      label: json['label'] ?? "",
      description: json['description'] ?? "",
      maxValue: json['maxValue'] is int
          ? json['maxValue']
          : int.tryParse(json['maxValue'].toString()) ?? 0,
      type: _mapStringToType(json['type'] ?? "custom"),
    );
  }

  /// 🔁 To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'description': description,
      'maxValue': maxValue,
      'type': type?.name,
    };
  }

  /// 🔄 CopyWith (very useful for state management)
  MilestoneModel copyWith({
    String? id,
    String? label,
    String? description,
    int? maxValue,
    MilestoneType? type,
  }) {
    return MilestoneModel(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      maxValue: maxValue ?? this.maxValue,
      type: type ?? this.type,
    );
  }

  /// 🧠 Enum Mapper
  static MilestoneType _mapStringToType(String value) {
    return MilestoneType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MilestoneType.custom,
    );
  }
}
