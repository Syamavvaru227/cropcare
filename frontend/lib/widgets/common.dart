import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../l10n/strings.dart';

class Brand extends StatelessWidget {
  final bool light;
  const Brand({super.key, this.light = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: light ? ivory : forest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.crop_free_rounded,
              size: 32,
              color: light ? forest : ivory,
            ),
            Icon(Icons.eco_rounded, size: 22, color: light ? forest : ivory),
          ],
        ),
      ),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          'CropCare',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -.8,
            color: light ? ivory : forest,
          ),
        ),
      ),
    ],
  );
}

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1080),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          MediaQuery.sizeOf(context).width > 700 ? 36 : 22,
          20,
          MediaQuery.sizeOf(context).width > 700 ? 36 : 22,
          32,
        ),
        children: children,
      ),
    ),
  );
}

class Heading extends StatelessWidget {
  final String title;
  final String? subtitle;
  const Heading(this.title, {super.key, this.subtitle});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(subtitle!, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ],
    ),
  );
}

class Notice extends StatelessWidget {
  final String text;
  final bool warning;
  const Notice(this.text, {super.key, this.warning = false});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: warning ? const Color(0xFFF4E7C7) : sage,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(warning ? Icons.info_outline : Icons.spa_outlined, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

void toast(BuildContext context, String key) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(context.tr(key))));
Future<bool> confirm(BuildContext context, String key) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(c.tr(key)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(c.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(c.tr('delete')),
          ),
        ],
      ),
    ) ??
    false;
Widget section(BuildContext context, String title, {VoidCallback? action}) =>
    Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.tr(title),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (action != null)
            TextButton(onPressed: action, child: Text(context.tr('viewAll'))),
        ],
      ),
    );
