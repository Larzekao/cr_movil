import 'package:equatable/equatable.dart';
import '../../domain/entities/help_topic_entity.dart';

abstract class HelpState extends Equatable {
  const HelpState();

  @override
  List<Object?> get props => [];
}

class HelpInitial extends HelpState {}

class HelpLoading extends HelpState {}

class HelpTopicsLoaded extends HelpState {
  final List<HelpTopicEntity> topics;
  final String? userRole;

  const HelpTopicsLoaded({required this.topics, this.userRole});

  @override
  List<Object?> get props => [topics, userRole];
}

class HelpSearchResults extends HelpState {
  final List<HelpTopicEntity> topics;
  final String query;
  final String? userRole;

  const HelpSearchResults({
    required this.topics,
    required this.query,
    this.userRole,
  });

  @override
  List<Object?> get props => [topics, query, userRole];
}

class HelpCategoryFiltered extends HelpState {
  final List<HelpTopicEntity> topics;
  final String category;
  final String? userRole;

  const HelpCategoryFiltered({
    required this.topics,
    required this.category,
    this.userRole,
  });

  @override
  List<Object?> get props => [topics, category, userRole];
}

class HelpTopicSelected extends HelpState {
  final HelpTopicEntity topic;

  const HelpTopicSelected({required this.topic});

  @override
  List<Object?> get props => [topic];
}

class HelpError extends HelpState {
  final String message;

  const HelpError({required this.message});

  @override
  List<Object?> get props => [message];
}
