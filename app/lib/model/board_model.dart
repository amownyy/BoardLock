class Board {
  final String name;

  Board({required this.name});

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(name: json['name']);
  }
}
