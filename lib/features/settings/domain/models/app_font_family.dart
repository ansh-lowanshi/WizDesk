/// Supported Font Families in Wiz Desk
enum AppFontFamily {
  plusJakartaSans(
    'plusJakartaSans',
    'Plus Jakarta Sans',
    'Modern & Sleek',
  ),
  spaceGrotesk(
    'spaceGrotesk',
    'Space Grotesk',
    'Tech & Futuristic',
  ),
  inter(
    'inter',
    'Inter',
    'Minimal & Clean',
  ),
  outfit(
    'outfit',
    'Outfit',
    'Bold & Expressive',
  );

  final String id;
  final String displayName;
  final String subtitle;

  const AppFontFamily(this.id, this.displayName, this.subtitle);

  static AppFontFamily fromId(String? id) {
    return AppFontFamily.values.firstWhere(
      (f) => f.id == id,
      orElse: () => AppFontFamily.plusJakartaSans,
    );
  }
}
