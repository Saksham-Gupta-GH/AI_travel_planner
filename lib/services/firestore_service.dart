import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/package_model.dart';
import '../models/booking_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USERS ====================

  // Create user
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // Get all users
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // ==================== PACKAGES ====================

  // Create package
  Future<String> createPackage(PackageModel package) async {
    final docRef = await _firestore.collection('packages').add(package.toMap());
    return docRef.id;
  }

  // Get all packages
  Stream<List<PackageModel>> getAllPackages() {
    return _firestore
        .collection('packages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PackageModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Get packages by agent
  Stream<List<PackageModel>> getPackagesByAgent(String agentId) {
    return _firestore
        .collection('packages')
        .where('agentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PackageModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Get package by ID
  Future<PackageModel?> getPackage(String packageId) async {
    final doc = await _firestore.collection('packages').doc(packageId).get();
    if (doc.exists && doc.data() != null) {
      return PackageModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // Update package
  Future<void> updatePackage(
    String packageId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('packages').doc(packageId).update(data);
  }

  // Delete package
  Future<void> deletePackage(String packageId) async {
    await _firestore.collection('packages').doc(packageId).delete();
  }

  // Filter packages by budget and destination
  Future<List<PackageModel>> filterPackages({
    double? maxBudget,
    String? destination,
  }) async {
    Query query = _firestore.collection('packages');

    // Fetch all for budget first (or just all if no budget)
    final snapshot = await query.get();
    var packages = snapshot.docs
        .map(
          (doc) =>
              PackageModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();

    if (maxBudget != null) {
      packages = packages.where((p) => p.price <= maxBudget).toList();
    }

    if (destination != null && destination.isNotEmpty) {
      final searchLower = destination.toLowerCase();
      packages = packages.where((p) => 
          p.destination.toLowerCase().contains(searchLower) || 
          p.address.toLowerCase().contains(searchLower) ||
          p.highlights.any((h) => h.toLowerCase().contains(searchLower))
      ).toList();
    }

    return packages;
  }

  // ==================== BOOKINGS ====================

  // Create booking
  Future<String> createBooking(BookingModel booking) async {
    final docRef = await _firestore.collection('bookings').add(booking.toMap());
    return docRef.id;
  }

  // Get bookings by user
  Stream<List<BookingModel>> getBookingsByUser(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Get all bookings
  Stream<List<BookingModel>> getAllBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Get bookings for agent's packages
  Stream<List<BookingModel>> getBookingsForAgent(String agentId) {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          // We need to filter by agentId through package lookup
          // For simplicity, we'll return all and filter in UI
          return snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // Update booking status
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status.name,
    });
  }

  // Confirm booking with an optional message to the traveller
  Future<void> confirmBookingWithMessage(String bookingId, String message) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.confirmed.name,
      'agentMessage': message.trim().isEmpty ? null : message.trim(),
    });
  }

  // Decline booking with reason
  Future<void> declineBooking(String bookingId, String reason) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.declined.name,
      'declineReason': reason,
    });
  }

  // Delete booking
  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }

  // Reviews
  Future<void> createReview(ReviewModel review) async {
    await _firestore.collection('reviews').add(review.toMap());
  }

  Stream<List<ReviewModel>> getReviewsForPackage(String packageId) {
    return _firestore
        .collection('reviews')
        .where('packageId', isEqualTo: packageId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // ==================== STATISTICS ====================

  // Get dashboard statistics
  Future<Map<String, int>> getStatistics() async {
    final users = await _firestore.collection('users').get();
    final packages = await _firestore.collection('packages').get();
    final bookings = await _firestore.collection('bookings').get();
    final userDocs = users.docs
        .map((doc) => UserModel.fromMap(doc.id, doc.data()))
        .toList();

    return {
      'totalUsers': userDocs.length,
      'totalAgents': userDocs.where((user) => user.role == 'agent').length,
      'totalTravelers': userDocs
          .where((user) => user.role == 'traveler')
          .length,
      'totalAdmins': userDocs.where((user) => user.role == 'admin').length,
      'totalPackages': packages.docs.length,
      'totalBookings': bookings.docs.length,
    };
  }

  // Get popular destinations
  Future<List<Map<String, dynamic>>> getPopularDestinations() async {
    final bookings = await _firestore.collection('bookings').get();
    final Map<String, int> destinationCount = {};

    for (var doc in bookings.docs) {
      final destination = doc.data()['packageDestination'] as String?;
      if (destination != null) {
        destinationCount[destination] =
            (destinationCount[destination] ?? 0) + 1;
      }
    }

    if (destinationCount.isEmpty) {
      final packages = await _firestore.collection('packages').get();
      for (var doc in packages.docs) {
        final destination = doc.data()['destination'] as String?;
        if (destination != null) {
          destinationCount[destination] =
              (destinationCount[destination] ?? 0) + 1;
        }
      }
    }

    var sortedDestinations = destinationCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedDestinations
        .take(5)
        .map((e) => {'destination': e.key, 'count': e.value})
        .toList();
  }
}
