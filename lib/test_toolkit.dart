library test_toolkit;

import 'dart:mirrors';

import 'package:log4dart/log4dart.dart';
import 'package:unittest/unittest.dart';

final _logger = LoggerFactory.getLogger("test_toolkit");

/**
 *
 */
class TestCase {

  TestCase();

  /**
   *
   */
  void setUp() {}

  /**
   *
   */
  void tearDown() {}

  /**
   *
   */
  void call() {
    run();
  }

  /**
   *
   */
  void run() {
    var instanceMirror = reflect(this);
    var classMirror = instanceMirror.type;

    for (var symbol in classMirror.methods.keys) {
      var name = MirrorSystem.getName(symbol);
      if (!_isTestMethod(name)) {
        continue;
      }

      var method = classMirror.methods[symbol];

      // Skip runTest method if its not implemented in the child class.
      var owner = MirrorSystem.getName(method.owner.simpleName);
      if (name == 'runTest' && owner.startsWith('TestCase')) {
        continue;
      }

      var description = _getDescription(method);
      _logger.info('Running test $name: $description.');

      test(description, () {
        setUp();
        instanceMirror.invoke(symbol, []);
        tearDown();
      });
    }
  }

  /**
   *
   */
  void runTest() {}

  bool _isTestMethod(String name) {
    return name.startsWith('test') || name == 'runTest';
  }

  String _getDescription(MethodMirror method) {
    var description = MirrorSystem.getName(method.simpleName);
    for (var descriptor in method.metadata) {
      if (descriptor.reflectee is testdoc) {
        description = descriptor.reflectee.doc;
      }
    }
    return description;
  }
}

/**
 *
 */
class testdoc {
  final String doc;
  const testdoc(this.doc);
}