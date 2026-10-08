import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/guide_block.dart';
import '../models/unit_data.dart';
import 'lesson_page.dart';

const Color _bg = Color(0xFF272F33);
const Color _surface = Color(0xFF1F292E);
const Color _border = Color(0xFF414F57);
const Color _yellow = Color(0xFFFCCF10);
const Color _yellowDark = Color(0xFFC9A200);
const Color _onYellow = Color(0xFF3B3000);
const Color _blue = Color(0xFF1CB0F6);

class GuidebookPage extends StatefulWidget {
  final UnitData unit;
  final String ttsCode;

  const GuidebookPage({super.key, required this.unit, required this.ttsCode});

  @override
  State<GuidebookPage> createState() => _GuidebookPageState();
}

class _GuidebookPageState extends State<GuidebookPage> {
  final FlutterTts _tts = FlutterTts();

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await _tts.stop();
      await _tts.setLanguage(widget.ttsCode);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocks = widget.unit.guidebook;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: blocks.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      itemCount: blocks.length,
                      itemBuilder: (context, index) =>
                          _buildBlock(blocks[index]),
                    ),
            ),

            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final lightHeader = widget.unit.color.computeLuminance() > 0.45;
    final onColor = lightHeader ? _onYellow : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 20),
      decoration: BoxDecoration(
        color: widget.unit.color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: onColor, size: 28),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PANDUAN • BAGIAN ${widget.unit.section}, UNIT ${widget.unit.unit}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onColor.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.unit.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, color: Colors.white24, size: 64),

            SizedBox(height: 16),

            Text(
              'Panduan untuk unit ini belum tersedia.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(GuideBlock block) {
    final body = block.body;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            block.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          if (body != null && body.isNotEmpty) ...[
            const SizedBox(height: 8),

            Text(
              body,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],

          if (block.items.isNotEmpty) ...[
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border, width: 2),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < block.items.length; i++) ...[
                    _buildRow(block.items[i]),

                    if (i < block.items.length - 1)
                      const Divider(height: 1, thickness: 1, color: _border),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(GuideItem item) {
    final romaji = item.romanization ?? '';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _speak(item.text),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: _blue, size: 28),

            const SizedBox(width: 14),

            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (romaji.isNotEmpty)
                    Text(
                      romaji,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),

                  Text(
                    item.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 4,
              child: Text(
                item.meaning,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Button3D(
          color: _yellow,
          lipColor: _yellowDark,
          holdBeforeTap: true,
          onTap: () => Navigator.pop(context),
          height: 52,
          depth: 5,
          radius: 16,
          alignment: Alignment.center,
          child: const Text(
            'MENGERTI',
            style: TextStyle(
              color: _onYellow,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
