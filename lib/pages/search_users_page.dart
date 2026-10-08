import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/profile_service.dart';
import '../widgets/friend_tile.dart';
import '../widgets/user_card_dialog.dart';

// Cari user lewat username/nama. Tanpa kata kunci, yang tampil adalah saran.
class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final _controller = TextEditingController();
  Timer? _debounce;

  List<FriendUser> _users = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = text.trim();
      if (q != _query) _load(q);
    });
  }

  Future<void> _load([String query = '']) async {
    setState(() {
      _query = query;
      _loading = true;
      _error = null;
    });
    try {
      final users = await ProfileService.searchUsers(query);
      // abaikan hasil lama kalau user sudah mengetik hal lain
      if (!mounted || query != _query) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || query != _query) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _view(FriendUser user) async {
    final changed = await showUserCardDialog(context, user);
    if (changed) {
      _changed = true;
      _load(_query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF272F33),
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context, _changed),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              style: GoogleFonts.baloo2(color: Colors.white, fontSize: 18),
              cursorColor: const Color(0xFF55B6E8),
              decoration: InputDecoration(
                hintText: 'Search by username',
                hintStyle: GoogleFonts.baloo2(
                  color: Colors.white38,
                  fontSize: 18,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white54,
                ),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          _controller.clear();
                          _debounce?.cancel();
                          _load();
                        },
                      ),
                filled: true,
                fillColor: const Color(0xFF20272B),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF38474C),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF55B6E8),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.baloo2(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    final searching = _query.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4),
          child: Text(
            searching ? 'RESULTS' : 'SUGGESTIONS',
            style: GoogleFonts.pixelifySans(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ),
        if (_users.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Image.asset('assets/app/qua.gif', height: 110),
                const SizedBox(height: 12),
                Text(
                  searching
                      ? 'No player found for "$_query".'
                      : 'No suggestions right now.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    color: Colors.white70,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        for (final user in _users)
          FriendTile(user: user, onAction: () => _view(user)),
      ],
    );
  }
}
