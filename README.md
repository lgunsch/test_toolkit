Test Toolkit
============

A simple test framework for the [Dart][dart] language to organize your [unittest][unittest] tests and keep them DRY.

Installation
------------

Add this package to your pubspec.yaml file:

    dependencies:
      test_toolkit: any

Then, run `pub install` to download and link in the package.

TestGroup
---------

TestGroup is used to organize your tests into groups sharing the same setup
code. Extend `TestGroup`, implement the `runTest` method, or add in methods
prefixed with `test`. These methods will be run as a unittest `group`, with
each method being run in a unittest `test`. If you only need a single test
method, simply implement `runTest`. If you have multiple tests then prefix
each method with `test` (implementing `runTest` is not required).

Use `@groupdoc` and `@testdoc` to add `test` and `group` description strings.

If you only want to run the tests, and not put them into a `group`, use the
`run` method.

See [test.dart][examples] in the test folder for a complete set of examples on
how to use `TestGroup`.

Example
-------

```dart
import 'package:unittest/unittest.dart';
import 'package:test_toolkit/test_toolkit.dart';

void main() {
  group('Simple', new SimpleGroup());
  group('Multi', new MultiGroup());

  group('other group', () {
    test('first', () => expect(true, isTrue));
    test('second', () => expect(true, isTrue));

    // now add in the group test classes
    var groups = [new SimpleGroup(), new MultiGroup()];
    for (var group in groups) {
      group.run();
    }
  });
}

class SimpleGroup extends TestGroup {
  String status;

  void setUp() {
    status = 'setUp';
  }

  @testdoc('A simple test case')
  void runTest() {
    expect(status, equals('setUp'));
  }

  void tearDown() {
    status = null;
  }
}


@groupdoc('Multi')
class MultiGroup extends TestGroup {
  String status;

  void setUp() {
    status = 'setUp';
  }

  void tearDown() {
    status = null;
  }

  @testdoc('test 1')
  void testFirst() {
    expect(status, equals('setUp'));
  }

  @testdoc('test 2')
  void testSecond() {
    expect(status, equals('setUp'));
  }

  // testdoc string is method name by default when its missing
  void testThird() {
    expect(status, equals('setUp'));
  }
}
```

Bugs & Feature Requests
-----------------------
Any bugs reports, or features requests can be from the github project page.

See: [issues]


[issues]: https://github.com/lgunsch/test_toolkit/issues
[examples]: https://github.com/lgunsch/test_toolkit/blob/master/test/test.dart
[dart]: http://www.dartlang.org/
[unittest]: http://pub.dartlang.org/packages/unittest


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/lgunsch/test_toolkit/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

