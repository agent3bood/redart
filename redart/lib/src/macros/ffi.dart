library redart;

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:macros/macros.dart';
import 'package:path/path.dart' as path;

macro class DyLib implements ClassDeclarationsMacro {
  final String name;

  const DyLib(this.name);

  @override
  Future<void> buildDeclarationsForClass(ClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    final joinIdentifier = await builder.resolveIdentifier(
        Uri.parse('package:path/path.dart'), 'join');
    final directoryIdentifier = await builder.resolveIdentifier(
        Uri.parse('dart:io'), 'Directory');

    // final libraryPath = path.join(Directory.current.path, 'primitives_library', 'libprimitives.so');
    final dylibPath = DeclarationCode.fromParts([
      'late final dylibPath = ',
      joinIdentifier,
      '(',
      directoryIdentifier, '.current.path, ',
      '"$name", ',
      '"$name.so"',
      ');',
    ]);

    // final dylib = DynamicLibrary.open(dylibPath);
    final dynamicLibraryIdentifier = await builder.resolveIdentifier(
        Uri.parse('dart:ffi'), 'DynamicLibrary');
    final dylib = DeclarationCode.fromParts([
      'late final dylib = ',
      dynamicLibraryIdentifier, '.open(dylibPath);',
    ]);

    builder.declareInType(dylibPath);
    builder.declareInType(dylib);
  }
}

macro class Ffi implements MethodDeclarationsMacro, MethodTypesMacro {
  const Ffi();

  @override
  Future<void> buildDeclarationsForMethod(MethodDeclaration method,
      MemberDeclarationBuilder builder) async {
    if (method.namedParameters.isNotEmpty) {
      throw UnsupportedError("Named parameters are not supported.");
    }
    if (method.typeParameters.isNotEmpty) {
      throw UnsupportedError("Type parameters are not supported.");
    }
    if (!method.hasExternal) {
      throw UnsupportedError("Method must be external");
    }

    final name = method.identifier.name;
    String publicName = name;
    if (!publicName.startsWith('_')) {
      throw UnsupportedError("Method name must start with underscore.");
    }
    while (publicName.startsWith('_')) {
      publicName = publicName.substring(1);
    }

    final ffiTypeName = '${name}NativeFunction';
    final dartTypeName = '${name}DartFunction';
    // final ffiType = await builder.resolveIdentifier(method.library.uri, ffiTypeName);
    // final dartType = await builder.resolveIdentifier(method.library.uri, dartTypeName);
    final ffiMethod = DeclarationCode.fromParts([
      method.returnType.code,
      ' $publicName',
      '(',
      ...method.positionalParameters.map((e) {
        return e.code;
      }),
      ') \n',
      '{\n',
      // 'final pointer = dylib.lookup("$publicName");\n',
      // RawCode.fromString('return pointer.lookupFunction<$ffiTypeName, $dartTypeName>().call('),
      // // 'return pointer.lookupFunction<$ffiType, $dartType>().call(',
      // ...method.positionalParameters.map((e) {
      //   return e.identifier;
      // }),
      // ');\n',
      '}',
    ]);

    builder.declareInType(ffiMethod);
  }

  @override
  Future<void> buildTypesForMethod(MethodDeclaration method,
      TypeBuilder builder) async {
    final name = method.identifier.name;

    final ffiTypeName = '${name}NativeFunction';
    final ffiType = DeclarationCode.fromParts(
        [
          'typedef ',
          '$ffiTypeName = ',
          await _getNativeType(builder, method.returnType.code),
          ' ',
          'Function(',
          ...(await Future.wait(method.positionalParameters.map((e) async {
            return DeclarationCode.fromParts([
              await _getNativeType(builder, e.type.code),
              ' ',
              e.identifier,
            ]);
          }))),
          ');',
        ]
    );

    final dartTypeName = '${name}DartFunction';
    final dartType = DeclarationCode.fromParts(
        [
          'typedef ',
          '$dartTypeName = ',
          await _getDartType(builder, method.returnType.code),
          // method.returnType.code,
          ' ',
          'Function(',
          ...(await Future.wait(method.positionalParameters.map((e) async {
            return DeclarationCode.fromParts([
              await _getDartType(builder, e.type.code),
              // e.type.code,
              ' ',
              e.identifier,
            ]);
          }))),
          ');',
        ]
    );
    builder.declareType(ffiTypeName, ffiType);
    builder.declareType(dartTypeName, dartType);
  }

  Future<Object> _getNativeType(TypeBuilder builder,
      TypeAnnotationCode type) async {
    final name = (type as NamedTypeAnnotationCode).name.name;
    switch (name) {
      case 'void':
        return builder.resolveIdentifier(
            Uri.parse('dart:ffi'), 'Void');
      case 'String':
        {
          final pointer = await builder.resolveIdentifier(
              Uri.parse('dart:ffi'), 'Pointer');
          final utf8 = await builder.resolveIdentifier(
              Uri.parse('package:ffi/src/utf8.dart'), 'Utf8');

          return NamedTypeAnnotationCode(name: pointer, typeArguments: [
            RawTypeAnnotationCode.fromParts([utf8])
          ]);
        }
      default:
        throw UnsupportedError('Unsupported native type $name');
    }
  }

  Future<Object> _getDartType(TypeBuilder builder, TypeAnnotationCode type) async {
    var name = (type as NamedTypeAnnotationCode).name.name;
    if(name == 'void') {
      return Future.value('void');
    }
    name = '${name[0].toUpperCase()}${name.substring(1)}';
    return builder.resolveIdentifier(Uri.parse('dart:core'), name);
  }
}
