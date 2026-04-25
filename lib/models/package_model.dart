class PackageModel {
  final String id;
  final String agentId;
  final String agentName;
  final String destination;
  final String address;
  final double price;
  final int duration; // in days
  final String description;
  final List<String> imageUrls;
  final double? latitude;
  final double? longitude;
  final List<String> itinerary;
  final List<String> highlights;
  final DateTime createdAt;

  PackageModel({
    required this.id,
    required this.agentId,
    required this.agentName,
    required this.destination,
    required this.address,
    required this.price,
    required this.duration,
    required this.description,
    required this.imageUrls,
    this.latitude,
    this.longitude,
    required this.itinerary,
    required this.highlights,
    required this.createdAt,
  });

  factory PackageModel.fromMap(String id, Map<String, dynamic> map) {
    // Migration logic: if 'imageUrl' exists but 'imageUrls' doesn't, convert to list
    List<String> images = [];
    if (map['imageUrls'] != null) {
      images = List<String>.from(map['imageUrls']);
    } else if (map['imageUrl'] != null && (map['imageUrl'] as String).isNotEmpty) {
      images = [map['imageUrl']];
    }

    return PackageModel(
      id: id,
      agentId: map['agentId'] ?? '',
      agentName: map['agentName'] ?? '',
      destination: map['destination'] ?? '',
      address: map['address'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      duration: map['duration'] ?? 0,
      description: map['description'] ?? '',
      imageUrls: images,
      latitude: (map['latitude'] as dynamic)?.toDouble(),
      longitude: (map['longitude'] as dynamic)?.toDouble(),
      itinerary: List<String>.from(map['itinerary'] ?? []),
      highlights: List<String>.from(map['highlights'] ?? []),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'agentId': agentId,
      'agentName': agentName,
      'destination': destination,
      'address': address,
      'price': price,
      'duration': duration,
      'description': description,
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'itinerary': itinerary,
      'highlights': highlights,
      'createdAt': createdAt,
    };
  }

  PackageModel copyWith({
    String? id,
    String? agentId,
    String? agentName,
    String? destination,
    String? address,
    double? price,
    int? duration,
    String? description,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
    List<String>? itinerary,
    List<String>? highlights,
    DateTime? createdAt,
  }) {
    return PackageModel(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      destination: destination ?? this.destination,
      address: address ?? this.address,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      itinerary: itinerary ?? this.itinerary,
      highlights: highlights ?? this.highlights,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
