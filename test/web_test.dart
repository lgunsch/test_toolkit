// Copyright © 2013 Lewis Gunsch and contributors (see also: LICENSE)
library web_test;

import 'package:unittest/html_enhanced_config.dart';

import 'test.dart' as test;

void main() {
  useHtmlEnhancedConfiguration();
  test.main();
}