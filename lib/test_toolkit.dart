// Copyright © 2013 Lewis Gunsch and contributors (see also: LICENSE)

/**
 * A simple test framework for the dart language to organize your tests and keep them DRY.
 */
library test_toolkit;

import 'dart:mirrors';

import 'package:log4dart/log4dart.dart';
import 'package:unittest/unittest.dart' as unittest;

final _logger = LoggerFactory.getLogger("test_toolkit");

/**
 * TestGroup is used to organize your tests into groups sharing the same
 * setup code. Extend `TestGroup`, and then the [runTest] method, as well
 * as any method prefixed with "test" will be ran as a [group]. If you only
 * need a single test method, simply implement [runTest]. If you have multiple
 * tests then prefix each method with "test" (implementing [runTest] is not
 * required). See `test.dart` in the test folder for a complete set of
 * examples on how to use TestGroup.
 */
class TestGroup {

  TestGroup();

  /** Setup method called before each test method in this group. */
  void setUp() {}

  /** Teardown method called after each test method in this group. */
  void tearDown() {}

  /**
   * Run all the test methods by calling [group].
   * If there is no [groupdoc] metadata annotation for this [TestGroup]
   * then an optional [description] may also be provided. [groupdoc] takes
   * precedence over the description parameter.
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
    unittest.group(description, _run);
  }

  /**
   * A [TestGroup] instance may be passed directly into the [group] function.
   *
   *     group('description', new MyTestGroup());
   */
  void call() {
    _run();
  }

  /** Implement this method to run a single test in the [group] */
  void runTest() {}

  void _run() {
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


/** Metadata annotation to provide the [group] with a description. */
class groupdoc {
  final String doc;
  const groupdoc(this.doc);
}


/** Metadata annotation to provide each test method with a [test] description. */
class testdoc {
  final String doc;
  const testdoc(this.doc);
}
