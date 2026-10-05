import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/content_item.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/content_repository.dart';
import '../content/content_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.authRepository,
    required this.contentRepository,
    super.key,
  });

  final AuthRepository authRepository;
  final ContentRepository contentRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _signOut() async {
    try {
      await widget.authRepository.signOut();
    } on AuthException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Déconnexion impossible. Vérifiez votre connexion.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = ContentSection.values;
    final section = sections[_selectedIndex];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.title),
            Text(
              section.subtitle,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          for (final item in sections)
            ContentScreen(
              key: ValueKey(item),
              section: item,
              repository: widget.contentRepository,
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article_rounded),
            label: 'Articles',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Livres',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            label: 'Tâches',
          ),
        ],
      ),
    );
  }
}
