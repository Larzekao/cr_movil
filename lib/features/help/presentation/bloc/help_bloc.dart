import 'package:flutter_bloc/flutter_bloc.dart';
import 'help_event.dart';
import 'help_state.dart';
import '../../data/datasources/help_local_datasource.dart';

class HelpBloc extends Bloc<HelpEvent, HelpState> {
  final HelpLocalDataSource _dataSource;

  HelpBloc({HelpLocalDataSource? dataSource})
      : _dataSource = dataSource ?? HelpLocalDataSource(),
        super(HelpInitial()) {
    on<LoadHelpTopics>(_onLoadHelpTopics);
    on<SearchHelpTopics>(_onSearchHelpTopics);
    on<FilterHelpByCategory>(_onFilterByCategory);
    on<SelectHelpTopic>(_onSelectTopic);
    on<ClearHelpSearch>(_onClearSearch);
  }

  void _onLoadHelpTopics(LoadHelpTopics event, Emitter<HelpState> emit) {
    try {
      final topics = _dataSource.getHelpTopicsByRole(event.userRole);
      emit(HelpTopicsLoaded(topics: topics, userRole: event.userRole));
    } catch (e) {
      emit(HelpError(message: 'Error al cargar temas de ayuda'));
    }
  }

  void _onSearchHelpTopics(SearchHelpTopics event, Emitter<HelpState> emit) {
    try {
      if (event.query.isEmpty) {
        final topics = _dataSource.getHelpTopicsByRole(event.userRole);
        emit(HelpTopicsLoaded(topics: topics, userRole: event.userRole));
      } else {
        final topics = _dataSource.searchHelpTopics(event.query, event.userRole);
        emit(HelpSearchResults(
          topics: topics,
          query: event.query,
          userRole: event.userRole,
        ));
      }
    } catch (e) {
      emit(HelpError(message: 'Error al buscar temas'));
    }
  }

  void _onFilterByCategory(FilterHelpByCategory event, Emitter<HelpState> emit) {
    try {
      final topics = _dataSource.getTopicsByCategory(event.category, event.userRole);
      emit(HelpCategoryFiltered(
        topics: topics,
        category: event.category,
        userRole: event.userRole,
      ));
    } catch (e) {
      emit(HelpError(message: 'Error al filtrar por categoría'));
    }
  }

  void _onSelectTopic(SelectHelpTopic event, Emitter<HelpState> emit) {
    try {
      final topic = _dataSource.getTopicById(event.topicId);
      if (topic != null) {
        emit(HelpTopicSelected(topic: topic));
      } else {
        emit(HelpError(message: 'Tema no encontrado'));
      }
    } catch (e) {
      emit(HelpError(message: 'Error al cargar el tema'));
    }
  }

  void _onClearSearch(ClearHelpSearch event, Emitter<HelpState> emit) {
    try {
      final topics = _dataSource.getHelpTopicsByRole(event.userRole);
      emit(HelpTopicsLoaded(topics: topics, userRole: event.userRole));
    } catch (e) {
      emit(HelpError(message: 'Error al limpiar búsqueda'));
    }
  }
}
