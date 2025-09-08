import 'package:cloud_firestore/cloud_firestore.dart';

class ConfigService {
  static Future<String?> getBaseUrl() async {
    final doc = await FirebaseFirestore.instance
        .collection('configs')
        .doc('api')
        .get();
    return doc.data()?['owner_base_url'] as String?;
  }
}