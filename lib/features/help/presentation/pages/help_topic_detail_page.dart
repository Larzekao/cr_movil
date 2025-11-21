import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/help_bloc.dart';
import '../bloc/help_event.dart';
import '../bloc/help_state.dart';
import '../../domain/entities/help_topic_entity.dart';

class HelpTopicDetailPage extends StatefulWidget {
  final String topicId;

  const HelpTopicDetailPage({super.key, required this.topicId});

  @override
  State<HelpTopicDetailPage> createState() => _HelpTopicDetailPageState();
}

class _HelpTopicDetailPageState extends State<HelpTopicDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<HelpBloc>().add(SelectHelpTopic(topicId: widget.topicId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía de Ayuda'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<HelpBloc, HelpState>(
        builder: (context, state) {
          if (state is HelpTopicSelected) {
            return _buildContent(state.topic);
          }

          if (state is HelpError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(HelpTopicEntity topic) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(topic.category),
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  topic.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBadge(topic.category, Colors.white, Colors.blue),
                    ...topic.tags.take(3).map(
                          (tag) => _buildBadge(tag, Colors.white70, Colors.transparent),
                        ),
                  ],
                ),
              ],
            ),
          ),

          // Pasos de la guía
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.list_alt, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Pasos a seguir (${topic.steps.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...topic.steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isLast = index == topic.steps.length - 1;
                  return _buildStepCard(step, index + 1, isLast);
                }),
              ],
            ),
          ),

          // Footer con información adicional
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      '¿Necesitas más ayuda?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Si aún tienes dudas, contacta a tu supervisor o al Administrador TI de tu institución.',
                  style: TextStyle(color: Colors.blue[800]),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Aquí podrías implementar un formulario de contacto
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Función de contacto en desarrollo'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.contact_support),
                        label: const Text('Contactar Soporte'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: BorderSide(color: Colors.blue[300]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStepCard(HelpStepEntity step, int stepNumber, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número del paso con línea
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue, Colors.blue.withOpacity(0.3)],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Contenido del paso
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (step.iconName != null) ...[
                          Icon(
                            _getIconFromName(step.iconName!),
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'person_search':
        return Icons.person_search;
      case 'person':
        return Icons.person;
      case 'add':
        return Icons.add;
      case 'edit':
        return Icons.edit;
      case 'save':
        return Icons.save;
      case 'search':
        return Icons.search;
      case 'history':
        return Icons.history;
      case 'visibility':
        return Icons.visibility;
      case 'description':
        return Icons.description;
      case 'list':
        return Icons.list;
      case 'draw':
        return Icons.draw;
      case 'upload':
        return Icons.upload;
      case 'auto_fix_high':
        return Icons.auto_fix_high;
      case 'hourglass_empty':
        return Icons.hourglass_empty;
      case 'compare':
        return Icons.compare;
      case 'analytics':
        return Icons.analytics;
      case 'check':
        return Icons.check;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'assessment':
        return Icons.assessment;
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;
      case 'settings':
        return Icons.settings;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'medical_services':
        return Icons.medical_services;
      case 'badge':
        return Icons.badge;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'contact_mail':
        return Icons.contact_mail;
      case 'pending':
        return Icons.pending;
      case 'check_circle':
        return Icons.check_circle;
      case 'people':
        return Icons.people;
      case 'person_add':
        return Icons.person_add;
      case 'phone':
        return Icons.phone;
      case 'filter_alt':
        return Icons.filter_alt;
      case 'tune':
        return Icons.tune;
      case 'touch_app':
        return Icons.touch_app;
      case 'manage_accounts':
        return Icons.manage_accounts;
      case 'assignment_ind':
        return Icons.assignment_ind;
      case 'password':
        return Icons.password;
      case 'send':
        return Icons.send;
      case 'add_box':
        return Icons.add_box;
      case 'checklist':
        return Icons.checklist;
      case 'security':
        return Icons.security;
      case 'business':
        return Icons.business;
      case 'apps':
        return Icons.apps;
      case 'link':
        return Icons.link;
      case 'menu':
        return Icons.menu;
      case 'navigation':
        return Icons.navigation;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'account_circle':
        return Icons.account_circle;
      case 'notifications':
        return Icons.notifications;
      case 'info':
        return Icons.info;
      case 'mark_email_read':
        return Icons.mark_email_read;
      default:
        return Icons.circle;
    }
  }
}
