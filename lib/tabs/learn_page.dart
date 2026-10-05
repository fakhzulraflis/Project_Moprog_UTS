import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/unit_data.dart';
import '../pages/lesson_page.dart';
import '../widgets/chest_node.dart';
import '../widgets/gem_burst.dart';
import '../widgets/lesson_node.dart';
import '../widgets/lesson_popup.dart';
import '../widgets/unit_header.dart';

// Satu slot di jalur: pelajaran atau peti
class _Slot {
  final int unit;
  final int index; // urutan di dalam unit (pelajaran + peti)
  final int order; // urutan global (untuk zigzag)
  final bool isChest;
  final int
  lessonId; // pelajaran: id-nya sendiri; peti: id pelajaran sebelumnya
  final int lessonIndex; // pelajaran: indeks di unit (0-based); peti: -1

  const _Slot({
    required this.unit,
    required this.index,
    required this.order,
    required this.isChest,
    required this.lessonId,
    required this.lessonIndex,
  });
}

class LearnPage extends StatefulWidget {
  final String selectedLanguage;

  const LearnPage({super.key, required this.selectedLanguage});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _gemsKey = GlobalKey(); // target animasi gems

  int completedLessons = 0;
  int? selectedLessonId; // node yang sedang menampilkan popup
  int headerIndex = 0; // unit yang sedang tampil di header

  int gems = 0;
  bool gemPulse = false;
  final Set<int> openedChests =
      {}; // diidentifikasi lewat id pelajaran sebelumnya

  // =========================
  // ZOOM HALAMAN
  // =========================
  static const double zoom = 0.85;

  // =========================
  // HADIAH PETI
  // =========================
  static const int chestParticles = 10; // jumlah gems yang beterbangan
  static const int gemsPerParticle = 2; // total hadiah = 10 x 2 = 20

  // =========================
  // DATA UNIT (contoh, ganti sesuai materimu)
  // =========================
  static const List<UnitData> units = [
    UnitData(
      section: 1,
      unit: 1,
      title: 'Memesan Makanan & Minuman',
      color: Color(0xFFFCCF10),
      nodeColor: Color(0xFFFCCF10),
      lessonTitles: [
        'Memesan Makanan',
        'Memesan Kopi & Teh',
        'Membaca Menu',
        'Memesan Minuman',
        'Tantangan Unit',
      ],
      chestAfter: [2], // peti setelah pelajaran ke-2
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
      chestAfter: [3], // peti setelah pelajaran ke-3
    ),
  ];

  // =========================
  // TATA LETAK
  // =========================
  static const double slotHeight = 150; // tinggi tiap slot node
  static const double topPad = 40; // ruang di atas node pertama tiap unit
  static const double dividerHeight = 70; // pemisah antar unit
  static const double popupSpace = 200; // perkiraan tinggi popup
  static const double headerSwitchOffset =
      60; // kapan header berganti saat scroll

  static const Color backgroundColor = Color(0xFF272F33);
  static const Color dividerColor = Color(0xFF52656D);

  late final List<_Slot> _slots = _buildSlots();

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

  // ---------- susun slot (pelajaran + peti) ----------
  List<_Slot> _buildSlots() {
    final out = <_Slot>[];
    int lessonId = 0;
    int order = 0;

    for (int u = 0; u < units.length; u++) {
      final unit = units[u];
      int idx = 0;

      for (int j = 0; j < unit.lessonCount; j++) {
        lessonId++;
        out.add(
          _Slot(
            unit: u,
            index: idx++,
            order: order++,
            isChest: false,
            lessonId: lessonId,
            lessonIndex: j,
          ),
        );

        if (unit.chestAfter.contains(j + 1)) {
          out.add(
            _Slot(
              unit: u,
              index: idx++,
              order: order++,
              isChest: true,
              lessonId: lessonId,
              lessonIndex: -1,
            ),
          );
        }
      }
    }
    return out;
  }

  _Slot _lessonSlot(int lessonId) =>
      _slots.firstWhere((s) => !s.isChest && s.lessonId == lessonId);

  // ---------- helper hitung posisi ----------
  double _unitHeight(int u) =>
      (u > 0 ? dividerHeight : 0) + topPad + units[u].slotCount * slotHeight;

  double _unitStart(int u) {
    double y = 0;
    for (int i = 0; i < u; i++) {
      y += _unitHeight(i);
    }
    return y;
  }

  double _slotTop(_Slot s) =>
      _unitStart(s.unit) +
      (s.unit > 0 ? dividerHeight : 0) +
      topPad +
      s.index * slotHeight;

  double _popupTop(_Slot s) => _slotTop(s) + slotHeight - 4;

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

                  // ikon gems = tujuan animasi, ikut "berdenyut" saat gem tiba
                  AnimatedScale(
                    key: _gemsKey,
                    scale: gemPulse ? 1.3 : 1.0,
                    duration: const Duration(milliseconds: 120),
                    child: Image.asset(
                      'assets/icons/gems.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$gems',
                    style: const TextStyle(
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
    final baseHeight = _unitStart(units.length);
    double totalHeight = baseHeight;

    // beri ruang ekstra bila popup mencapai dasar jalur
    if (selectedLessonId != null) {
      final popupBottom =
          _popupTop(_lessonSlot(selectedLessonId!)) + popupSpace;
      totalHeight = math.max(baseHeight, popupBottom);
    }

    final children = <Widget>[];

    for (int u = 1; u < units.length; u++) {
      children.add(_buildDivider(u));
    }

    for (final s in _slots) {
      children.add(s.isChest ? _buildChestSlot(s) : _buildLessonSlot(s));
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

  // ---------- slot pelajaran ----------
  Widget _buildLessonSlot(_Slot s) {
    final unit = units[s.unit];
    final id = s.lessonId;
    final state = _stateOf(id);
    final isLast = s.lessonIndex == unit.lessonCount - 1;
    final isSelected = selectedLessonId == id;

    // Piala tetap piala (abu/putih), centang hanya untuk node bintang
    final type = isLast
        ? NodeType.trophy
        : state == NodeState.completed
        ? NodeType.check
        : NodeType.star;

    return Positioned(
      top: _slotTop(s),
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
          offset: Offset(_dxOf(s.order), 0),
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

  // ---------- slot peti ----------
  Widget _buildChestSlot(_Slot s) {
    return Positioned(
      top: _slotTop(s),
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
          offset: Offset(_dxOf(s.order), 0),
          child: ChestNode(
            state: _chestStateOf(s.lessonId),
            onOpen: (origin) => _openChest(s.lessonId, origin),
          ),
        ),
      ),
    );
  }

  Widget _buildPopup(int id) {
    final s = _lessonSlot(id);
    final unit = units[s.unit];
    final state = _stateOf(id);

    return Positioned(
      top: _popupTop(s),
      left: 24,
      right: 24,
      // GestureDetector kosong: ketuk badan popup tidak menutupnya
      child: GestureDetector(
        onTap: () {},
        child: LessonPopup(
          title: unit.lessonTitles[s.lessonIndex],
          subtitle: 'Pelajaran ${s.lessonIndex + 1} dari ${unit.lessonCount}',
          buttonLabel: state == NodeState.completed
              ? 'LATIH LAGI +5 XP'
              : 'MULAI +10 XP',
          color: unit.nodeColor,
          textColor: _popupTextColor(unit.nodeColor),
          pointerDx: _dxOf(s.order),
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

  // zigzag berlanjut antar slot (pelajaran & peti): 0, +50, 0, -50, 0 ...
  double _dxOf(int order) => math.sin(order * math.pi / 2) * 50;

  NodeState _stateOf(int lessonId) {
    if (lessonId <= completedLessons) return NodeState.completed;
    if (lessonId == completedLessons + 1) return NodeState.current;
    return NodeState.locked;
  }

  // Peti: terkunci sampai pelajaran sebelumnya selesai
  ChestState _chestStateOf(int afterLessonId) {
    if (openedChests.contains(afterLessonId)) return ChestState.opened;
    if (completedLessons >= afterLessonId) return ChestState.ready;
    return ChestState.locked;
  }

  // =========================
  // BUKA PETI + ANIMASI GEMS
  // =========================
  Offset? _gemsTarget() {
    final box = _gemsKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  void _openChest(int afterLessonId, Offset origin) {
    if (openedChests.contains(afterLessonId)) return;

    setState(() {
      openedChests.add(afterLessonId);
      selectedLessonId = null;
    });

    final target = _gemsTarget();

    // cadangan: tujuan tidak ditemukan -> langsung tambahkan hadiah
    if (target == null) {
      setState(() => gems += chestParticles * gemsPerParticle);
      return;
    }

    GemBurst.play(
      context: context,
      from: origin,
      to: target,
      asset: 'assets/icons/gems.png',
      count: chestParticles,
      size: 24,
      onGemArrive: _onGemArrive,
    );
  }

  // Tiap gem yang sampai: tambah angka + ikon gems berdenyut sebentar
  void _onGemArrive() {
    if (!mounted) return;

    setState(() {
      gems += gemsPerParticle;
      gemPulse = true;
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => gemPulse = false);
    });
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
