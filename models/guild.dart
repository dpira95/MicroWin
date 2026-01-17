class Guild {
  final String id;
  final String name;
  final String description;
  final int members;
  final String goal;
  final int progress; // 0..100

  const Guild({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.goal,
    required this.progress,
  });
}
