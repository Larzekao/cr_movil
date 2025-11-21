import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/help_bloc.dart';
import '../bloc/help_event.dart';
import '../pages/help_chat_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Botón flotante que abre el chatbot de ayuda
class HelpChatButton extends StatelessWidget {
  const HelpChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String? userRole;
        if (authState is Authenticated) {
          userRole = authState.user.role?.name;
        }

        return FloatingActionButton(
          heroTag: 'help_chat_button',
          onPressed: () {
            // Cargar temas de ayuda según el rol
            context.read<HelpBloc>().add(LoadHelpTopics(userRole: userRole));

            // Abrir el chat de ayuda
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => HelpChatPage(userRole: userRole),
            );
          },
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.help_outline,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

/// Versión mini del botón que se puede integrar en cualquier página
class HelpChatButtonMini extends StatelessWidget {
  final Alignment alignment;

  const HelpChatButtonMini({
    super.key,
    this.alignment = Alignment.bottomLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? 16 : null,
      top: alignment == Alignment.topLeft || alignment == Alignment.topRight ? 16 : null,
      left: alignment == Alignment.bottomLeft || alignment == Alignment.topLeft ? 16 : null,
      right: alignment == Alignment.bottomRight || alignment == Alignment.topRight ? 16 : null,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String? userRole;
          if (authState is Authenticated) {
            userRole = authState.user.role?.name;
          }

          return FloatingActionButton.small(
            heroTag: 'help_chat_button_mini',
            onPressed: () {
              context.read<HelpBloc>().add(LoadHelpTopics(userRole: userRole));

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => HelpChatPage(userRole: userRole),
              );
            },
            backgroundColor: Colors.blue.withOpacity(0.9),
            child: const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 20,
            ),
          );
        },
      ),
    );
  }
}
