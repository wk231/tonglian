import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/models/order_model.dart';
import 'package:hiddify/features/panel/xboard/models/payment_method.dart';
import 'package:hiddify/features/panel/xboard/models/plan_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/order_service.dart';
import 'package:hiddify/features/panel/xboard/services/purchase_service.dart';
import 'package:hiddify/features/panel/xboard/services/subscription.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/dialog_viewmodel/payment_methods_viewmodel.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/dialog_viewmodel/payment_methods_viewmodel_provider.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/purchase_viewmodel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

final purchaseViewModelProvider = ChangeNotifierProvider(
  (ref) => PurchaseViewModel(purchaseService: PurchaseService()),
);

class PurchasePage extends ConsumerStatefulWidget {
  const PurchasePage({super.key});

  @override
  _PurchasePageState createState() => _PurchasePageState();
}

class _PurchasePageState extends ConsumerState<PurchasePage> {
  final PurchaseService _purchaseService = PurchaseService();
  final OrderService _orderService = OrderService();
  NumberFormat formatter = NumberFormat('#,###.##');

  @override
  void initState() {
    super.initState();
    // Delay the provider modification until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(purchaseViewModelProvider).fetchPlans();
      ref.read(purchaseViewModelProvider).fetchPaymentMethods();
    });
  }

  List<double?> priceList(PurchaseViewModel viewModel) {
    if (viewModel.select == -1) {
      return [];
    }
    final plan = viewModel.plans[viewModel.select];
    return [plan.monthPrice, plan.quarterPrice, plan.halfYearPrice, plan.yearPrice, plan.twoYearPrice, plan.threeYearPrice, plan.onetimePrice].where((price) => price != null).toList();
  }

  String? _findCheapestPeriod(Plan plan, double? cheapestPrice) {
    if (cheapestPrice == plan.monthPrice) return 'month_price';
    if (cheapestPrice == plan.quarterPrice) return 'quarter_price';
    if (cheapestPrice == plan.halfYearPrice) return 'half_year_price';
    if (cheapestPrice == plan.yearPrice) return 'year_price';
    if (cheapestPrice == plan.twoYearPrice) return 'two_year_price';
    if (cheapestPrice == plan.threeYearPrice) return 'three_year_price';
    if (cheapestPrice == plan.onetimePrice) return 'onetime_price';
    return null;
  }

  String? _findCheapestText(Plan plan, double? cheapestPrice, Translations t) {
    if (cheapestPrice == plan.monthPrice) return t.purchase.monthPrice;
    if (cheapestPrice == plan.quarterPrice) return t.purchase.quarterPrice;
    if (cheapestPrice == plan.halfYearPrice) return t.purchase.halfYearPrice;
    if (cheapestPrice == plan.yearPrice) return t.purchase.yearPrice;
    if (cheapestPrice == plan.twoYearPrice) return t.purchase.twoYearPrice;
    if (cheapestPrice == plan.threeYearPrice) return t.purchase.threeYearPrice;
    if (cheapestPrice == plan.onetimePrice) return t.purchase.onetimePrice;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);
    final viewModel = ref.watch(purchaseViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(t.purchase.pageTitle, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // 添加参数指示隐藏底部tab并保留导航历史
              context.push('/order', extra: {'hideBottomTab': true});
            },
            child: Text(
              t.order.title,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(purchaseViewModelProvider).fetchPlans(); // 强制刷新
        },
        child: Builder(
          builder: (context) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.errorMessage != null) {
              return Center(
                child: Text(
                  '${t.purchase.fetchPlansError} ${viewModel.errorMessage}',
                ),
              );
            } else if (viewModel.plans.isEmpty) {
              return Center(child: Text(t.purchase.noPlans));
            } else {
              return MasonryGridView.count(
                padding: const EdgeInsets.all(24).copyWith(top: 10),
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                itemCount: viewModel.plans.length,
                itemBuilder: (context, index) => _buildPlanCard(viewModel.plans[index], t, context, ref, viewModel, index),
              );
            }
          },
        ),
      ),
    );
  }

  void showSheet(PurchaseViewModel viewModel, Translations t) {
    // 获取价格列表
    final prices = priceList(viewModel);
    // 设置默认选中的价格（第一个有效价格）
    if (prices.isNotEmpty) {
      // 找到第一个有效价格
      final firstValidPrice = prices.first;
      // 找到对应的周期
      final firstPeriod = _findCheapestPeriod(viewModel.plans[viewModel.select], firstValidPrice);
      // 设置默认选中的价格和周期
      viewModel.setSelectedPrice(firstValidPrice, firstPeriod);
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => StatefulBuilder(
        builder: (context, state) => SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, crossAxisSpacing: 4, mainAxisSpacing: 4, childAspectRatio: 6),
                  shrinkWrap: true,
                  itemCount: priceList(viewModel).length,
                  itemBuilder: (_, index) => Card(
                    child: Row(
                      children: [
                        Radio<double>(
                          value: priceList(viewModel)[index] ?? 0,
                          groupValue: viewModel.selectedPrice,
                          onChanged: (value) {
                            viewModel.setSelectedPrice(priceList(viewModel)[index], _findCheapestPeriod(viewModel.plans[viewModel.select], priceList(viewModel)[index]));
                            state(() {});
                          },
                        ),
                        Text(_findCheapestText(viewModel.plans[viewModel.select], priceList(viewModel)[index], t) ?? ''),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 1),
                              child: Text(
                                '￥',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFFF0000),
                                ),
                              ),
                            ),
                            Text(
                              formatter.format(priceList(viewModel)[index]),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFF0000),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: Column(
                    children: List.generate(viewModel.paymentMethods.length, (int index) => _buildMethod(viewModel, index, state)),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final String? accessToken = await getToken();
                    // 检查未支付的订单
                    final List<Order> orders = await _orderService.fetchUserOrders(accessToken ?? '');
                    for (final order in orders) {
                      print(order.status);
                      if (order.status == 0) {
                        // 如果订单未支付
                        await _orderService.cancelOrder(order.tradeNo!, accessToken ?? '');
                        print('未支付订单 ${order.tradeNo} 已取消');
                      }
                    }
                    final orderResponse = await _purchaseService.createOrder(
                      viewModel.plans[viewModel.select].id,
                      viewModel.selectedPeriod ?? '',
                      accessToken ?? '',
                    );
                    if (orderResponse != null) {
                      final String? tradeNo = orderResponse['data']?.toString();
                      final PaymentMethodsViewModelParams params = PaymentMethodsViewModelParams(
                        tradeNo: tradeNo ?? '',
                        totalAmount: viewModel.selectedPrice ?? 0,
                        onPaymentSuccess: () {
                          Navigator.pop(context);
                          viewModel.select = -1;
                          final t = ref.watch(translationsProvider); // 引入本地化文件
                          // 支付成功回调
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.purchase.orderSuccess)),
                          );
                          Subscription.updateSubscription(context, ref);
                        },
                      );
                      final AutoDisposeChangeNotifierProvider<PaymentMethodsViewModel> provider = paymentMethodsViewModelProvider(params);
                      final methodsViewModel = ref.watch(provider);
                      methodsViewModel.handlePayment(viewModel.paymentMethods[viewModel.method].id.toString());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    '立即支付',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethod(PurchaseViewModel viewModel, int index, StateSetter state) {
    final PaymentMethod method = viewModel.paymentMethods[index];
    return InkWell(
      onTap: () => state(() => viewModel.method = index),
      child: Row(
        children: [
          const SizedBox(height: 58),
          const SizedBox(width: 18),
          Image.network(method.icon ?? '', width: 25, height: 25),
          const SizedBox(width: 10),
          Text(method.name ?? '', style: const TextStyle(color: Colors.black, fontSize: 16)),
          const Spacer(),
          Icon(
            viewModel.method == index ? FluentIcons.checkmark_circle_24_filled : FluentIcons.circle_24_regular,
            color: viewModel.method == index ? Theme.of(context).primaryColor : const Color(0xFFECECF0),
          ),
          const SizedBox(width: 18),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    Plan plan,
    Translations t,
    BuildContext context,
    WidgetRef ref,
    PurchaseViewModel viewModel,
    int index,
  ) {
    return InkWell(
      onTap: () {
        setState(() => viewModel.select = index);
        showSheet(viewModel, t);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: viewModel.select == index ? Theme.of(context).primaryColor : const Color(0xFFECECF0)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: const Color(0xFF5D647E).withAlpha(10), offset: const Offset(3, 3), blurRadius: 5)],
        ),
        child: Stack(
          children: [
            Visibility(
              visible: viewModel.select == index,
              child: Align(
                alignment: Alignment.topRight,
                child: Image.asset('assets/images/purchase_select.png', width: 35, height: 32),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildUniformStyledContent(plan.content ?? t.purchase.noData),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Text(
                          '￥',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFF0000),
                          ),
                        ),
                      ),
                      Text(
                        // formatter.format(plan.monthPrice ?? 0),
                        formatter.format(plan.onetimePrice ?? plan.monthPrice ??plan.quarterPrice ??plan.halfYearPrice ??plan.yearPrice ??plan.twoYearPrice ??plan.threeYearPrice??0),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFF0000),
                        ),
                      ),
                    ],
                  )
                  // PriceWidget(
                  //   plan: plan,
                  //   priceLabel: t.purchase.priceLabel,
                  //   currency: t.purchase.rmb,
                  // ),
                  // const SizedBox(height: 8),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     showPurchaseDialog(context, plan, t, ref);
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.blue,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  //   child: Text(
                  //     t.purchase.subscribe,
                  //     style: const TextStyle(color: Colors.white),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniformStyledContent(String content) {
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              const Icon(
                FluentIcons.checkmark_circle_24_filled,
                color: Colors.blue,
                size: 13,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  line.trim(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  double getFirstValidPrice(PurchaseViewModel viewModel, int index) {
    final prices = priceList(viewModel);

    // 从指定索引开始查找第一个有效价格
    for (int i = index; i < prices.length; i++) {
      final price = prices[i];
      if (price != null && price > 0) {
        return price;
      }
    }

    // 如果都没找到，返回0或最后一个
    return prices.last ?? 0;
  }
}
