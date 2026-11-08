import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const GeometryCalculatorApp());
}

class GeometryCalculatorApp extends StatefulWidget {
  const GeometryCalculatorApp({super.key});

  @override
  State<GeometryCalculatorApp> createState() => _GeometryCalculatorAppState();
}

class CalculationHistory {
  final String shapeName;
  final List<ShapeResult> results;
  final DateTime createdAt;

  const CalculationHistory({
    required this.shapeName,
    required this.results,
    required this.createdAt,
  });
}

class _GeometryCalculatorAppState extends State<GeometryCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final List<CalculationHistory> _history = [];

  void _addHistory(String shapeName, List<ShapeResult> results) {
    setState(() {
      _history.insert(
        0,
        CalculationHistory(
          shapeName: shapeName,
          results: List<ShapeResult>.from(results),
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Geometri',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xfff7f8f4),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2c8d91)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xff101417),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff55c5c0),
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xff1a2225),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xff202a2d),
          border: OutlineInputBorder(),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xff151d20),
          indicatorColor: Color(0xff2e5557),
        ),
      ),
      home: _AppShell(
        history: _history,
        isDark: _themeMode == ThemeMode.dark,
        onThemeChanged: (isDark) => setState(
          () => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light,
        ),
        onCalculated: _addHistory,
      ),
    );
  }
}

class _AppShell extends StatefulWidget {
  final List<CalculationHistory> history;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final void Function(String, List<ShapeResult>) onCalculated;

  const _AppShell({
    required this.history,
    required this.isDark,
    required this.onThemeChanged,
    required this.onCalculated,
  });

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      CalculatorHomePage(onCalculated: widget.onCalculated),
      _HistoryPage(history: widget.history),
      _AboutPage(isDark: widget.isDark, onThemeChanged: widget.onThemeChanged),
    ];
    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Kalkulator',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            label: 'Tentang',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Konfigurasi setiap bangun: nama, ikon, daftar input, dan fungsi hitungnya.
// Menambah bangun baru cukup menambah satu entri di list `shapes` di bawah.
// ---------------------------------------------------------------------------

class FieldSpec {
  final String key;
  final String label;
  const FieldSpec(this.key, this.label);
}

class ShapeResult {
  final String label;
  final double value;
  final String unit;
  final String formula;
  const ShapeResult(this.label, this.value, this.unit, [this.formula = '']);
}

String _number(double value) =>
    value.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');

class ShapeSpec {
  final String name;
  final IconData icon;
  final String category; // "Bangun Datar" atau "Bangun Ruang"
  final List<FieldSpec> fields;
  final List<ShapeResult> Function(Map<String, double> v) calculate;

  const ShapeSpec({
    required this.name,
    required this.icon,
    required this.category,
    required this.fields,
    required this.calculate,
  });
}

final List<ShapeSpec> shapes = [
  ShapeSpec(
    name: 'Persegi',
    icon: Icons.crop_square,
    category: 'Bangun Datar',
    fields: const [FieldSpec('sisi', 'Panjang sisi (cm)')],
    calculate: (v) {
      final s = v['sisi']!;
      return [
        ShapeResult(
          'Luas',
          s * s,
          'cm\u00b2',
          'L = s × s = ${_number(s)} × ${_number(s)}',
        ),
        ShapeResult('Keliling', 4 * s, 'cm', 'K = 4 × s = 4 × ${_number(s)}'),
      ];
    },
  ),
  ShapeSpec(
    name: 'Persegi Panjang',
    icon: Icons.crop_5_4,
    category: 'Bangun Datar',
    fields: const [
      FieldSpec('panjang', 'Panjang (cm)'),
      FieldSpec('lebar', 'Lebar (cm)'),
    ],
    calculate: (v) {
      final p = v['panjang']!, l = v['lebar']!;
      return [
        ShapeResult(
          'Luas',
          p * l,
          'cm\u00b2',
          'L = p × l = ${_number(p)} × ${_number(l)}',
        ),
        ShapeResult(
          'Keliling',
          2 * (p + l),
          'cm',
          'K = 2 × (p + l) = 2 × (${_number(p)} + ${_number(l)})',
        ),
      ];
    },
  ),
  ShapeSpec(
    name: 'Segitiga',
    icon: Icons.change_history,
    category: 'Bangun Datar',
    fields: const [
      FieldSpec('alas', 'Alas (cm)'),
      FieldSpec('tinggi', 'Tinggi (cm)'),
      FieldSpec('sisiB', 'Sisi lain B (cm)'),
      FieldSpec('sisiC', 'Sisi lain C (cm)'),
    ],
    calculate: (v) {
      final alas = v['alas']!, tinggi = v['tinggi']!;
      final b = v['sisiB']!, c = v['sisiC']!;
      return [
        ShapeResult(
          'Luas',
          0.5 * alas * tinggi,
          'cm\u00b2',
          'L = ½ × a × t = ½ × ${_number(alas)} × ${_number(tinggi)}',
        ),
        ShapeResult(
          'Keliling',
          alas + b + c,
          'cm',
          'K = a + b + c = ${_number(alas)} + ${_number(b)} + ${_number(c)}',
        ),
      ];
    },
  ),
  ShapeSpec(
    name: 'Jajar Genjang',
    icon: Icons.polyline,
    category: 'Bangun Datar',
    fields: const [
      FieldSpec('alas', 'Alas (cm)'),
      FieldSpec('tinggi', 'Tinggi (cm)'),
      FieldSpec('sisiMiring', 'Sisi miring (cm)'),
    ],
    calculate: (v) {
      final a = v['alas']!, t = v['tinggi']!, m = v['sisiMiring']!;
      return [
        ShapeResult(
          'Luas',
          a * t,
          'cm\u00b2',
          'L = a × t = ${_number(a)} × ${_number(t)}',
        ),
        ShapeResult(
          'Keliling',
          2 * (a + m),
          'cm',
          'K = 2 × (a + m) = 2 × (${_number(a)} + ${_number(m)})',
        ),
      ];
    },
  ),
  ShapeSpec(
    name: 'Trapesium',
    icon: Icons.change_history_outlined,
    category: 'Bangun Datar',
    fields: const [
      FieldSpec('sisiAtas', 'Sisi sejajar atas (cm)'),
      FieldSpec('sisiBawah', 'Sisi sejajar bawah (cm)'),
      FieldSpec('tinggi', 'Tinggi (cm)'),
      FieldSpec('sisiC', 'Sisi lain C (cm)'),
      FieldSpec('sisiD', 'Sisi lain D (cm)'),
    ],
    calculate: (v) {
      final a = v['sisiAtas']!, b = v['sisiBawah']!, t = v['tinggi']!;
      final c = v['sisiC']!, d = v['sisiD']!;
      return [
        ShapeResult(
          'Luas',
          0.5 * (a + b) * t,
          'cm\u00b2',
          'L = ½ × (a + b) × t = ½ × (${_number(a)} + ${_number(b)}) × ${_number(t)}',
        ),
        ShapeResult(
          'Keliling',
          a + b + c + d,
          'cm',
          'K = a + b + c + d = ${_number(a)} + ${_number(b)} + ${_number(c)} + ${_number(d)}',
        ),
      ];
    },
  ),
  ShapeSpec(
    name: 'Belah Ketupat',
    icon: Icons.diamond_outlined,
    category: 'Bangun Datar',
    fields: const [
      FieldSpec('diagonal1', 'Diagonal 1 (cm)'),
      FieldSpec('diagonal2', 'Diagonal 2 (cm)'),
      FieldSpec('sisi', 'Sisi (cm)'),
    ],
    calculate: (v) {
      final d1 = v['diagonal1']!, d2 = v['diagonal2']!, s = v['sisi']!;
      return [
        ShapeResult(
          'Luas',
          0.5 * d1 * d2,
          'cm\u00b2',
          'L = ½ × d1 × d2 = ½ × ${_number(d1)} × ${_number(d2)}',
        ),
        ShapeResult('Keliling', 4 * s, 'cm', 'K = 4 × s = 4 × ${_number(s)}'),
      ];
    },
  ),
  ShapeSpec(
    name: 'Lingkaran',
    icon: Icons.circle_outlined,
    category: 'Bangun Datar',
    fields: const [FieldSpec('jariJari', 'Jari-jari (cm)')],
    calculate: (v) {
      final r = v['jariJari']!;
      return [
        ShapeResult(
          'Luas',
          pi * r * r,
          'cm\u00b2',
          'L = π × r × r = 3,14 × ${_number(r)} × ${_number(r)}',
        ),
        ShapeResult(
          'Keliling',
          2 * pi * r,
          'cm',
          'K = 2 × π × r = 2 × 3,14 × ${_number(r)}',
        ),
      ];
    },
  ),
  ShapeSpec(
    name: 'Kubus',
    icon: Icons.view_in_ar,
    category: 'Bangun Ruang',
    fields: const [FieldSpec('sisi', 'Panjang sisi (cm)')],
    calculate: (v) {
      final s = v['sisi']!;
      return [
        ShapeResult(
          'Volume',
          s * s * s,
          'cm\u00b3',
          'V = s × s × s = ${_number(s)} × ${_number(s)} × ${_number(s)}',
        ),
        ShapeResult(
          'Luas Permukaan',
          6 * s * s,
          'cm\u00b2',
          'LP = 6 × s × s = 6 × ${_number(s)} × ${_number(s)}',
        ),
      ];
    },
  ),
  ShapeSpec(
    name: 'Kerucut',
    icon: Icons.change_history,
    category: 'Bangun Ruang',
    fields: const [
      FieldSpec('jariJari', 'Jari-jari (cm)'),
      FieldSpec('tinggi', 'Tinggi (cm)'),
      FieldSpec('garisPelukis', 'Garis pelukis (cm)'),
    ],
    calculate: (v) {
      final r = v['jariJari']!, t = v['tinggi']!, s = v['garisPelukis']!;
      return [
        ShapeResult(
          'Volume',
          pi * r * r * t / 3,
          'cm\u00b3',
          'V = ⅓ × π × r² × t = ⅓ × 3,14 × ${_number(r)}² × ${_number(t)}',
        ),
        ShapeResult(
          'Luas Permukaan',
          pi * r * (r + s),
          'cm\u00b2',
          'LP = π × r × (r + s) = 3,14 × ${_number(r)} × (${_number(r)} + ${_number(s)})',
        ),
      ];
    },
  ),
  ShapeSpec(
    name: 'Limas',
    icon: Icons.change_history,
    category: 'Bangun Ruang',
    fields: const [
      FieldSpec('sisiAlas', 'Sisi alas persegi (cm)'),
      FieldSpec('tinggi', 'Tinggi limas (cm)'),
      FieldSpec('tinggiSisi', 'Tinggi sisi tegak (cm)'),
    ],
    calculate: (v) {
      final s = v['sisiAlas']!, t = v['tinggi']!, ts = v['tinggiSisi']!;
      return [
        ShapeResult(
          'Volume',
          s * s * t / 3,
          'cm\u00b3',
          'V = ⅓ × s² × t = ⅓ × ${_number(s)}² × ${_number(t)}',
        ),
        ShapeResult(
          'Luas Permukaan',
          s * s + 2 * s * ts,
          'cm\u00b2',
          'LP = s² + 2 × s × ts = ${_number(s)}² + 2 × ${_number(s)} × ${_number(ts)}',
        ),
      ];
    },
  ),
  ShapeSpec(
    name: 'Prisma',
    icon: Icons.view_in_ar,
    category: 'Bangun Ruang',
    fields: const [
      FieldSpec('alas', 'Alas segitiga (cm)'),
      FieldSpec('tinggiAlas', 'Tinggi segitiga (cm)'),
      FieldSpec('sisiB', 'Sisi segitiga B (cm)'),
      FieldSpec('sisiC', 'Sisi segitiga C (cm)'),
      FieldSpec('tinggiPrisma', 'Tinggi prisma (cm)'),
    ],
    calculate: (v) {
      final a = v['alas']!,
          ta = v['tinggiAlas']!,
          b = v['sisiB']!,
          c = v['sisiC']!,
          tp = v['tinggiPrisma']!;
      final luasAlas = 0.5 * a * ta;
      return [
        ShapeResult(
          'Volume',
          luasAlas * tp,
          'cm\u00b3',
          'V = L alas × tp = (½ × ${_number(a)} × ${_number(ta)}) × ${_number(tp)}',
        ),
        ShapeResult(
          'Luas Permukaan',
          2 * luasAlas + (a + b + c) * tp,
          'cm\u00b2',
          'LP = 2 × L alas + K alas × tp',
        ),
      ];
    },
  ),
  ShapeSpec(
    name: 'Balok',
    icon: Icons.inbox,
    category: 'Bangun Ruang',
    fields: const [
      FieldSpec('panjang', 'Panjang (cm)'),
      FieldSpec('lebar', 'Lebar (cm)'),
      FieldSpec('tinggi', 'Tinggi (cm)'),
    ],
    calculate: (v) {
      final p = v['panjang']!, l = v['lebar']!, t = v['tinggi']!;
      return [
        ShapeResult(
          'Volume',
          p * l * t,
          'cm\u00b3',
          'V = p × l × t = ${_number(p)} × ${_number(l)} × ${_number(t)}',
        ),
        ShapeResult(
          'Luas Permukaan',
          2 * (p * l + p * t + l * t),
          'cm\u00b2',
          'LP = 2 × (pl + pt + lt) = 2 × (${_number(p)}×${_number(l)} + ${_number(p)}×${_number(t)} + ${_number(l)}×${_number(t)})',
        ),
      ];
    },
  ),
  ShapeSpec(
    name: 'Tabung',
    icon: Icons.local_drink_outlined,
    category: 'Bangun Ruang',
    fields: const [
      FieldSpec('jariJari', 'Jari-jari alas (cm)'),
      FieldSpec('tinggi', 'Tinggi (cm)'),
    ],
    calculate: (v) {
      final r = v['jariJari']!, t = v['tinggi']!;
      return [
        ShapeResult(
          'Volume',
          pi * r * r * t,
          'cm\u00b3',
          'V = π × r × r × t = 3,14 × ${_number(r)} × ${_number(r)} × ${_number(t)}',
        ),
        ShapeResult(
          'Luas Permukaan',
          2 * pi * r * (r + t),
          'cm\u00b2',
          'LP = 2 × π × r × (r + t) = 2 × 3,14 × ${_number(r)} × (${_number(r)} + ${_number(t)})',
        ),
      ];
    },
  ),
  ShapeSpec(
    name: 'Bola',
    icon: Icons.sports_baseball_outlined,
    category: 'Bangun Ruang',
    fields: const [FieldSpec('jariJari', 'Jari-jari (cm)')],
    calculate: (v) {
      final r = v['jariJari']!;
      return [
        ShapeResult(
          'Volume',
          (4 / 3) * pi * r * r * r,
          'cm\u00b3',
          'V = ⁴⁄₃ × π × r³ = ⁴⁄₃ × 3,14 × ${_number(r)}³',
        ),
        ShapeResult(
          'Luas Permukaan',
          4 * pi * r * r,
          'cm\u00b2',
          'LP = 4 × π × r² = 4 × 3,14 × ${_number(r)}²',
        ),
      ];
    },
  ),
];

// ---------------------------------------------------------------------------
// Halaman utama
// ---------------------------------------------------------------------------

class CalculatorHomePage extends StatefulWidget {
  final void Function(String, List<ShapeResult>)? onCalculated;

  const CalculatorHomePage({super.key, this.onCalculated});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  ShapeSpec _selectedShape = shapes.first;
  final Map<String, TextEditingController> _controllers = {};
  final PageController _shapePageController = PageController(
    viewportFraction: .2,
  );
  final PageController _compactShapePageController = PageController(
    viewportFraction: .78,
  );
  List<ShapeResult>? _results;

  @override
  void initState() {
    super.initState();
    _initControllersForShape(_selectedShape);
  }

  void _initControllersForShape(ShapeSpec shape) {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    for (final field in shape.fields) {
      _controllers[field.key] = TextEditingController();
    }
    _results = null;
  }

  void _onShapeChanged(ShapeSpec? shape) {
    if (shape == null) return;
    final index = shapes.indexOf(shape);
    setState(() {
      _selectedShape = shape;
      _initControllersForShape(shape);
    });
    final pageController = _shapePageController.hasClients
        ? _shapePageController
        : _compactShapePageController;
    if (pageController.hasClients && pageController.page?.round() != index) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleHitung() {
    final values = <String, double>{};

    for (final field in _selectedShape.fields) {
      final rawText = _controllers[field.key]!.text.trim();

      if (rawText.isEmpty) {
        _showError('${field.label} belum diisi.');
        setState(() => _results = null);
        return;
      }

      final parsed = double.tryParse(rawText.replaceAll(',', '.'));
      if (parsed == null) {
        _showError('${field.label} harus berupa angka.');
        setState(() => _results = null);
        return;
      }

      if (parsed <= 0) {
        _showError('${field.label} harus lebih besar dari 0.');
        setState(() => _results = null);
        return;
      }

      values[field.key] = parsed;
    }

    setState(() {
      _results = _selectedShape.calculate(values);
    });
    widget.onCalculated?.call(_selectedShape.name, _results!);
  }

  void _handleReset() {
    setState(() {
      for (final c in _controllers.values) {
        c.clear();
      }
      _results = null;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _shapePageController.dispose();
    _compactShapePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: _GeometryBackgroundPainter(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 30),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 940),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Kalkulator Geometri',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff27777b),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Pilih bangun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildShapeSelectorCard(),
                    const SizedBox(height: 24),
                    _buildInputCard(),
                    const SizedBox(height: 26),
                    _buildActionButtons(),
                    if (_results != null) ...[
                      const SizedBox(height: 18),
                      _buildResultCard(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShapeSelectorCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageController = constraints.maxWidth < 600
            ? _compactShapePageController
            : _shapePageController;
        return SizedBox(
          height: 142,
          child: PageView.builder(
            controller: pageController,
            pageSnapping: true,
            padEnds: true,
            scrollDirection: Axis.horizontal,
            itemCount: shapes.length,
            onPageChanged: (index) {
              final shape = shapes[index];
              if (shape != _selectedShape) {
                setState(() {
                  _selectedShape = shape;
                  _initControllersForShape(shape);
                });
              }
            },
            itemBuilder: (context, index) {
              final shape = shapes[index];
              final selected = shape == _selectedShape;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: GestureDetector(
                  onTap: () => _onShapeChanged(shape),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .88),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? const Color(0xff3d9799)
                            : const Color(0xffd8dcda),
                        width: selected ? 3 : 1,
                      ),
                      boxShadow: selected
                          ? const [
                              BoxShadow(
                                color: Color(0x403d9799),
                                blurRadius: 12,
                                offset: Offset(0, 5),
                              ),
                            ]
                          : const [
                              BoxShadow(
                                color: Color(0x16000000),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          shape.icon,
                          size: 42,
                          color: selected
                              ? const Color(0xff2e8d93)
                              : const Color(0xff78aeb0),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          shape.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          shape.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data ${_selectedShape.name}',
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          for (final field in _selectedShape.fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _controllers[field.key],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  hintText: field.label,
                  prefixIcon: const Icon(Icons.straighten, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        SizedBox(
          width: 195,
          child: ElevatedButton.icon(
            onPressed: _handleHitung,
            icon: const Icon(Icons.calculate),
            label: const Text('Hitung'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xff329398),
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 195,
          child: OutlinedButton.icon(
            onPressed: _handleReset,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xff26363b),
              backgroundColor: Colors.white.withValues(alpha: .75),
              padding: const EdgeInsets.all(15),
              side: const BorderSide(color: Color(0xffc7d0d0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return Card(
      color: const Color(0xffe4f3f0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                Text(
                  'Hasil ${_selectedShape.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.indigo.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final r in _results!)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r.label, style: const TextStyle(fontSize: 15)),
                        Text(
                          '${r.value.toStringAsFixed(2)} ${r.unit}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (r.formula.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Rumus: ${r.formula} = ${r.value.toStringAsFixed(2)} ${r.unit}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GeometryBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0x183d9799)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path();
    for (var offset = -100.0; offset < size.width + 180; offset += 105) {
      path.moveTo(offset, 0);
      path.lineTo(offset + 105, 105);
      path.lineTo(offset + 35, 175);
      path.lineTo(offset + 135, 275);
    }
    for (var offset = 80.0; offset < size.height; offset += 170) {
      path.moveTo(0, offset);
      path.lineTo(90, offset + 90);
      path.lineTo(0, offset + 180);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HistoryPage extends StatelessWidget {
  final List<CalculationHistory> history;

  const _HistoryPage({required this.history});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Riwayat Perhitungan',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: .45),
                          ),
                          const SizedBox(height: 12),
                          const Text('Belum ada riwayat perhitungan.'),
                          const SizedBox(height: 4),
                          Text(
                            'Hasil perhitungan akan muncul di sini.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return Card(
                          child: ExpansionTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(
                              item.shapeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(_formatDate(item.createdAt)),
                            children: [
                              for (final result in item.results)
                                ListTile(
                                  dense: true,
                                  title: Text(result.label),
                                  subtitle: Text(
                                    result.formula.isEmpty
                                        ? 'Rumus tidak tersedia'
                                        : result.formula,
                                  ),
                                  trailing: Text(
                                    '${_number(result.value)} ${result.unit}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year}  $hour:$minute';
  }
}

class _AboutPage extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const _AboutPage({required this.isDark, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
        children: [
          const Text(
            'Tentang',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.calculate, size: 42, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  'Kalkulator Geometri',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Versi 1.0',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Aplikasi'),
              subtitle: const Text(
                'Kalkulator Geometri membantu menghitung luas, keliling, luas permukaan, dan volume berbagai bangun geometri.',
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.auto_awesome),
                  title: Text('Fitur Aplikasi'),
                ),
                const ListTile(
                  leading: Icon(Icons.calculate, color: Colors.blue),
                  title: Text('Kalkulator Geometri'),
                  subtitle: Text('Menghitung berbagai bangun.'),
                ),
                const ListTile(
                  leading: Icon(Icons.history, color: Colors.deepPurple),
                  title: Text('Riwayat Perhitungan'),
                  subtitle: Text('Menyimpan hasil selama aplikasi berjalan.'),
                ),
                const ListTile(
                  leading: Icon(Icons.menu_book, color: Colors.orange),
                  title: Text('Informasi & Rumus'),
                  subtitle: Text('Menampilkan rumus setiap perhitungan.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Mode Gelap'),
              subtitle: const Text('Aktifkan tampilan gelap aplikasi'),
              value: isDark,
              onChanged: onThemeChanged,
            ),
          ),
        ],
      ),
    );
  }
}
