import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart' as internal;

class Protocol extends SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  String getModuleName() => 'dart_hello';

  @override
  Table? getTableForType(Type t) => null;

  @override
  List<internal.TableDefinition> getTargetTableDefinitions() => [];
}
