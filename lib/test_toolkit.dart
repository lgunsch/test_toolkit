// Copyright © 2013 Lewis Gunsch and contributors (see also: LICENSE)

/**
 * A simple test framework for the dart language to organize your tests and keep them DRY.
 */
library test_toolkit;

import 'dart:mirrors';

import 'package:test/test.dart' as test;

final testGroupName = MirrorSystem.getName(reflectClass(TestGroup).simpleName);


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
   * If description parameter is specified, it will give description to [group].
   * Otherwise description will be taken from [groupdoc] metadata annotation
   * for this [TestGroup]. If there is no [groupdoc] metadata annotation for
   * this [TestGroup] then its class name will be taken as description.
   */
  void groupRun([String description]) {
    var classMirror = reflect(this).type;
    var groupName = MirrorSystem.getName(classMirror.simpleName);
    if (description == null) {
      if (hasGroupdoc(classMirror)) {
        groupName = getDescription(classMirror);
      }
    } else {
      groupName = description;
    }
    test.group(groupName, () {
      test.setUp(this.setUp);
      test.tearDown(this.tearDown);
      _doRun();
    });
  }

  /**
   * A [TestGroup] instance may be passed directly into the [group] function.
   *
   *     group('description', new MyTestGroup());
   */
  void call() {
    groupRun();
  }

  /** Implement this method to run a single test in the [group] */
  void runTest() {}

  /**
   * Run all the tests without a [group]; Use [groupRun] if you want them
   * run in a [group].
   * To be qualified as a test, method should have name equal to 'runTest',
   * or should start with 'test'.
   */
  void run() {
    // Add an anonymous group here
    // because in test package, setUp() can't be called multiple times
    // for the same group.
    test.group('', () {
      test.setUp(this.setUp);
      test.tearDown(this.tearDown);
      _doRun();
    });
  }

  void _doRun() {
    var instanceMirror = reflect(this);
    var classMirror = instanceMirror.type;

    classMirror.instanceMembers.forEach((symbol, method) {
      var name = MirrorSystem.getName(symbol);
      if (!method.isRegularMethod || !isTestMethod(name)) {
        return;
      }

      // Skip runTest method if its not implemented in the child class.
      var owner = MirrorSystem.getName(method.owner.simpleName);
      if (name == 'runTest' && owner == testGroupName) {
        return;
      }

      var description = getDescription(method);

      test.test(description, () => instanceMirror.invoke(symbol, []));
    });
  }

  bool isTestMethod(String name) {
    return name.startsWith('test') || name == 'runTest';
  }

  bool hasGroupdoc(DeclarationMirror mirror) {
    var description = MirrorSystem.getName(mirror.simpleName);
    for (var descriptor in mirror.metadata) {
      if (descriptor.reflectee is groupdoc) {
        return true;
      }
    }
    return false;
  }

  String getDescription(DeclarationMirror mirror) {
    var description = MirrorSystem.getName(mirror.simpleName);
    for (var descriptor in mirror.metadata) {
      if (descriptor.reflectee is groupdoc || descriptor.reflectee is testdoc) {
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
