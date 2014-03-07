// Copyright © 2013 Lewis Gunsch and contributors (see also: LICENSE)
library web_test;

import 'package:unittest/html_enhanced_config.dart';

import '../test/test.dart' as test;  // TODO: Fix me once there is a better solution

void main() {
  useHtmlEnhancedConfiguration();
  test.main();
}