enum BookingStatus { pending, confirmed, cancelled, declined }

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String packageId;
  final String packageDestination;
  final double packagePrice;
  final int numPeople; // New field
  final DateTime travelDate;
  final String paymentMethod;
  final String paymentDetails;
  final String qrCodeData;
  final BookingStatus status;
  final String? declineReason;
  final String? agentMessage; // Message from agent on confirmation
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.packageId,
    required this.packageDestination,
    required this.packagePrice,
    required this.numPeople,
    required this.travelDate,
    required this.paymentMethod,
    required this.paymentDetails,
    required this.qrCodeData,
    required this.status,
    this.declineReason,
    this.agentMessage,
    required this.createdAt,
  });

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      packageId: map['packageId'] ?? '',
      packageDestination: map['packageDestination'] ?? '',
      packagePrice: (map['packagePrice'] ?? 0).toDouble(),
      numPeople: map['numPeople'] ?? 1,
      travelDate: (map['travelDate'] as dynamic)?.toDate() ?? DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? '',
      paymentDetails: map['paymentDetails'] ?? '',
      qrCodeData: map['qrCodeData'] ?? '',
      status: _statusFromString(map['status'] ?? 'pending'),
      declineReason: map['declineReason'],
      agentMessage: map['agentMessage'],
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'packageId': packageId,
      'packageDestination': packageDestination,
      'packagePrice': packagePrice,
      'numPeople': numPeople,
      'travelDate': travelDate,
      'paymentMethod': paymentMethod,
      'paymentDetails': paymentDetails,
      'qrCodeData': qrCodeData,
      'status': status.name,
      'declineReason': declineReason,
      'agentMessage': agentMessage,
      'createdAt': createdAt,
    };
  }

  static BookingStatus _statusFromString(String status) {
    switch (status) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'declined':
        return BookingStatus.declined;
      default:
        return BookingStatus.pending;
    }
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? packageId,
    String? packageDestination,
    double? packagePrice,
    int? numPeople,
    DateTime? travelDate,
    String? paymentMethod,
    String? paymentDetails,
    String? qrCodeData,
    BookingStatus? status,
    String? declineReason,
    String? agentMessage,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      packageId: packageId ?? this.packageId,
      packageDestination: packageDestination ?? this.packageDestination,
      packagePrice: packagePrice ?? this.packagePrice,
      numPeople: numPeople ?? this.numPeople,
      travelDate: travelDate ?? this.travelDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      status: status ?? this.status,
      declineReason: declineReason ?? this.declineReason,
      agentMessage: agentMessage ?? this.agentMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
