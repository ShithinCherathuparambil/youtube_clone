import 'package:equatable/equatable.dart';

class VideoCategory extends Equatable {
  const VideoCategory({
    required this.id,
    required this.title,
    required this.assignable,
  });

  final String id;
  final String title;
  final bool assignable;

  @override
  List<Object?> get props => [id, title, assignable];
}
