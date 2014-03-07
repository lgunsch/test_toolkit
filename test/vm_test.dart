// Copyright © 2013 Lewis Gunsch and contributors (see also: LICENSE)
library vm_test;

import 'package:unittest/vm_config.dart';

import 'test.dart' as test;

void main() {
  useVMConfiguration();
  test.main();
}