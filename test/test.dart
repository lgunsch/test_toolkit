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
}


// SimpleGroup demonstrates a single test ran in a group
class SimpleGroup extends TestGroup {
  String status;

  void setUp() {
    expect(status, isNull);
    status = 'setUp';
  }

  @testdoc('A simple test case')
  void runTest() {
    expect(status, equals('setUp'));
    status = 'runTest';
  }

  void tearDown() {
    expect(status, equals('runTest'));
    status = null;
  }
}


// MultiGroup demonstrates 3 test methods all ran in a group.
@groupdoc('Multi groupdoc')
class MultiGroup extends TestGroup {
  String status;

  void setUp() {
    expect(status, isNull);
    status = 'setUp';
  }

  void tearDown() {
    expect(status, equals('ran'));
    status = null;
  }

  @testdoc('test 1')
  void testFirst() {
    expect(status, equals('setUp'));
    status = 'ran';
  }

  @otherdescriptor('this method has 2 metadata descriptors.')
  @testdoc('test 2')
  void testSecond() {
    expect(status, equals('setUp'));
    status = 'ran';
  }

  // testdoc string is method name by default when its missing
  void testThird() {
    expect(status, equals('setUp'));
    status = 'ran';
  }
}


class otherdescriptor {
  final String doc;
  const otherdescriptor(this.doc);
}
