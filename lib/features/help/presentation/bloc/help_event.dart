import 'package:equatable/equatable.dart';

abstract class HelpEvent extends Equatable {
  const HelpEvent();

  @override
  List<Object?> get props => [];
}

class LoadHelpTopics extends HelpEvent {
  final String? userRole;

  const LoadHelpTopics({this.userRole});

  @override
  List<Object?> get props => [userRole];
}

class SearchHelpTopics extends HelpEvent {
  final String query;
  final String? userRole;

  const SearchHelpTopics({required this.query, this.userRole});

  @override
  List<Object?> get props => [query, userRole];
}

class FilterHelpByCategory extends HelpEvent {
  final String category;
  final String? userRole;

  const FilterHelpByCategory({required this.category, this.userRole});

  @override
  List<Object?> get props => [category, userRole];
}

class SelectHelpTopic extends HelpEvent {
  final String topicId;

  const SelectHelpTopic({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}

class ClearHelpSearch extends HelpEvent {
  final String? userRole;

  const ClearHelpSearch({this.userRole});

  @override
  List<Object?> get props => [userRole];
}
