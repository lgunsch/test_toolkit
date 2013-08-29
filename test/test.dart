/* Main test runner */

import 'dart:async';

import 'package:unittest/unittest.dart' hide TestCase;
import 'package:unittest/mock.dart';

import 'package:unittest/vm_config.dart';

import 'package:test_toolkit/test_toolkit.dart';


void main() {
  useVMConfiguration();
  group('Simple', new Simple());
  group('Multi', new Multi());
}


class otherdescriptor {
  final String doc;
  const otherdescriptor(this.doc);
}


class Simple extends TestCase {
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
  }
}


class Multi extends TestCase {
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

  @testdoc('test 3')
  void testThird() {
    expect(status, equals('setUp'));
    status = 'ran';
  }
}
