// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'greeting.dart';

// **************************************************************************
// JsonModelGenerator
// **************************************************************************

@generatedSerializable
class Greeting extends _Greeting {
  Greeting({this.id, this.createdAt, this.updatedAt, required this.message});

  /// A unique identifier corresponding to this item.
  @override
  String? id;

  /// The time at which this item was created.
  @override
  DateTime? createdAt;

  /// The last time at which this item was updated.
  @override
  DateTime? updatedAt;

  @override
  String? message;

  Greeting copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? message,
  }) {
    return Greeting(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(other) {
    return other is _Greeting &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.message == message;
  }

  @override
  int get hashCode {
    return Object.hashAll([id, createdAt, updatedAt, message]);
  }

  @override
  String toString() {
    return 'Greeting(id=$id, createdAt=$createdAt, updatedAt=$updatedAt, message=$message)';
  }

  Map<String, dynamic> toJson() {
    return GreetingSerializer.toMap(this);
  }
}

// **************************************************************************
// SerializerGenerator
// **************************************************************************

const GreetingSerializer greetingSerializer = GreetingSerializer();

class GreetingEncoder extends Converter<Greeting, Map> {
  const GreetingEncoder();

  @override
  Map convert(Greeting model) => GreetingSerializer.toMap(model);
}

class GreetingDecoder extends Converter<Map, Greeting> {
  const GreetingDecoder();

  @override
  Greeting convert(Map map) => GreetingSerializer.fromMap(map);
}

class GreetingSerializer extends Codec<Greeting, Map> {
  const GreetingSerializer();

  @override
  GreetingEncoder get encoder => const GreetingEncoder();

  @override
  GreetingDecoder get decoder => const GreetingDecoder();

  static Greeting fromMap(Map map) {
    if (map['message'] == null) {
      throw FormatException("Missing required field 'message' on Greeting.");
    }

    return Greeting(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? (map['created_at'] is DateTime
                ? (map['created_at'] as DateTime)
                : DateTime.parse(map['created_at'].toString()))
          : null,
      updatedAt: map['updated_at'] != null
          ? (map['updated_at'] is DateTime
                ? (map['updated_at'] as DateTime)
                : DateTime.parse(map['updated_at'].toString()))
          : null,
      message: map['message'] as String?,
    );
  }

  static Map<String, dynamic> toMap(_Greeting? model) {
    if (model == null) {
      throw FormatException("Required field [model] cannot be null");
    }
    return {
      'id': model.id,
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String(),
      'message': model.message,
    };
  }
}

abstract class GreetingFields {
  static const List<String> allFields = <String>[
    id,
    createdAt,
    updatedAt,
    message,
  ];

  static const String id = 'id';

  static const String createdAt = 'created_at';

  static const String updatedAt = 'updated_at';

  static const String message = 'message';
}
