import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/help_bloc.dart';
import '../bloc/help_event.dart';
import '../bloc/help_state.dart';
import '../../domain/entities/help_topic_entity.dart';
import 'help_topic_detail_page.dart';

class HelpChatPage extends StatefulWidget {
  final String? userRole;

  const HelpChatPage({super.key, this.userRole});

  @override
  State<HelpChatPage> createState() => _HelpChatPageState();
}

class _HelpChatPageState extends State<HelpChatPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_animation),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Search bar
            _buildSearchBar(),
            // Content
            Expanded(
              child: BlocBuilder<HelpBloc, HelpState>(
                builder: (context, state) {
                  if (state is HelpLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is HelpError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(state.message),
                        ],
                      ),
                    );
                  }

                  if (state is HelpTopicsLoaded) {
                    return _buildTopicsList(state.topics);
                  }

                  if (state is HelpSearchResults) {
                    return _buildSearchResults(state.topics, state.query);
                  }

                  if (state is HelpCategoryFiltered) {
                    return _buildCategoryResults(state.topics, state.category);
                  }

                  return _buildInitialState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.support_agent, color: Colors.blue, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Asistente Virtual',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.userRole != null
                      ? 'Ayuda para ${widget.userRole}'
                      : 'Centro de Ayuda',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '¿En qué puedo ayudarte?',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<HelpBloc>().add(
                          ClearHelpSearch(userRole: widget.userRole),
                        );
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.length >= 2) {
            context.read<HelpBloc>().add(
                  SearchHelpTopics(query: value, userRole: widget.userRole),
                );
          } else if (value.isEmpty) {
            context.read<HelpBloc>().add(
                  ClearHelpSearch(userRole: widget.userRole),
                );
          }
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '¡Hola! 👋',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Estoy aquí para ayudarte a usar CliniDocs. ¿Qué necesitas saber?',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        _buildQuickActions(),
        const SizedBox(height: 24),
        _buildCategoriesGrid(),
      ],
    );
  }

  Widget _buildQuickActions() {
    final quickActions = [
      {
        'icon': Icons.description,
        'title': 'Crear Historia Clínica',
        'topicId': 'create_medical_record',
      },
      {
        'icon': Icons.person_add,
        'title': 'Registrar Paciente',
        'topicId': 'register_patient',
      },
      {
        'icon': Icons.analytics,
        'title': 'Usar IA',
        'topicId': 'diabetes_prediction',
      },
      {
        'icon': Icons.security,
        'title': 'Ver mis Permisos',
        'topicId': 'role_permissions',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickActions.map((action) {
            return InkWell(
              onTap: () => _openTopicDetail(action['topicId'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(action['icon'] as IconData, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      action['title'] as String,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {
        'name': HelpCategory.medicalRecords,
        'icon': Icons.medical_information,
        'color': Colors.red,
      },
      {
        'name': HelpCategory.forms,
        'icon': Icons.description,
        'color': Colors.orange,
      },
      {
        'name': HelpCategory.ai,
        'icon': Icons.psychology,
        'color': Colors.purple,
      },
      {
        'name': HelpCategory.permissions,
        'icon': Icons.security,
        'color': Colors.green,
      },
      {
        'name': HelpCategory.patients,
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'name': HelpCategory.users,
        'icon': Icons.manage_accounts,
        'color': Colors.indigo,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorías',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () {
                context.read<HelpBloc>().add(
                      FilterHelpByCategory(
                        category: category['name'] as String,
                        userRole: widget.userRole,
                      ),
                    );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (category['color'] as Color).withOpacity(0.7),
                      (category['color'] as Color),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopicsList(List<HelpTopicEntity> topics) {
    if (topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay temas disponibles para tu rol',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQuickActions(),
        const SizedBox(height: 24),
        const Text(
          'Todos los Temas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...topics.map((topic) => _buildTopicCard(topic)),
      ],
    );
  }

  Widget _buildSearchResults(List<HelpTopicEntity> topics, String query) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Icon(Icons.search, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Resultados para "$query"',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${topics.length} ${topics.length == 1 ? 'resultado' : 'resultados'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (topics.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No se encontraron resultados',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Intenta con otras palabras clave',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          )
        else
          ...topics.map((topic) => _buildTopicCard(topic)),
      ],
    );
  }

  Widget _buildCategoryResults(List<HelpTopicEntity> topics, String category) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.read<HelpBloc>().add(
                      LoadHelpTopics(userRole: widget.userRole),
                    );
              },
            ),
            Expanded(
              child: Text(
                category,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (topics.isEmpty)
          Center(
            child: Text(
              'No hay temas en esta categoría',
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          ...topics.map((topic) => _buildTopicCard(topic)),
      ],
    );
  }

  Widget _buildTopicCard(HelpTopicEntity topic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openTopicDetail(topic.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(topic.category),
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: topic.tags.take(2).map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.grey[200],
                          labelStyle: const TextStyle(fontSize: 11),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _openTopicDetail(String topicId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpTopicDetailPage(topicId: topicId),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case HelpCategory.medicalRecords:
        return Icons.medical_information;
      case HelpCategory.forms:
        return Icons.description;
      case HelpCategory.ai:
        return Icons.psychology;
      case HelpCategory.permissions:
        return Icons.security;
      case HelpCategory.patients:
        return Icons.people;
      case HelpCategory.users:
        return Icons.manage_accounts;
      case HelpCategory.system:
        return Icons.settings;
      case HelpCategory.generalUsage:
        return Icons.help;
      default:
        return Icons.info;
    }
  }
}
