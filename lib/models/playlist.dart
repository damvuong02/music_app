class Playlist {
  final int id;
  final String name;
  final String image;
  final String? author;

  Playlist(
      {required this.id, required this.name, required this.image, this.author});

  Playlist copyWith({
    int? id,
    String? name,
    String? image,
    String? author,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      author: author ?? this.author,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'author': author,
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
        id: map['id'],
        name: map['name'],
        image: map['image'],
        author: map['author']);
  }
}
