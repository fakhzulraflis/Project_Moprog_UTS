import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/unit_data.dart';
import '../pages/lesson_page.dart';
import '../services/course_service.dart';
import '../widgets/chest_node.dart';
import '../widgets/gem_burst.dart';
import '../widgets/inventory_button.dart';
import '../widgets/lesson_node.dart';
import '../widgets/lesson_popup.dart';
import '../widgets/unit_header.dart';

class _Slot {
  final int unit;
  final int index;
  final int order;
  final bool isChest;
  final int lessonId;
  final int apiLessonId;
  final int lessonIndex;

  const _Slot({
    required this.unit,
    required this.index,
    required this.order,
    required this.isChest,
    required this.lessonId,
    required this.apiLessonId,
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
  final GlobalKey _gemsKey = GlobalKey();

  List<UnitData> units = [];
  List<_Slot> _slots = [];
  bool isLoading = true;
  String? errorMessage;
  String ttsCode = 'en-US';

  int completedLessons = 0;
  int? selectedLessonId;
  int headerIndex = 0;

  int gems = 0;
  bool gemPulse = false;
  final Set<int> openedChests = {};

  static const double zoom = 0.85;

  static const int chestParticles = 10;
  static const int gemsPerParticle = 2;

  static const double slotHeight = 170;
  static const double topPad = 40;
  static const double dividerHeight = 70;
  static const double popupSpace = 200;
  static const double headerSwitchOffset = 60;

  static const Color backgroundColor = Color(0xFF272F33);
  static const Color dividerColor = Color(0xFF52656D);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadPath();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String get languageCode {
    switch (widget.selectedLanguage) {
      case 'Japanese':
      case 'Jepang':
        return 'ja';

      case 'Korean':
      case 'Korea':
        return 'ko';

      default:
        return 'en';
    }
  }

  Future<void> _loadPath() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await CourseService.getPath(languageCode);

      if (!mounted) return;

      setState(() {
        units = result.units;
        ttsCode = result.ttsCode;
        _slots = _buildSlots();
        headerIndex = 0;
        completedLessons = 0;
        selectedLessonId = null;
        openedChests.clear();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<_Slot> _buildSlots() {
    final out = <_Slot>[];
    int lessonNumber = 0;
    int order = 0;

    for (int u = 0; u < units.length; u++) {
      final unit = units[u];
      int idx = 0;

      for (int j = 0; j < unit.lessonCount; j++) {
        lessonNumber++;

        out.add(
          _Slot(
            unit: u,
            index: idx++,
            order: order++,
            isChest: false,
            lessonId: lessonNumber,
            apiLessonId: unit.lessonIds[j],
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
              lessonId: lessonNumber,
              apiLessonId: unit.lessonIds[j],
              lessonIndex: -1,
            ),
          );
        }
      }
    }

    return out;
  }

  _Slot _lessonSlot(int lessonNumber) =>
      _slots.firstWhere((s) => !s.isChest && s.lessonId == lessonNumber);

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

  void _onScroll() {
    if (units.isEmpty) return;

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
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFCCF10)),
        ),
      );
    }

    if (errorMessage != null || units.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    errorMessage ?? 'Belum ada pelajaran untuk bahasa ini.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loadPath,
                    child: const Text(
                      'COBA LAGI',
                      style: TextStyle(
                        color: Color(0xFFFCCF10),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: const InventoryButton(),
      body: SafeArea(
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

  Widget _buildContent() {
    final current = units[headerIndex];

    return Column(
      children: [
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

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: UnitHeader(
            key: ValueKey(headerIndex),
            color: current.color,
            sectionLabel: 'BAGIAN ${current.section}, UNIT ${current.unit}',
            title: current.title,
            onGuidebookTap: () {},
          ),
        ),

        const SizedBox(height: 4),

        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            child: _buildPath(),
          ),
        ),
      ],
    );
  }

  Widget _buildPath() {
    final baseHeight = _unitStart(units.length);
    double totalHeight = baseHeight;

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

    if (selectedLessonId != null) children.add(_buildPopup(selectedLessonId!));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
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

  Widget _buildLessonSlot(_Slot s) {
    final unit = units[s.unit];
    final id = s.lessonId;
    final state = _stateOf(id);
    final isLast = s.lessonIndex == unit.lessonCount - 1;
    final isSelected = selectedLessonId == id;

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

  Color _popupTextColor(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness(0.14).toColor();
  }

  double _dxOf(int order) => math.sin(order * math.pi / 2) * 50;

  NodeState _stateOf(int lessonId) {
    if (lessonId <= completedLessons) return NodeState.completed;
    if (lessonId == completedLessons + 1) return NodeState.current;
    return NodeState.locked;
  }

  ChestState _chestStateOf(int afterLessonId) {
    if (openedChests.contains(afterLessonId)) return ChestState.opened;
    if (completedLessons >= afterLessonId) return ChestState.ready;
    return ChestState.locked;
  }

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

  void _onNodeTap(int lessonId) {
    setState(() {
      selectedLessonId = selectedLessonId == lessonId ? null : lessonId;
    });
  }

  void _startLesson(int lessonId) {
    setState(() => selectedLessonId = null);
    _openLesson(lessonId);
  }

  Future<void> _openLesson(int lessonNumber) async {
    final slot = _lessonSlot(lessonNumber);

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LessonPage(lessonId: slot.apiLessonId, ttsCode: ttsCode),
      ),
    );

    if (!mounted) return;

    if (result == true && lessonNumber > completedLessons) {
      setState(() => completedLessons = lessonNumber);
    }
  }

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
