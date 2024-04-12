library redart;

import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

macro

class Re implements FieldDeclarationsMacro /*, MethodDeclarationsMacro*/ {
  const Re();

  @override
  Future<void> buildDeclarationsForField(FieldDeclaration field,
      MemberDeclarationBuilder builder) async {
    final name = field.identifier.name;
    if (!name.startsWith('_')) {
      throw ArgumentError('Reactive fields must start with an underscore');
    }
    String publicName = name;
    while (publicName.startsWith('_')) {
      publicName = publicName.substring(1);
    }

    final Identifier listIdentifier =
    await builder.resolveIdentifier(Uri.parse('dart:core'), 'List');
    final Identifier functionIdentifier =
    await builder.resolveIdentifier(Uri.parse('dart:core'), 'Function');
    final Identifier callbackIdentifier = await builder.resolveIdentifier(
        Uri.parse('package:redart/src/types.dart'), 'Callback');
    final Identifier reListenerIdentifier = await builder.resolveIdentifier(
        Uri.parse('package:redart/src/globals.dart'), 'reListener');
    final Identifier reReadWithoutListeningIdentifier = await builder
        .resolveIdentifier(
        Uri.parse('package:redart/src/globals.dart'),
        'reReadWithoutListening');

    builder.declareInType(_fieldListeners(
      publicName: publicName,
      listIdentifier: listIdentifier,
      callbackIdentifier: callbackIdentifier,
    ));

    builder.declareInType(_fieldGetter(
      field: field,
      publicName: publicName,
      reListener: reListenerIdentifier,
      reReadWithoutListening: reReadWithoutListeningIdentifier,
    ));

    builder.declareInType(_fieldSetter(
      field: field,
      publicName: publicName,
      functionIdentifier: functionIdentifier,
    ));
  }

  DeclarationCode _fieldListeners({
    required String publicName,
    required Identifier listIdentifier,
    required Identifier callbackIdentifier
  }) {
    return DeclarationCode.fromParts([
      listIdentifier,
      '<',
      callbackIdentifier,
      '>? _${publicName}Listeners;\n',
    ]);
  }

  DeclarationCode _fieldGetter({
    required FieldDeclaration field,
    required String publicName,
    required Identifier reListener,
    required Identifier reReadWithoutListening,
  }) {
    return DeclarationCode.fromParts([
      field.type.code, ' get $publicName {\n',
      '  ', 'final prevListener = ', reListener, ';\n',
      '  ', 'if (', reReadWithoutListening, ') {\n',
      '    ', reListener, ' = null;\n',
      '  ', '}\n',
      '  ', 'final val = ', field.identifier, ';\n',
      '  ', 'if (', reListener, ' != null) {\n',
      '    ', '_${publicName}Listeners ??= [];\n',
      '    ', 'if (!_${publicName}Listeners!.contains(', reListener, '!.\$1)) {\n',
      '      ', '_${publicName}Listeners!.add(', reListener, '!.\$1);\n',
      '      ', reListener, '!.\$2.add(_${publicName}Listeners!);\n',
      '    ', '}\n',
      '  ', '}\n',
      '  ', reListener, ' = prevListener;\n',
      '  ', 'return val;\n',
      '}',
    ]);
  }

  DeclarationCode _fieldSetter({
    required FieldDeclaration field,
    required String publicName,
    required Identifier functionIdentifier,
  }) {
    return DeclarationCode.fromParts([
      'set $publicName(', field.type.code, ' val) {\n',
      '  ', field.identifier, ' = val;\n',
      '  ', 'if (_${publicName}Listeners != null) {\n',
      '    ', 'for (final listener in _${publicName}Listeners!) {\n',
      '      ', 'if (listener is ', functionIdentifier, ') {\n',
      '        ', 'scheduleCallback(listener);\n',
      '      ', '}\n',
      '    ', '}\n',
      '  ', '}\n',
      '}',
    ]);
  }

  // methods & getters can be memoized, not reactive
  // @override
  // FutureOr<void> buildDeclarationsForMethod(MethodDeclaration method,
  //     MemberDeclarationBuilder builder) {
  //   if (method.isGetter) {
  //     return _buildDeclarationsForGetter(method, builder);
  //   }
  // }
  //
  // Future<void> _buildDeclarationsForGetter(MethodDeclaration method,
  //     MemberDeclarationBuilder builder) async {
  //   final name = method.identifier.name;
  //   if (!name.startsWith('_')) {
  //     throw ArgumentError('Reactive fields must start with an underscore');
  //   }
  //   final String privateName = '_$name';
  //   String publicName = name;
  //   while (publicName.startsWith('_')) {
  //     publicName = publicName.substring(1);
  //   }
  //
  //   final Identifier boolIdentifier =
  //   await builder.resolveIdentifier(Uri.parse('dart:core'), 'bool');
  //   final Identifier reListenerIdentifier = await builder.resolveIdentifier(
  //       Uri.parse('package:redart/src/globals.dart'), 'reListener');
  //   final Identifier listenIdentifier = await builder.resolveIdentifier(
  //       Uri.parse('package:redart/src/listen.dart'), 'listen');
  //
  //   final listening = DeclarationCode.fromParts([
  //     boolIdentifier, ' ${privateName}Listening = false;\n',
  //   ]);
  //   builder.declareInType(listening);
  //
  //   final privateField = DeclarationCode.fromParts([
  //     'late ', method.returnType.code, ' $privateName;',
  //   ]);
  //   builder.declareInType(privateField);
  //
  //
  //   final getter = DeclarationCode.fromParts([
  //     method.returnType.code, ' get $publicName {\n',
  //     '  ', 'if(!${privateName}Listening) {\n',
  //     '    ', 'var prevListener = ', reListenerIdentifier, ';\n',
  //     '    ', 'final dispose = ', listenIdentifier, '(() {\n',
  //     '      ', '$privateName = $name;\n',
  //     '      ', 'if(${privateName}Listening) {\n',
  //     '        ', 'prevListener?.\$1();\n',
  //     '      ', '}\n',
  //     '    ', '});\n',
  //     '    ', 'disposeListeners.add(() {\n',
  //     '      ', 'prevListener = null;\n',
  //     '      ', 'dispose();\n',
  //     '    ', '});\n',
  //     '    ', '${privateName}Listening = true;\n',
  //     '  ', '}\n',
  //     '  ', 'return $privateName;\n',
  //     '}',
  //   ]);
  //   builder.declareInType(getter);
  // }
}
