import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../main.dart';
import '../services/cover_cache.dart';
import '../services/library_controller.dart';
import 'folder_picker_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _coverBytes = 0;

  @override
  void initState() {
    super.initState();
    _tailleCache();
  }

  Future<void> _tailleCache() async {
    final bytes = await CoverCache.sizeInBytes();
    if (mounted) setState(() => _coverBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: library,
      builder: (context, _) {
        final s = library.settings;

        return Scaffold(
          appBar: darkAppBar(title: const Text('Réglages')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              _carte(
                icone: Icons.folder_copy_outlined,
                titre: 'Dossiers surveillés',
                enfants: [
                  if (library.folders.isEmpty)
                    Text('Aucun dossier pour l\'instant.',
                        style:
                            TextStyle(color: Palette.muted, fontSize: 13)),
                  for (final f in library.folders)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading:
                          Icon(Icons.folder_outlined, color: Palette.kin),
                      title: Text(f,
                          style: TextStyle(
                              color: Palette.text, fontSize: 12.5)),
                      trailing: IconButton(
                        icon: Icon(Icons.close,
                            color: Palette.muted, size: 18),
                        onPressed: () => _confirmerRetrait(f),
                      ),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _ajouterDossier,
                    icon: const Icon(Icons.create_new_folder_outlined,
                        size: 18),
                    label: const Text('Ajouter un dossier'),
                  ),
                  _interrupteur(
                    valeur: s.scanOnStart,
                    onChanged: (v) =>
                        library.updateSettings((s) => s.scanOnStart = v),
                    titre: 'Scanner à chaque ouverture',
                    sous: 'Détecte les nouveaux morceaux. Les écoutes et les '
                        'favoris sont conservés.',
                  ),
                ],
              ),
              _carte(
                icone: Icons.image_outlined,
                titre: 'Pochettes',
                enfants: [
                  Text(
                    'Les pochettes intégrées aux fichiers sont extraites et '
                    'rangées à part, une par album. Une image posée dans le '
                    'dossier — cover, folder, front — sert de secours.',
                    style: TextStyle(
                        color: Palette.muted, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _coverBytes == 0
                        ? 'Cache vide.'
                        : '${(_coverBytes / 1000000).toStringAsFixed(1)} Mo de pochettes.',
                    style: TextStyle(color: Palette.kin, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final n = await CoverCache.clear();
                      for (final t in library.tracks) {
                        t.coverPath = null;
                      }
                      await library.save();
                      await _tailleCache();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('$n pochette(s) supprimée(s).')),
                      );
                    },
                    icon: const Icon(Icons.cleaning_services_outlined,
                        size: 18),
                    label: const Text('Vider le cache'),
                  ),
                ],
              ),
              _carte(
                icone: Icons.palette_outlined,
                titre: 'Apparence',
                enfants: [
                  for (final theme in appThemes)
                    _tuileTheme(theme, s.themeId),
                ],
              ),
              _carte(
                icone: Icons.save_outlined,
                titre: 'Sauvegarde',
                enfants: [
                  Text(
                    'Un fichier unique contient tes listes de lecture, tes '
                    'favoris et tes écoutes. Les fichiers audio ne sont pas '
                    'copiés.',
                    style: TextStyle(
                        color: Palette.muted, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _exporter,
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Exporter'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _importer,
                        icon: const Icon(Icons.restore, size: 18),
                        label: const Text('Restaurer'),
                      ),
                    ],
                  ),
                ],
              ),
              _zoneSensible(),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------ blocs

  Widget _carte({
    required IconData icone,
    required String titre,
    required List<Widget> enfants,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Palette.surface,
        border: Border.all(color: Palette.line),
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 15, color: Palette.shu),
              const SizedBox(width: 8),
              Icon(icone, size: 17, color: Palette.kin),
              const SizedBox(width: 8),
              Text(titre,
                  style: TextStyle(
                      color: Palette.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...enfants,
        ],
      ),
    );
  }

  Widget _tuileTheme(AppTheme theme, String choisi) {
    final actif = theme.id == choisi;
    return GestureDetector(
      onTap: () async {
        await library.updateSettings((s) => s.themeId = theme.id);
        Palette.apply(theme.id);
        library.refresh();
        if (mounted) setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(
              color: actif ? theme.shu : theme.line, width: actif ? 2 : 1),
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        child: Row(
          children: [
            for (final c in [theme.shu, theme.kin, theme.sakura])
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.line),
                ),
              ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(theme.name,
                      style: TextStyle(
                          color: theme.text,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700)),
                  Text(theme.description,
                      style: TextStyle(
                          color: theme.muted, fontSize: 11, height: 1.3)),
                ],
              ),
            ),
            if (actif) Icon(Icons.check_circle, color: theme.shu, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _zoneSensible() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Palette.shu.withAlpha(20),
        border: Border.all(color: Palette.shu),
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 17, color: Palette.shu),
              const SizedBox(width: 8),
              Text('Actions sensibles',
                  style: TextStyle(
                      color: Palette.shu,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Efface la bibliothèque, les listes de lecture et les pochettes. '
            'Tes fichiers audio ne sont jamais touchés.',
            style: TextStyle(color: Palette.muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Palette.shu,
              side: BorderSide(color: Palette.shu),
            ),
            onPressed: _confirmerVidage,
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: const Text('Vider la bibliothèque'),
          ),
        ],
      ),
    );
  }

  Widget _interrupteur({
    required bool valeur,
    required ValueChanged<bool> onChanged,
    required String titre,
    required String sous,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: valeur,
      onChanged: onChanged,
      title: Text(titre,
          style: TextStyle(color: Palette.text, fontSize: 14)),
      subtitle:
          Text(sous, style: TextStyle(color: Palette.muted, fontSize: 12)),
    );
  }

  // ------------------------------------------------------------------ actions

  Future<void> _ajouterDossier() async {
    final dir = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const FolderPickerScreen()),
    );
    if (dir == null) return;
    await library.addFolder(dir);
    await library.scan();
  }

  Future<void> _confirmerRetrait(String dossier) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Palette.surface,
        title: const Text('Retirer ce dossier ?'),
        content: Text(
            'Les morceaux de $dossier disparaîtront de la bibliothèque. '
            'Aucun fichier n\'est supprimé.',
            style: const TextStyle(height: 1.4)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Palette.shu),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (ok == true) await library.removeFolder(dossier);
  }

  Future<void> _confirmerVidage() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Palette.surface,
        title: const Text('Vider la bibliothèque ?'),
        content: const Text(
            'Morceaux, listes de lecture, favoris et écoutes seront effacés.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Palette.shu),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await library.clearLibrary();
      await _tailleCache();
    }
  }

  Future<void> _exporter() async {
    final dossier = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const FolderPickerScreen()),
    );
    if (dossier == null) return;
    try {
      final now = DateTime.now();
      String d(int v) => v.toString().padLeft(2, '0');
      final nom = 'music-organizer-${now.year}${d(now.month)}${d(now.day)}'
          '-${d(now.hour)}${d(now.minute)}.json';
      final fichier = File(p.join(dossier, nom));
      await fichier.writeAsString(
          const JsonEncoder.withIndent('  ').convert(library.snapshot()),
          flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sauvegarde écrite : ${fichier.path}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Écriture impossible dans ce dossier.')),
      );
    }
  }

  Future<void> _importer() async {
    final fichier = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const FolderPickerScreen(pickExtension: '.json'),
      ),
    );
    if (fichier == null) return;
    final n = await library.importFrom(fichier);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(n < 0
            ? 'Fichier de sauvegarde illisible.'
            : '$n morceau(x) restauré(s).'),
      ),
    );
  }
}
