import 'dart:convert';
import 'dart:typed_data';

class Disease {
  final Map<String, dynamic> data;
  Disease(this.data);
  String get id => data['id'];
  String get name => data['name'];
  String get category => data['category'];
  String get scientific => data['scientific'];
  String symptoms(String lang) =>
      data[lang == 'te' ? 'symptoms_te' : 'symptoms'];
}

class ScanRecord {
  final String id, diseaseId;
  final double confidence;
  final bool demo;
  final DateTime created;
  final Uint8List image;
  ScanRecord({
    required this.id,
    required this.diseaseId,
    required this.confidence,
    required this.demo,
    required this.created,
    required this.image,
  });
  factory ScanRecord.fromJson(Map<String, dynamic> j) => ScanRecord(
    id: j['id'],
    diseaseId: j['disease_id'],
    confidence: (j['confidence'] as num).toDouble(),
    demo: j['demo'],
    created: DateTime.parse(j['created_at']),
    image: base64Decode(j['image']),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'disease_id': diseaseId,
    'confidence': confidence,
    'demo': demo,
    'created_at': created.toIso8601String(),
    'image': base64Encode(image),
  };
}
