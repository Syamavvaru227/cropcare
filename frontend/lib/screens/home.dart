import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import 'setup.dart';
import 'library.dart';
import 'scanner.dart';

class HomeShell extends StatefulWidget {
  final AppState state;
  final VoidCallback onLogout;
  const HomeShell({super.key, required this.state, required this.onLogout});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  void scanner({bool gallery = false}) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ScannerScreen(state: widget.state, galleryFirst: gallery),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Brand(),
      actions: [
        TextButton(
          onPressed: () => widget.state.setLanguage(
            widget.state.language == 'en' ? 'te' : 'en',
          ),
          child: Text(widget.state.language == 'en' ? 'తెలుగు' : 'English'),
        ),
        IconButton(
          tooltip: context.tr('profile'),
          onPressed: () => setState(() => tab = 4),
          icon: const Icon(Icons.account_circle_outlined),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: switch (tab) {
      1 => LibraryScreen(state: widget.state),
      3 => HistoryScreen(state: widget.state),
      4 => ProfileScreen(state: widget.state, onLogout: widget.onLogout),
      _ => dashboard(context),
    },
    bottomNavigationBar: SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: ivory,
          border: Border(top: BorderSide(color: sage)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: List.generate(5, (i) {
            final icons = [
              Icons.home_outlined,
              Icons.menu_book_outlined,
              Icons.document_scanner_outlined,
              Icons.history,
              Icons.person_outline,
            ];
            final keys = ['home', 'diseases', 'scan', 'history', 'profile'];
            return Expanded(
              child: Semantics(
                selected: tab == i && i != 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (i == 2) {
                      scanner();
                    } else {
                      setState(() => tab = i);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 38,
                          decoration: BoxDecoration(
                            color: i == 2
                                ? forest
                                : tab == i
                                ? sage
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(icons[i], color: i == 2 ? ivory : forest),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(keys[i]),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: tab == i
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
  Widget dashboard(BuildContext context) => PageBody(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.state.name.isEmpty
                      ? context.tr('greeting')
                      : '${context.tr('greeting')} ${widget.state.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocationScreen(state: widget.state),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            widget.state.location.isEmpty
                                ? context.tr('notSet')
                                : widget.state.location,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.expand_more, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text(context.tr(widget.state.demo ? 'demo' : 'live')),
            side: BorderSide.none,
            backgroundColor: sage,
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: forest,
          borderRadius: BorderRadius.circular(28),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 650;
            final content = Padding(
              padding: EdgeInsets.all(wide ? 36 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('tagline').toUpperCase(),
                    style: const TextStyle(
                      color: sage,
                      fontSize: 12,
                      letterSpacing: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.tr('hero'),
                    style: TextStyle(
                      fontSize: wide ? 40 : 29,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      letterSpacing: -.9,
                      color: ivory,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.tr('heroBody'),
                    style: const TextStyle(color: sage, fontSize: 16),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: ivory,
                      foregroundColor: forest,
                    ),
                    onPressed: scanner,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: Text(context.tr('scanCrop')),
                  ),
                ],
              ),
            );
            return wide
                ? Row(
                    children: [
                      Expanded(flex: 6, child: content),
                      Expanded(
                        flex: 5,
                        child: Image.asset(
                          'assets/images/tomato.jpg',
                          height: 340,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/tomato.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: ColoredBox(color: forest.withValues(alpha: .84)),
                      ),
                      content,
                    ],
                  );
          },
        ),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: scanner,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(context.tr('camera')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => scanner(gallery: true),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(context.tr('gallery')),
            ),
          ),
        ],
      ),
      section(
        context,
        'yourCrops',
        action: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CropScreen(state: widget.state)),
        ),
      ),
      Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/tomato.jpg',
              width: 90,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('tomato'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 5),
                Text(
                  context.tr('available'),
                  style: const TextStyle(color: forest),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.tr('scanCrop'),
            onPressed: scanner,
            icon: const Icon(Icons.document_scanner_outlined),
          ),
        ],
      ),
      section(context, 'recent', action: () => setState(() => tab = 3)),
      if (widget.state.historyError)
        Notice(context.tr('offline'), warning: true)
      else if (widget.state.scans.isEmpty)
        EmptyHistory(onScan: scanner)
      else
        for (final s in widget.state.scans.take(2))
          ScanTile(state: widget.state, record: s),
      const SizedBox(height: 26),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: sage,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(64),
            bottomLeft: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.wb_sunny_outlined, color: forest),
            const SizedBox(height: 12),
            Text(
              context.tr('tip'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(context.tr('tipBody')),
            TextButton(
              onPressed: () => setState(() => tab = 1),
              child: Text(context.tr('diseases')),
            ),
          ],
        ),
      ),
    ],
  );
}

class CropScreen extends StatelessWidget {
  final AppState state;
  const CropScreen({super.key, required this.state});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.tr('allCrops'))),
    body: PageBody(
      children: [
        Heading(context.tr('yourCrops')),
        for (final crop in [
          'tomato',
          'chilli',
          'cotton',
          'paddy',
          'maize',
          'groundnut',
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              tileColor: crop == 'tomato' ? sage : Colors.white54,
              contentPadding: const EdgeInsets.all(18),
              leading: crop == 'tomato'
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/tomato.jpg',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.grass, size: 38, color: Color(0xFF896548)),
              title: Text(
                context.tr(crop),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(
                context.tr(crop == 'tomato' ? 'available' : 'soon'),
              ),
              trailing: Icon(
                crop == 'tomato'
                    ? Icons.document_scanner_outlined
                    : Icons.lock_outline,
              ),
              onTap: crop == 'tomato'
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScannerScreen(state: state),
                      ),
                    )
                  : null,
            ),
          ),
      ],
    ),
  );
}

class EmptyHistory extends StatelessWidget {
  final VoidCallback onScan;
  const EmptyHistory({super.key, required this.onScan});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFD3DDCB)),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        const Icon(Icons.eco_outlined, size: 36, color: forest),
        const SizedBox(height: 12),
        Text(
          context.tr('noScans'),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(context.tr('noScansBody'), textAlign: TextAlign.center),
        TextButton(onPressed: onScan, child: Text(context.tr('scanCrop'))),
      ],
    ),
  );
}

class ScanTile extends StatelessWidget {
  final AppState state;
  final ScanRecord record;
  final VoidCallback? onDelete;
  const ScanTile({
    super.key,
    required this.state,
    required this.record,
    this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(record.created.toLocal());
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(record.created.toLocal()));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            record.image,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          state.disease(record.diseaseId).name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '$date · $time\n${context.tr(record.demo ? 'demo' : 'live')} · ${(record.confidence * 100).round()}%',
        ),
        isThreeLine: true,
        trailing: onDelete == null
            ? const Icon(Icons.chevron_right)
            : IconButton(
                tooltip: context.tr('delete'),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiseaseScreen(
              state: state,
              disease: state.disease(record.diseaseId),
              result: record,
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  final AppState state;
  const HistoryScreen({super.key, required this.state});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String query = '', filter = 'all';
  @override
  Widget build(BuildContext context) {
    final rows = widget.state.scans
        .where(
          (s) =>
              widget.state
                  .disease(s.diseaseId)
                  .name
                  .toLowerCase()
                  .contains(query.toLowerCase()) &&
              (filter == 'all' ||
                  (filter == 'low' ? s.confidence < .6 : s.confidence >= .6)),
        )
        .toList();
    return PageBody(
      children: [
        Heading(context.tr('recent')),
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: InputDecoration(
            hintText: context.tr('search'),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['all', 'low']
              .map(
                (f) => ChoiceChip(
                  label: Text(context.tr(f)),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                ),
              )
              .toList(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: widget.state.refresh,
            icon: const Icon(Icons.refresh),
            label: Text(context.tr('refresh')),
          ),
        ),
        if (widget.state.historyError)
          Notice(context.tr('offline'), warning: true),
        if (rows.isEmpty)
          EmptyHistory(
            onScan: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScannerScreen(state: widget.state),
              ),
            ),
          ),
        for (final s in rows)
          ScanTile(
            state: widget.state,
            record: s,
            onDelete: () async {
              if (!await confirm(context, 'deleteQuestion')) {
                return;
              }
              try {
                await widget.state.repository.delete(s.id);
                await widget.state.refresh();
              } catch (_) {
                if (context.mounted) {
                  toast(context, 'error');
                }
              }
            },
          ),
      ],
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.state, required this.onLogout});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool switching = false;
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      Heading(context.tr('settings')),
      Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: sage,
            child: Icon(Icons.person_outline, color: forest, size: 38),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.state.name.isEmpty
                      ? context.tr('guestName')
                      : widget.state.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (widget.state.mobile.isNotEmpty) Text(widget.state.mobile),
                if (widget.state.email.isNotEmpty) Text(widget.state.email),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      if (!widget.state.signedIn) ...[
        TextFormField(
          initialValue: widget.state.name,
          decoration: InputDecoration(labelText: context.tr('name')),
          onChanged: widget.state.setName,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) =>
                  AuthScreen(state: widget.state, done: () => Navigator.pop(c)),
            ),
          ),
          child: Text(context.tr('login')),
        ),
      ],
      Notice('${widget.state.scans.length} ${context.tr('observations')}'),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.location_on_outlined),
        title: Text(context.tr('location')),
        subtitle: Text(
          widget.state.location.isEmpty
              ? context.tr('notSet')
              : widget.state.location,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LocationScreen(state: widget.state),
          ),
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.translate),
        title: Text(context.tr('language')),
        trailing: SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'en', label: Text('EN')),
            ButtonSegment(value: 'te', label: Text('తెలుగు')),
          ],
          selected: {widget.state.language},
          onSelectionChanged: (s) => widget.state.setLanguage(s.first),
        ),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(context.tr('live')),
        subtitle: Text(context.tr('liveRequires')),
        value: !widget.state.demo,
        onChanged: switching
            ? null
            : (v) async {
                setState(() => switching = true);
                try {
                  final ok = await widget.state.setLive(v);
                  if (!ok && context.mounted) {
                    toast(context, 'liveRequires');
                  }
                } catch (_) {
                  if (context.mounted) {
                    toast(context, 'offline');
                  }
                } finally {
                  if (mounted) {
                    setState(() => switching = false);
                  }
                }
              },
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.dns_outlined),
        title: Text(context.tr('server')),
        subtitle: Text(widget.state.api.base),
        onTap: () => editServer(context, widget.state),
      ),
      section(context, 'privacy'),
      Text(context.tr('privacyBody')),
      TextButton.icon(
        onPressed: () async {
          if (await confirm(context, 'clearQuestion')) {
            try {
              await widget.state.local.clear();
              await widget.state.refresh();
            } catch (_) {
              if (context.mounted) {
                toast(context, 'error');
              }
            }
          }
        },
        icon: const Icon(Icons.delete_outline),
        label: Text(context.tr('deleteAll')),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.help_outline),
        title: Text(context.tr('help')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpScreen()),
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.eco_outlined),
        title: Text(context.tr('about')),
        onTap: () => showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Brand(),
            content: Text(c.tr('aboutBody')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: Text(c.tr('continue')),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      OutlinedButton(
        onPressed: () async {
          try {
            await widget.state.logout();
          } catch (_) {
            /* Local credentials cleared even offline. */
          }
          if (mounted) {
            widget.onLogout();
          }
        },
        child: Text(context.tr('logout')),
      ),
    ],
  );
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.tr('help'))),
    body: PageBody(
      children: [
        Heading(context.tr('help')),
        for (final pair in [
          ('scanCrop', 'scanInstructions'),
          ('confidence', 'resultWarning'),
          ('low', 'uncertain'),
          ('guidance', 'expertBody'),
          ('privacy', 'privacyBody'),
          ('demo', 'demoNotice'),
        ])
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              context.tr(pair.$1),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  context.tr(pair.$2),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
      ],
    ),
  );
}
