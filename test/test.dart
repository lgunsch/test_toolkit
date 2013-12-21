// Copyright © 2013 Lewis Gunsch and contributors (see also: LICENSE)

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';

import 'package:unittest/vm_config.dart';

import 'package:test_toolkit/test_toolkit.dart';


void main() {
  useVMConfiguration();

  // First calling convention.
  group('Simple', new SimpleGroup());
  group('Multi', new MultiGroup());

  // Second calling convention.
  var simple = new SimpleGroup()
      ..groupRun();
  var multi = new MultiGroup()
      ..groupRun();

  // You may also specify a description if you do not
  // want to use the `groupdoc` metadata descriptor.
  simple.groupRun('Message for TestGroup with no groupdoc');
  multi.groupRun("groupdoc takes precedence");

  // You can run the tests without using a group if you want multiple
  // TestGroup classes in a single group.
  group('Group', () {
    // some simple tests not using a TestGroup
    test('first', () => expect(true, isTrue));
    test('second', () => expect(true, isTrue));

    // now add in the group tests
    var groups = [new SimpleGroup(), new MultiGroup()];
    for (var group in groups) {
      group.run();
    }
  });

  // TestGroup run with group scope.
  (new MultiGroup()).run();
}


// SimpleGroup demonstrates a single test ran in a group
class SimpleGroup extends TestGroup {
  String status = null;

  void setUp() {
    status = 'setup the test';
  }

  @testdoc('A simple test case')
  void runTest() {
    expect(status, isNotNull);
  }

  void tearDown() {
    status = null;
  }
}


// MultiGroup demonstrates 3 test methods all ran in a group.
@groupdoc('Multi groupdoc')
class MultiGroup extends TestGroup {
  Completer completer;

  void setUp() {
    completer = new Completer<string>();
  }

  @testdoc('test 1')
  void testFirst() {
    var data = 'first test data';
    addCompleterAssert(completer, data);
    completer.complete(data);
  }

  @otherdescriptor('this method has 2 metadata descriptors.')
  @testdoc('test 2')
  void testSecond() {
    var delay = new Duration(milliseconds: 10);
    var data = 'second test data';
    addCompleterAssert(completer, data);
    new Timer(delay, () => completer.complete(data));
  }

  // testdoc string is method name by default when its missing
  void testThird() {
    completer.future.catchError((e) {
      expectAsync0(() {});
    });
    completer.completeError(new Exception());
  }

  void addCompleterAssert(completer, data) {
    completer.future.then(expectAsync1((str) {
      expect(str, equals(data), reason: "Data string does not match.");
    }));
  }
}


class otherdescriptor {
  final String doc;
  const otherdescriptor(this.doc);
}
