import 'package:equatable/equatable.dart';

class StorageInfo extends Equatable {
  final double totalSpaceGB;
  final double freeSpaceGB;
  final double appUsedSpaceGB;

  const StorageInfo({
    required this.totalSpaceGB,
    required this.freeSpaceGB,
    required this.appUsedSpaceGB,
  });

  double get usedPercentage => (totalSpaceGB - freeSpaceGB) / totalSpaceGB;
  double get appUsedPercentage => appUsedSpaceGB / totalSpaceGB;

  @override
  List<Object?> get props => [totalSpaceGB, freeSpaceGB, appUsedSpaceGB];
}
