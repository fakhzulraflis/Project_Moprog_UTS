import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/unit_data.dart';
import '../pages/lesson_page.dart';
import '../widgets/lesson_node.dart';
import '../widgets/lesson_popup.dart';
import '../widgets/unit_header.dart';

class LearnPage extends StatefulWidget {
  final String selectedLanguage;

  const LearnPage({super.key, required this.selectedLanguage});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final ScrollController _scroll = ScrollController();

  int completedLessons = 0;
  int? selectedLessonId; // node yang sedang menampilkan popup
  int headerIndex = 0; // unit yang sedang tampil di header

  // =========================
  // ZOOM HALAMAN
  // 1.0 = ukuran asli, makin kecil = makin "zoom out"
  // =========================
  static const double zoom = 0.85;

  // =========================
  // DATA UNIT (contoh, ganti sesuai materimu)
  // =========================
  static const List<UnitData> units = [
    UnitData(
      section: 1,
      unit: 1,
      title: 'Memesan Makanan & Minuman',
      color: Color(0xFF3B8C5A),
      nodeColor: Color(0xFFFCCF10),
      lessonTitles: [
        'Memesan Makanan',
        'Memesan Kopi & Teh',
        'Membaca Menu',
        'Memesan Minuman',
        'Tantangan Unit',
      ],
    ),
    UnitData(
      section: 1,
      unit: 2,
      title: 'Menanyakan Arah',
      color: Color(0xFF1CB0F6),
      nodeColor: Color(0xFFFF9600),
      lessonTitles: [
        'Bertanya Lokasi',
        'Kiri dan Kanan',
        'Naik Transportasi',
        'Tantangan Unit',
      ],
    ),
  ];

  // =========================
  // TATA LETAK
  // =========================
  static const double slotHeight = 150; // tinggi tiap slot node
  static const double topPad = 40; // ruang di atas node pertama tiap unit
  static const double dividerHeight = 70; // pemisah antar unit
  static const double popupSpace =
      200; // ruang bawah jika popup di node terakhir
  static const double headerSwitchOffset =
      60; // kapan header berganti saat scroll

  static const Color backgroundColor = Color(0xFF272F33);
  static const Color dividerColor = Color(0xFF52656D);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // ---------- helper hitung posisi ----------
  int get totalLessons => units.fold<int>(0, (sum, u) => sum + u.lessonCount);

  double _unitHeight(int u) =>
      (u > 0 ? dividerHeight : 0) + topPad + units[u].lessonCount * slotHeight;

  double _unitStart(int u) {
    double y = 0;
    for (int i = 0; i < u; i++) {
      y += _unitHeight(i);
    }
    return y;
  }

  double _nodeTop(int u, int j) =>
      _unitStart(u) + (u > 0 ? dividerHeight : 0) + topPad + j * slotHeight;

  int _firstLessonId(int u) {
    int id = 1;
    for (int i = 0; i < u; i++) {
      id += units[i].lessonCount;
    }
    return id;
  }

  int _unitIndexOf(int lessonId) {
    for (int u = 0; u < units.length; u++) {
      final first = _firstLessonId(u);
      if (lessonId >= first && lessonId < first + units[u].lessonCount) {
        return u;
      }
    }
    return units.length - 1;
  }

  // ---------- header berganti saat scroll ----------
  void _onScroll() {
    final offset = _scroll.offset;
    int idx = 0;
    for (int u = 1; u < units.length; u++) {
      if (offset + headerSwitchOffset >= _unitStart(u) + dividerHeight / 2) {
        idx = u;
      }
    }
    if (idx != headerIndex) setState(() => headerIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        // Halaman digambar di kanvas yang lebih besar (ukuran / zoom),
        // lalu diskala turun supaya pas di layar
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth / zoom;
            final h = constraints.maxHeight / zoom;

            return OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: w,
              maxWidth: w,
              minHeight: h,
              maxHeight: h,
              child: Transform.scale(
                scale: zoom,
                alignment: Alignment.topLeft,
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================
  // ISI HALAMAN
  // =========================
  Widget _buildContent() {
    final current = units[headerIndex];

    return Column(
      children: [
        // =========================
        // TOP BAR
        // =========================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                _getLanguageFlagAsset(),
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/icons/streak.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Image.asset(
                    'assets/icons/gems.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Image.asset(
                    'assets/icons/hearts.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    '5',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // =========================
        // UNIT HEADER (menempel, berganti per unit)
        // =========================
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: UnitHeader(
            key: ValueKey(headerIndex),
            color: current.color,
            sectionLabel: 'BAGIAN ${current.section}, UNIT ${current.unit}',
            title: current.title,
            onGuidebookTap: () {
              // TODO: buka halaman panduan untuk unit ini
            },
          ),
        ),

        const SizedBox(height: 4),

        // =========================
        // JALUR PELAJARAN (bisa di-scroll)
        // =========================
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            child: _buildPath(),
          ),
        ),
      ],
    );
  }

  // =========================
  // JALUR: satu Stack untuk semua unit
  // =========================
  Widget _buildPath() {
    final extraBottom = selectedLessonId == totalLessons ? popupSpace : 0.0;
    final totalHeight = _unitStart(units.length) + extraBottom;

    final children = <Widget>[];
    int g = 0; // indeks pelajaran global (0-based)

    for (int u = 0; u < units.length; u++) {
      if (u > 0) children.add(_buildDivider(u));
      for (int j = 0; j < units[u].lessonCount; j++) {
        children.add(_buildNodeSlot(u, j, g));
        g++;
      }
    }

    // popup paling akhir = paling atas, tidak menggeser apa pun
    if (selectedLessonId != null) children.add(_buildPopup(selectedLessonId!));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      // ketuk area kosong -> tutup popup
      onTap: () => setState(() => selectedLessonId = null),
      child: SizedBox(
        width: double.infinity,
        height: totalHeight,
        child: Stack(clipBehavior: Clip.none, children: children),
      ),
    );
  }

  Widget _buildDivider(int u) {
    return Positioned(
      top: _unitStart(u),
      left: 16,
      right: 16,
      height: dividerHeight,
      child: Row(
        children: [
          const Expanded(child: Divider(color: dividerColor, thickness: 2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              units[u].title,
              style: const TextStyle(
                color: dividerColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Expanded(child: Divider(color: dividerColor, thickness: 2)),
        ],
      ),
    );
  }

  Widget _buildNodeSlot(int u, int j, int g) {
    final unit = units[u];
    final id = g + 1;
    final state = _stateOf(id);
    final isLast = j == unit.lessonCount - 1;
    final isSelected = selectedLessonId == id;

    // Piala tetap piala (abu/putih), centang hanya untuk node bintang
    final type = isLast
        ? NodeType.trophy
        : state == NodeState.completed
        ? NodeType.check
        : NodeType.star;

    return Positioned(
      top: _nodeTop(u, j),
      left: 0,
      right: 0,
      height: slotHeight,
      child: OverflowBox(
        alignment: Alignment.bottomCenter,
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: 0,
        maxHeight: double.infinity,
        child: Transform.translate(
          offset: Offset(_dxOf(g), 0),
          child: LessonNode(
            state: state,
            type: type,
            color: unit.nodeColor,
            showStartBubble: !isSelected,
            onTap: () => _onNodeTap(id),
          ),
        ),
      ),
    );
  }

  Widget _buildPopup(int id) {
    final u = _unitIndexOf(id);
    final unit = units[u];
    final j = id - _firstLessonId(u);
    final g = id - 1;
    final state = _stateOf(id);

    return Positioned(
      top: _nodeTop(u, j) + slotHeight - 4,
      left: 24,
      right: 24,
      // GestureDetector kosong: ketuk badan popup tidak menutupnya
      child: GestureDetector(
        onTap: () {},
        child: LessonPopup(
          title: unit.lessonTitles[j],
          subtitle: 'Pelajaran ${j + 1} dari ${unit.lessonCount}',
          buttonLabel: state == NodeState.completed
              ? 'LATIH LAGI +5 XP'
              : 'MULAI +10 XP',
          color: unit.nodeColor,
          textColor: _popupTextColor(unit.nodeColor),
          pointerDx: _dxOf(g),
          onStart: () => _startLesson(id),
        ),
      ),
    );
  }

  // Warna teks popup: versi gelap dari warna kartu
  Color _popupTextColor(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness(0.14).toColor();
  }

  // zigzag berlanjut antar unit: 0, +50, 0, -50, 0 ...
  double _dxOf(int g) => math.sin(g * math.pi / 2) * 50;

  NodeState _stateOf(int lessonId) {
    if (lessonId <= completedLessons) return NodeState.completed;
    if (lessonId == completedLessons + 1) return NodeState.current;
    return NodeState.locked;
  }

  // Tekan node: buka/tutup popup (node terkunci tidak memanggil ini)
  void _onNodeTap(int lessonId) {
    setState(() {
      selectedLessonId = selectedLessonId == lessonId ? null : lessonId;
    });
  }

  void _startLesson(int lessonId) {
    setState(() => selectedLessonId = null);
    _openLesson(lessonId);
  }

  Future<void> _openLesson(int lessonId) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => LessonPage(lessonId: lessonId)),
    );

    if (!mounted) return;

    if (result == true && lessonId > completedLessons) {
      setState(() => completedLessons = lessonId);
    }
  }

  // =========================
  // LANGUAGE FLAG
  // =========================
  String _getLanguageFlagAsset() {
    switch (widget.selectedLanguage) {
      case 'Japanese':
      case 'Jepang':
        return 'assets/flags/japan.png';

      case 'Korean':
      case 'Korea':
        return 'assets/flags/korea.png';

      case 'English':
      case 'Inggris':
      default:
        return 'assets/flags/inggris.png';
    }
  }
}
