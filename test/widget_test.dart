import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_fit/core/constants/app_constants.dart';

void main() {
  test('AppConstants values are correctly set', () {
    expect(AppConstants.maxMonthlyLlmCalls, 5);
    expect(AppConstants.subscriptionPriceKrw, 2900);
    expect(AppConstants.planWeeks, 4);
    expect(AppConstants.subscriptionId, 'com.recoveryfit.app.monthly');
    expect(AppConstants.disclaimer, contains('의료기기가 아닙니다'));
  });
}
