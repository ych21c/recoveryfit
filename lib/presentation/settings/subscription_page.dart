import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initIAP();
  }

  Future<void> _initIAP() async {
    final available = await _iap.isAvailable();
    if (!available) {
      setState(() {
        _isAvailable = false;
        _isLoading = false;
      });
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => setState(() => _errorMessage = e.toString()),
    );

    final response = await _iap.queryProductDetails(
      {AppConstants.subscriptionId},
    );

    setState(() {
      _isAvailable = true;
      _products = response.productDetails;
      _isLoading = false;
    });
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _deliverPurchase(purchase);
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        setState(() {
          _isPurchasing = false;
          _errorMessage = purchase.error?.message ?? '결제 오류가 발생했습니다.';
        });
      }
    }
  }

  Future<void> _deliverPurchase(PurchaseDetails purchase) async {
    final expiry = DateTime.now().add(const Duration(days: 31));
    await ref.read(subscriptionProvider.notifier).activate(expiry);
    setState(() => _isPurchasing = false);
  }

  Future<void> _purchase() async {
    if (_products.isEmpty) return;
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });
    final param = PurchaseParam(productDetails: _products.first);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> _restore() async {
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });
    await _iap.restorePurchases();
    setState(() => _isPurchasing = false);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('구독'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'RecoveryFit Pro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'AI 맞춤 운동 플랜 · 주간 갱신 · 무제한 기록',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _FeatureList(),
                  const SizedBox(height: 32),
                  if (!_isAvailable)
                    const Text(
                      '이 기기에서는 인앱결제를 사용할 수 없습니다.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    )
                  else if (isSubscribed)
                    _SubscribedBadge()
                  else ...[
                    _PriceCard(
                      products: _products,
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: AppTheme.error, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    _isPurchasing
                        ? const CircularProgressIndicator(
                            color: AppTheme.primary)
                        : Column(
                            children: [
                              ElevatedButton(
                                onPressed: _purchase,
                                child: const Text('7일 무료 체험 시작'),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: _restore,
                                child: const Text('구독 복원'),
                              ),
                            ],
                          ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    AppConstants.disclaimer,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '결제는 Google Play 계정으로 청구됩니다.\n구독은 언제든지 취소할 수 있습니다.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  static const _features = [
    (Icons.psychology, 'AI 맞춤 운동 플랜', '부상을 고려한 4주 플랜 자동 생성'),
    (Icons.refresh, '주간 AI 재조정', '지난 7일 기록 기반 플랜 최적화'),
    (Icons.check_circle_outline, '일별 체크리스트', '완료/스킵/통증 기록'),
    (Icons.bar_chart, '통계 대시보드', '통증 추이·완료율·볼륨 그래프'),
    (Icons.notifications, '운동 리마인더', '맞춤 알림으로 꾸준한 운동'),
    (Icons.library_books, '150+ 운동 라이브러리', '영상·설명·부위별 분류'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(f.$1, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        f.$3,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final List<ProductDetails> products;
  const _PriceCard({required this.products});

  @override
  Widget build(BuildContext context) {
    final price = products.isNotEmpty
        ? products.first.price
        : '₩${AppConstants.subscriptionPriceKrw}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            price,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const Text(
            ' / 월',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscribedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: AppTheme.primary, size: 28),
          SizedBox(width: 12),
          Text(
            'Pro 구독 중 ✨',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
