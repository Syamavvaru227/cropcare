import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import 'scanner.dart';

class LibraryScreen extends StatefulWidget {
  final AppState state;
  const LibraryScreen({super.key, required this.state});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String search = '', category = 'all';
  @override
  Widget build(BuildContext context) {
    final filtered = widget.state.diseases
        .where(
          (d) =>
              (category == 'all' || d.category == category) &&
              '${d.name} ${d.scientific} ${d.symptoms(widget.state.language)}'
                  .toLowerCase()
                  .contains(search.toLowerCase()),
        )
        .toList();
    return PageBody(
      children: [
        Heading(context.tr('library'), subtitle: context.tr('libraryBody')),
        TextField(
          onChanged: (s) => setState(() => search = s),
          decoration: InputDecoration(
            hintText: context.tr('search'),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                    'all',
                    'Fungal',
                    'Bacterial',
                    'Viral',
                    'Pest',
                    'Healthy',
                    'Oomycete',
                  ]
                  .map(
                    (c) => ChoiceChip(
                      label: Text(context.tr(c)),
                      selected: category == c,
                      onSelected: (_) => setState(() => category = c),
                    ),
                  )
                  .toList(),
        ),
        Notice(context.tr('unverified')),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(context.tr('noResults')),
          ),
        for (final d in filtered)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white.withValues(alpha: .7),
              borderRadius: BorderRadius.circular(20),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 52,
                  height: 60,
                  decoration: BoxDecoration(
                    color: d.category == 'Healthy'
                        ? sage
                        : const Color(0xFFF1E4CF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    d.category == 'Healthy'
                        ? Icons.eco_outlined
                        : Icons.spa_outlined,
                    color: forest,
                  ),
                ),
                title: Text(
                  d.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text('${context.tr(d.category)} · ${d.scientific}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DiseaseScreen(state: widget.state, disease: d),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class DiseaseScreen extends StatelessWidget {
  final AppState state;
  final Disease disease;
  final ScanRecord? result;
  const DiseaseScreen({
    super.key,
    required this.state,
    required this.disease,
    this.result,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.tr(result == null ? 'diseases' : 'possible')),
    ),
    body: PageBody(
      children: [
        if (result != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.memory(
              result!.image,
              height: 260,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          if (result!.demo) Notice(context.tr('demoNotice'), warning: true),
          const SizedBox(height: 20),
        ],
        Text(
          context.tr('tomato').toUpperCase(),
          style: const TextStyle(
            letterSpacing: 2,
            color: forest,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Heading(disease.name, subtitle: disease.scientific),
        if (result != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr(result!.demo ? 'demoConfidence' : 'confidence'),
                ),
              ),
              Text(
                '${(result!.confidence * 100).round()}% · ${context.tr(result!.confidence >= .85
                    ? 'high'
                    : result!.confidence >= .6
                    ? 'medium'
                    : 'low')}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: result!.confidence,
              minHeight: 10,
              color: result!.confidence < .6 ? const Color(0xFF896548) : forest,
              backgroundColor: sage,
            ),
          ),
          Notice(
            context.tr(result!.confidence < .6 ? 'uncertain' : 'resultWarning'),
            warning: true,
          ),
          if (result!.confidence < .6)
            OutlinedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ScannerScreen(state: state)),
              ),
              child: Text(context.tr('retake')),
            ),
        ],
        section(context, 'symptoms'),
        Text(
          disease.symptoms(state.language),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        section(context, 'prevention'),
        Text(
          context.tr('careBody'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        section(context, 'guidance'),
        Text(
          context.tr('expertBody'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Notice(context.tr('unverified')),
        TextButton.icon(
          onPressed: () async {
            final ok = await launchUrl(
              Uri.parse(disease.data['source']),
              mode: LaunchMode.externalApplication,
            );
            if (!ok && context.mounted) {
              toast(context, 'offline');
            }
          },
          icon: const Icon(Icons.open_in_new),
          label: Text(context.tr('source')),
        ),
      ],
    ),
  );
}
