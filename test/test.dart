/* Main test runner */

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';

import 'package:unittest/vm_config.dart';

import 'package:test_toolkit/test_toolkit.dart';


void main() {
  useVMConfiguration();

  // calling convention 1
  group('Simple', new SimpleGroup());
  group('Multi', new MultiGroup());

  var simple = new SimpleGroup()
      ..groupRun();
  var multi = new MultiGroup()
      ..groupRun();

  simple.groupRun('Message for TestGroup with no groupdoc');
  multi.groupRun("groupdoc takes precedence");
}


class otherdescriptor {
  final String doc;
  const otherdescriptor(this.doc);
}


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
