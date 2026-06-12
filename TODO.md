# TODO - Dark Mode & UI Upgrade (Journal & Mood)

## Done
- [x] Identifikasi file terkait dark mode: `journal_screen.dart`, `mood_tracker_screen.dart`.
- [x] Analisis Theme system: `app_theme.dart`, `theme_provider.dart`, `main.dart`.
- [x] Update `JournalScreen` agar sepenuhnya theme-aware (hapus hardcode light) + perbaikan struktur widget.

## In Progress
- [ ] Update `MoodTrackerScreen` agar tidak hardcode warna light (bg/card/text, bottom sheet).
- [ ] Upgrade tampilan `MoodTrackerScreen` (kartu list lebih smooth & modern).

## Next
- [ ] (Opsional sesuai hasil cek) Update `relaxation_screen.dart` jika ditemukan hardcode warna light.
- [ ] Jalankan `flutter analyze` dan `flutter test`.
- [ ] Manual test: toggle dark mode pada Journal list/editor dan Mood list/bottom sheet.

