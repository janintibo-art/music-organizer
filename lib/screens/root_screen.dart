import 'package:flutter/material.dart';

import '../main.dart';
import '../services/library_controller.dart';
import '../widgets/mini_player.dart';
import 'albums_screen.dart';
import 'artists_screen.dart';
import 'playlists_screen.dart';
import 'tracks_screen.dart';

/// Quatre onglets, et la barre de lecture toujours visible au-dessus.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    TracksScreen(),
    AlbumsScreen(),
    ArtistsScreen(),
    PlaylistsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: library,
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(index: _index, children: _pages),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MiniPlayer(),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Palette.line)),
                ),
                child: BottomNavigationBar(
                  currentIndex: _index,
                  onTap: (i) => setState(() => _index = i),
                  backgroundColor: Palette.ink,
                  selectedItemColor: Palette.shu,
                  unselectedItemColor: Palette.muted,
                  selectedFontSize: 11,
                  unselectedFontSize: 11,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.music_note_outlined),
                      activeIcon: Icon(Icons.music_note),
                      label: 'Morceaux',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.album_outlined),
                      activeIcon: Icon(Icons.album),
                      label: 'Albums',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person),
                      label: 'Artistes',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.queue_music_outlined),
                      activeIcon: Icon(Icons.queue_music),
                      label: 'Listes',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
