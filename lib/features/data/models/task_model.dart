class TaskModel {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final String date;

  TaskModel(
      {required this.id,
      required this.title,
      required this.imageUrl,
      required this.description,
      required this.date});

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
