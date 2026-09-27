import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../meal.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser!.uid;

  static Future<void> addMeal(Meal meal) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('meals')
        .doc(meal.id)
        .set({
      'type': meal.type,
      'name': meal.name,
      'location': meal.location,
      'amount': meal.amount,
      'note': meal.note,
      'createdAt': meal.createdAt,
      'category': meal.category,
    });
  }

  static Stream<List<Meal>> getMeals() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('meals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Meal(
                id: doc.id,
                type: data['type'],
                name: data['name'],
                location: data['location'],
                amount: (data['amount'] as num).toDouble(),
                note: data['note'],
                createdAt: (data['createdAt'] as Timestamp).toDate(),
                category: data['category'], // null for meals logged before this update
              );
            }).toList());
  }

  static Future<void> deleteMeal(String id) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('meals')
        .doc(id)
        .delete();
  }

  static Future<void> updateMeal(Meal meal) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('meals')
        .doc(meal.id)
        .update({
      'type': meal.type,
      'name': meal.name,
      'location': meal.location,
      'amount': meal.amount,
      'note': meal.note,
      'createdAt': meal.createdAt,
      'category': meal.category,
    });
  }

  static Future<void> deleteAllMeals() async {
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('meals')
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}