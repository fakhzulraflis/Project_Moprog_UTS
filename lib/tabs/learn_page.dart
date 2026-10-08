import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/unit_data.dart';
import '../pages/guidebook_page.dart';
import '../pages/lesson_page.dart';
import '../services/course_service.dart';
import '../services/player_progress.dart';
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

  int? selectedLessonId;
  int headerIndex = 0;

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

  PlayerProgress get progress => PlayerProgress.instance;

  @override
  void initState() {
    super.initState();

    _scroll.addListener(_onScroll);
    _loadPath();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
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

      case 'English':
      case 'Inggris':
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
      await progress.load();

      final result = await CourseService.getPath(languageCode);

      if (!mounted) return;

      setState(() {
        units = result.units;
        ttsCode = result.ttsCode;
        _slots = _buildSlots();
        headerIndex = 0;
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

      int index = 0;

      for (int j = 0; j < unit.lessonCount; j++) {
        lessonNumber++;

        out.add(
          _Slot(
            unit: u,
            index: index,
            order: order,
            isChest: false,
            lessonId: lessonNumber,
            apiLessonId: unit.lessonIds[j],
            lessonIndex: j,
          ),
        );

        index++;
        order++;

        if (unit.chestAfter.contains(j + 1)) {
          out.add(
            _Slot(
              unit: u,
              index: index,
              order: order,
              isChest: true,
              lessonId: lessonNumber,
              apiLessonId: unit.lessonIds[j],
              lessonIndex: -1,
            ),
          );

          index++;
          order++;
        }
      }
    }

    return out;
  }

  _Slot? _findLessonSlot(int lessonNumber) {
    for (final slot in _slots) {
      if (!slot.isChest && slot.lessonId == lessonNumber) {
        return slot;
      }
    }

    return null;
  }

  _Slot? _findPreviousLessonSlot(int lessonNumber) {
    if (lessonNumber <= 1) {
      return null;
    }

    for (final slot in _slots) {
      if (!slot.isChest && slot.lessonId == lessonNumber - 1) {
        return slot;
      }
    }

    return null;
  }

  _Slot? _findChestSlot(int lessonNumber) {
    for (final slot in _slots) {
      if (slot.isChest && slot.lessonId == lessonNumber) {
        return slot;
      }
    }

    return null;
  }

  double _unitHeight(int unitIndex) {
    return (unitIndex > 0 ? dividerHeight : 0) +
        topPad +
        units[unitIndex].slotCount * slotHeight;
  }

  double _unitStart(int unitIndex) {
    double y = 0;

    for (int i = 0; i < unitIndex; i++) {
      y += _unitHeight(i);
    }

    return y;
  }

  double _slotTop(_Slot slot) {
    return _unitStart(slot.unit) +
        (slot.unit > 0 ? dividerHeight : 0) +
        topPad +
        slot.index * slotHeight;
  }

  double _popupTop(_Slot slot) {
    return _slotTop(slot) + slotHeight - 4;
  }

  void _onScroll() {
    if (units.isEmpty) return;

    final offset = _scroll.offset;

    int index = 0;

    for (int u = 1; u < units.length; u++) {
      if (offset + headerSwitchOffset >= _unitStart(u) + dividerHeight / 2) {
        index = u;
      }
    }

    if (index != headerIndex) {
      setState(() {
        headerIndex = index;
      });
    }
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

    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          floatingActionButton: const InventoryButton(),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth / zoom;
                final height = constraints.maxHeight / zoom;

                return OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: width,
                  maxWidth: width,
                  minHeight: height,
                  maxHeight: height,
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
      },
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
                  Text(
                    '${progress.storedStreak}',
                    style: const TextStyle(
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
                    '${progress.gems}',
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
                  Text(
                    '${5 + progress.bonusHearts}',
                    style: const TextStyle(
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
            onGuidebookTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      GuidebookPage(unit: current, ttsCode: ttsCode),
                ),
              );
            },
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
      final selectedSlot = _findLessonSlot(selectedLessonId!);

      if (selectedSlot != null) {
        final popupBottom = _popupTop(selectedSlot) + popupSpace;

        totalHeight = math.max(baseHeight, popupBottom);
      }
    }

    final children = <Widget>[];

    for (int u = 1; u < units.length; u++) {
      children.add(_buildDivider(u));
    }

    for (final slot in _slots) {
      if (slot.isChest) {
        children.add(_buildChestSlot(slot));
      } else {
        children.add(_buildLessonSlot(slot));
      }
    }

    if (selectedLessonId != null) {
      children.add(_buildPopup(selectedLessonId!));
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          selectedLessonId = null;
        });
      },
      child: SizedBox(
        width: double.infinity,
        height: totalHeight,
        child: Stack(clipBehavior: Clip.none, children: children),
      ),
    );
  }

  Widget _buildDivider(int unitIndex) {
    final unit = units[unitIndex];
    final completed = _completedLessonsInUnit(unitIndex);

    return Positioned(
      top: _unitStart(unitIndex),
      left: 16,
      right: 16,
      height: dividerHeight,
      child: Row(
        children: [
          const Expanded(child: Divider(color: dividerColor, thickness: 2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  unit.title,
                  style: const TextStyle(
                    color: dividerColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$completed/${unit.lessonCount}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: Divider(color: dividerColor, thickness: 2)),
        ],
      ),
    );
  }

  Widget _buildLessonSlot(_Slot slot) {
    final unit = units[slot.unit];
    final state = _stateOf(slot);
    final isLast = slot.lessonIndex == unit.lessonCount - 1;
    final isSelected = selectedLessonId == slot.lessonId;

    final type = isLast
        ? NodeType.trophy
        : state == NodeState.completed
        ? NodeType.check
        : NodeType.star;

    return Positioned(
      top: _slotTop(slot),
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
          offset: Offset(_dxOf(slot.order), 0),
          child: LessonNode(
            state: state,
            type: type,
            color: unit.nodeColor,
            showStartBubble: !isSelected,
            onTap: () {
              _onNodeTap(slot.lessonId);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChestSlot(_Slot slot) {
    return Positioned(
      top: _slotTop(slot),
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
          offset: Offset(_dxOf(slot.order), 0),
          child: ChestNode(
            state: _chestStateOf(slot),
            onOpen: (origin) {
              _openChest(slot.lessonId, origin);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPopup(int lessonNumber) {
    final slot = _findLessonSlot(lessonNumber);

    if (slot == null) {
      return const SizedBox.shrink();
    }

    final unit = units[slot.unit];
    final state = _stateOf(slot);

    return Positioned(
      top: _popupTop(slot),
      left: 24,
      right: 24,
      child: GestureDetector(
        onTap: () {},
        child: LessonPopup(
          title: unit.lessonTitles[slot.lessonIndex],
          subtitle:
              'Pelajaran ${slot.lessonIndex + 1} dari ${unit.lessonCount}',
          buttonLabel: state == NodeState.completed
              ? 'LATIH LAGI'
              : 'MULAI +10 XP',
          color: unit.nodeColor,
          textColor: _popupTextColor(unit.nodeColor),
          pointerDx: _dxOf(slot.order),
          onStart: () {
            _startLesson(lessonNumber);
          },
        ),
      ),
    );
  }

  Color _popupTextColor(Color color) {
    final hsl = HSLColor.fromColor(color);

    return hsl.withLightness(0.14).toColor();
  }

  double _dxOf(int order) {
    return math.sin(order * math.pi / 2) * 50;
  }

  NodeState _stateOf(_Slot slot) {
    if (progress.isLessonCompleted(slot.apiLessonId)) {
      return NodeState.completed;
    }

    if (_isLessonUnlocked(slot)) {
      return NodeState.current;
    }

    return NodeState.locked;
  }

  bool _isLessonUnlocked(_Slot slot) {
    if (slot.lessonId == 1) {
      return true;
    }

    final previous = _findPreviousLessonSlot(slot.lessonId);

    if (previous == null) {
      return false;
    }

    return progress.isLessonCompleted(previous.apiLessonId);
  }

  ChestState _chestStateOf(_Slot slot) {
    if (openedChests.contains(slot.lessonId)) {
      return ChestState.opened;
    }

    if (!progress.isLessonCompleted(slot.apiLessonId)) {
      return ChestState.locked;
    }

    return ChestState.ready;
  }

  int _completedLessonsInUnit(int unitIndex) {
    final lessonIds = units[unitIndex].lessonIds;

    int count = 0;

    for (final lessonId in lessonIds) {
      if (progress.isLessonCompleted(lessonId)) {
        count++;
      }
    }

    return count;
  }

  bool _isUnitCompleted(int unitIndex) {
    final lessonIds = units[unitIndex].lessonIds;

    if (lessonIds.isEmpty) {
      return false;
    }

    for (final lessonId in lessonIds) {
      if (!progress.isLessonCompleted(lessonId)) {
        return false;
      }
    }

    return true;
  }

  bool _isUnitUnlocked(int unitIndex) {
    if (unitIndex == 0) {
      return true;
    }

    return _isUnitCompleted(unitIndex - 1);
  }

  Offset? _gemsTarget() {
    final renderObject = _gemsKey.currentContext?.findRenderObject();

    if (renderObject is! RenderBox) {
      return null;
    }

    if (!renderObject.hasSize) {
      return null;
    }

    return renderObject.localToGlobal(renderObject.size.center(Offset.zero));
  }

  Future<void> _openChest(int afterLessonId, Offset origin) async {
    if (openedChests.contains(afterLessonId)) {
      return;
    }

    final slot = _findChestSlot(afterLessonId);

    if (slot == null) {
      return;
    }

    if (!progress.isLessonCompleted(slot.apiLessonId)) {
      return;
    }

    setState(() {
      openedChests.add(afterLessonId);
      selectedLessonId = null;
    });

    final target = _gemsTarget();

    if (target == null) {
      await progress.update(() {
        progress.gems += chestParticles * gemsPerParticle;
      });

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

  Future<void> _onGemArrive() async {
    if (!mounted) {
      return;
    }

    await progress.update(() {
      progress.gems += gemsPerParticle;
    });

    if (!mounted) {
      return;
    }

    setState(() {
      gemPulse = true;
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) {
        return;
      }

      setState(() {
        gemPulse = false;
      });
    });
  }

  void _onNodeTap(int lessonNumber) {
    final slot = _findLessonSlot(lessonNumber);

    if (slot == null) {
      return;
    }

    if (!_isLessonUnlocked(slot)) {
      return;
    }

    setState(() {
      if (selectedLessonId == lessonNumber) {
        selectedLessonId = null;
      } else {
        selectedLessonId = lessonNumber;
      }
    });
  }

  void _startLesson(int lessonNumber) {
    final slot = _findLessonSlot(lessonNumber);

    if (slot == null) {
      return;
    }

    if (!_isLessonUnlocked(slot)) {
      return;
    }

    setState(() {
      selectedLessonId = null;
    });

    _openLesson(lessonNumber);
  }

  Future<void> _openLesson(int lessonNumber) async {
    final slot = _findLessonSlot(lessonNumber);

    if (slot == null) {
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LessonPage(lessonId: slot.apiLessonId, ttsCode: ttsCode),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      await progress.load();

      if (!mounted) {
        return;
      }

      setState(() {});
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
