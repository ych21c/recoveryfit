import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/storage_service.dart';
import '../providers/providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiKeyController = TextEditingController();
  bool _apiKeyObscured = true;
  bool _savedSuccess = false;

  @override
  void initState() {
    super.initState();
    final saved = StorageService.instance.apiKey;
    if (saved != null) _apiKeyController.text = saved;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    await StorageService.instance.saveApiKey(_apiKeyController.text.trim());
    setState(() => _savedSuccess = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _savedSuccess = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final isSubscribed = ref.watch(subscriptionProvider);
    final llmRemaining = ref.watch(llmCallsRemainingProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // Subscription section
          _SectionHeader(title: '구독'),
          _SettingsTile(
            leading: const Icon(Icons.star, color: AppTheme.warning),
            title: isSubscribed ? 'RecoveryFit Pro 구독 중' : 'RecoveryFit Pro 구독',
            subtitle: isSubscribed
                ? '월 ${AppConstants.subscriptionPriceKrw}원 · 자동 갱신'
                : '월 ${AppConstants.subscriptionPriceKrw}원 · 7일 무료 체험',
            trailing: TextButton(
              onPressed: () => context.push(AppRoutes.subscription),
              child: Text(isSubscribed ? '관리' : '구독하기'),
            ),
          ),

          // AI usage section
          _SectionHeader(title: 'AI 사용 현황'),
          _SettingsTile(
            leading: const Icon(Icons.psychology_outlined,
                color: AppTheme.secondary),
            title: '이번 달 AI 호출',
            subtitle:
                '${StorageService.instance.llmCallsThisMonth} / ${AppConstants.maxMonthlyLlmCalls}회 사용',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: llmRemaining > 0
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '잔여 $llmRemaining회',
                style: TextStyle(
                  color: llmRemaining > 0
                      ? AppTheme.primary
                      : AppTheme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          // API Key section
          _SectionHeader(title: 'API 설정'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anthropic API 키',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _apiKeyObscured,
                  decoration: InputDecoration(
                    hintText: 'sk-ant-...',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => setState(
                              () => _apiKeyObscured = !_apiKeyObscured),
                          icon: Icon(
                            _apiKeyObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        IconButton(
                          onPressed: _saveApiKey,
                          icon: Icon(
                            _savedSuccess
                                ? Icons.check_circle
                                : Icons.save_outlined,
                            color: _savedSuccess
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_savedSuccess)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      '✅ API 키가 저장되었습니다',
                      style: TextStyle(
                          color: AppTheme.primary, fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'API 키는 기기에만 저장되며 서버로 전송되지 않습니다.\n'
                  'Anthropic Console(console.anthropic.com)에서 발급하세요.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Profile section
          if (profile != null) ...[
            _SectionHeader(title: '내 정보'),
            _SettingsTile(
              leading: const Icon(Icons.healing, color: AppTheme.primary),
              title: '부상/통증',
              subtitle: profile.injuryDescription,
            ),
            _SettingsTile(
              leading: const Icon(Icons.flag, color: AppTheme.secondary),
              title: '목표',
              subtitle: _goalLabel(profile.goal),
            ),
            _SettingsTile(
              leading: const Icon(Icons.calendar_today, color: AppTheme.warning),
              title: '운동 빈도',
              subtitle: '주 ${profile.weeklyFrequency}회',
            ),
          ],

          // Legal section
          _SectionHeader(title: '법적 고지'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppConstants.disclaimer,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Text(
              'RecoveryFit v1.0.0\n© 2025 RecoveryFit. All rights reserved.',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _goalLabel(String goal) => switch (goal) {
        'muscleGain' => '근육량 증가',
        'recovery' => '회복(재활)',
        'weightLoss' => '체중감소',
        _ => goal,
      };
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
              )
            : null,
        trailing: trailing,
      ),
    );
  }
}
