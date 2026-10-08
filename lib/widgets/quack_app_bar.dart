import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// AppBar standar untuk halaman turunan profil: latar gelap, judul Baloo,
// dan garis bawah tipis.
PreferredSizeWidget quackAppBar(String title, {PreferredSizeWidget? bottom}) {
  return AppBar(
    backgroundColor: const Color(0xFF272F33),
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    title: Text(
      title,
      style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 22),
    ),
    bottom:
        bottom ??
        PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: const Color(0xFF38474C)),
        ),
  );
}
