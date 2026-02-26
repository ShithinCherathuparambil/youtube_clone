import 'package:equatable/equatable.dart';

class VideoCategoryModel extends Equatable {
  const VideoCategoryModel({
    required this.id,
    required this.title,
    required this.assignable,
  });

  factory VideoCategoryModel.fromMap(Map<String, dynamic> map) {
    return VideoCategoryModel(
      id: map['id'] as String? ?? '',
      title: map['snippet']?['title'] as String? ?? '',
      assignable: map['snippet']?['assignable'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final bool assignable;

  @override
  List<Object?> get props => [id, title, assignable];
}
