// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonModelGenerator
// **************************************************************************

@generatedSerializable
class Todo extends _Todo {
  Todo({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.text,
    this.isComplete,
  });

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
  String? text;

  @override
  bool? isComplete;

  Todo copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? text,
    bool? isComplete,
  }) {
    return Todo(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        text: text ?? this.text,
        isComplete: isComplete ?? this.isComplete);
  }

  @override
  bool operator ==(other) {
    return other is _Todo &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.text == text &&
        other.isComplete == isComplete;
  }

  @override
  int get hashCode {
    return hashObjects([
      id,
      createdAt,
      updatedAt,
      text,
      isComplete,
    ]);
  }

  @override
  String toString() {
    return 'Todo(id=$id, createdAt=$createdAt, updatedAt=$updatedAt, text=$text, isComplete=$isComplete)';
  }

  Map<String, dynamic> toJson() {
    return TodoSerializer.toMap(this);
  }
}

// **************************************************************************
// SerializerGenerator
// **************************************************************************

const TodoSerializer todoSerializer = TodoSerializer();

class TodoEncoder extends Converter<Todo, Map> {
  const TodoEncoder();

  @override
  Map convert(Todo model) => TodoSerializer.toMap(model);
}

class TodoDecoder extends Converter<Map, Todo> {
  const TodoDecoder();

  @override
  Todo convert(Map map) => TodoSerializer.fromMap(map);
}

class TodoSerializer extends Codec<Todo, Map> {
  const TodoSerializer();

  @override
  TodoEncoder get encoder => const TodoEncoder();

  @override
  TodoDecoder get decoder => const TodoDecoder();

  static Todo fromMap(Map map) {
    return Todo(
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
        text: map['text'] as String?,
        isComplete: map['is_complete'] as bool?);
  }

  static Map<String, dynamic> toMap(_Todo? model) {
    if (model == null) {
      throw FormatException("Required field [model] cannot be null");
    }
    return {
      'id': model.id,
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String(),
      'text': model.text,
      'is_complete': model.isComplete
    };
  }
}

abstract class TodoFields {
  static const List<String> allFields = <String>[
    id,
    createdAt,
    updatedAt,
    text,
    isComplete,
  ];

  static const String id = 'id';

  static const String createdAt = 'created_at';

  static const String updatedAt = 'updated_at';

  static const String text = 'text';

  static const String isComplete = 'is_complete';
}

// **************************************************************************
// _GraphQLGenerator
// **************************************************************************

/// Auto-generated from [Todo].
final GraphQLObjectType todoGraphQLType = objectType(
  'Todo',
  isInterface: false,
  interfaces: [],
  fields: [
    field(
      'id',
      graphQLString,
    ),
    field(
      'created_at',
      graphQLDate,
    ),
    field(
      'updated_at',
      graphQLDate,
    ),
    field(
      'text',
      graphQLString,
    ),
    field(
      'is_complete',
      graphQLBoolean,
    ),
    field(
      'idAsInt',
      graphQLInt,
    ),
    field(
      'idAsString',
      graphQLString,
    ),
  ],
);
