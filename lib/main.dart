import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_background.dart';
import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_theme.dart';

const String kAppTitle = 'Nest Mojo - Flat';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.initialThemeMode = ThemeMode.light,
  });

  final ThemeMode initialThemeMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void _setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) {
      return;
    }
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      debugShowCheckedModeBanner: false,
      theme: NestTheme.light(),
      darkTheme: NestTheme.dark(),
      themeMode: _themeMode,
      home: MyHomePage(
        title: kAppTitle,
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    this.themeMode = ThemeMode.light,
    this.onThemeModeChanged,
  });

  final String title;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _toggleTheme() {
    final ThemeMode nextMode = widget.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    widget.onThemeModeChanged?.call(nextMode);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final NestColors nest = context.nest;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: _toggleTheme,
            tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              NestPatternBackground(
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: nest.brandLogoSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'N',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: nest.brandLogoInk,
                              ),
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: <InlineSpan>[
                                TextSpan(
                                  text: 'Nest Mojo ',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: nest.brandText,
                                  ),
                                ),
                                TextSpan(
                                  text: '- Flat',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: nest.brandLogoSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Run your home,',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: nest.brandText,
                        ),
                      ),
                      Text(
                        'together.',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: nest.brandLogoSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'House help, groceries, chores, meals and spends — shared between the phones in your home.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: nest.brandTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Appearance',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Switch between warm cream paper light mode and near-black green dark mode.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: nest.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: const <ButtonSegment<ThemeMode>>[
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode_outlined),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode_outlined),
                          ),
                        ],
                        selected: <ThemeMode>{
                          widget.themeMode == ThemeMode.dark
                              ? ThemeMode.dark
                              : ThemeMode.light,
                        },
                        onSelectionChanged: (Set<ThemeMode> selection) {
                          if (selection.isNotEmpty) {
                            widget.onThemeModeChanged?.call(selection.first);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _ColorBadge(
                            label: 'Primary',
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                          _ColorBadge(
                            label: 'Amber Accent',
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                          ),
                          _ColorBadge(
                            label: 'Danger',
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'You have pushed the button this many times:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: nest.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_counter',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ColorBadge extends StatelessWidget {
  const _ColorBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
        ),
      ),
    );
  }
}
