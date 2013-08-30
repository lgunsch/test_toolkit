library test_toolkit;

import 'dart:mirrors';

import 'package:log4dart/log4dart.dart';
import 'package:unittest/unittest.dart' as unittest;

final _logger = LoggerFactory.getLogger("test_toolkit");

/**
 *
 */
class TestGroup {

  TestGroup();

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
  void groupRun([String description]) {
    var classMirror = reflect(this).type;
    if (description == null) {
      description = MirrorSystem.getName(classMirror.simpleName);
    }

    // Prefer groupdoc over description passed in as a parameter
    var descriptors = classMirror.metadata;
    for (var descriptor in descriptors) {
      if (descriptor.reflectee is groupdoc) {
        description = descriptor.reflectee.doc;
      }
    }
    unittest.group(description, this.run);
  }

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

      unittest.setUp(this.setUp);
      unittest.tearDown(this.tearDown);
      unittest.test(description, () => instanceMirror.invoke(symbol, []));
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
class groupdoc {
  final String doc;
  const groupdoc(this.doc);
}


/**
 *
 */
class testdoc {
  final String doc;
  const testdoc(this.doc);
}
