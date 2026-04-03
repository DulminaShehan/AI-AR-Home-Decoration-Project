/// A single AI-generated design suggestion shown in the panel.
class AiSuggestion {
  final String icon;   // emoji icon
  final String title;
  final String body;

  const AiSuggestion({
    required this.icon,
    required this.title,
    required this.body,
  });
}
