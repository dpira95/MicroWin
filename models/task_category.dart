enum TaskCategory  { work, study, home, health, social, other }

extension CategoryX on TaskCategory  {
  static TaskCategory  fromString(String v) {
    switch (v.toLowerCase()) {
      case 'work':
        return TaskCategory .work;
      case 'study':
        return TaskCategory .study;
      case 'home':
        return TaskCategory .home;
      case 'health':
        return TaskCategory .health;
      case 'social':
        return TaskCategory .social;
      case 'other':
      default:
        return TaskCategory .other;
    }
  }

  String get key => name; // "work", "study", ...
}
