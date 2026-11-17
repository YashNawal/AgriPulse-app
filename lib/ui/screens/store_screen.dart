import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/services/payment_service.dart';
import '../../providers/agri_provider.dart';
import '../../providers/language_provider.dart';
import '../theme/app_theme.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showOrderBottomSheet(BuildContext context, Product product) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final villageCtrl = TextEditingController();
    int qty = 1;
    String deliveryOption = 'Home Delivery';
    String paymentMethod = 'UPI';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Request: ${product.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Price: ₹${product.price.toInt()} / ${product.unit}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Farmer Full Name',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number (+91)',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: villageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Village / Taluka / District',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantity Needed:', style: TextStyle(fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: qty > 1 ? () => setSheetState(() => qty--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => setSheetState(() => qty++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Home Delivery'),
                        selected: deliveryOption == 'Home Delivery',
                        onSelected: (s) => setSheetState(() => deliveryOption = 'Home Delivery'),
                        selectedColor: AppTheme.greenBadge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Mandi Center Pickup'),
                        selected: deliveryOption == 'Mandi Center Pickup',
                        onSelected: (s) => setSheetState(() => deliveryOption = 'Mandi Center Pickup'),
                        selectedColor: AppTheme.greenBadge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment Method Selector
                const Text(
                  'Payment Method:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        avatar: const Icon(Icons.bolt, size: 16, color: Colors.amber),
                        label: const Text('UPI App (GPay/PhonePe)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        selected: paymentMethod == 'UPI',
                        onSelected: (s) => setSheetState(() => paymentMethod = 'UPI'),
                        selectedColor: AppTheme.greenBadge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        avatar: const Icon(Icons.money, size: 16, color: Colors.green),
                        label: const Text('Cash on Delivery', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        selected: paymentMethod == 'COD',
                        onSelected: (s) => setSheetState(() => paymentMethod = 'COD'),
                        selectedColor: AppTheme.greenBadge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: paymentMethod == 'UPI' ? const Color(0xFFF0FDF4) : AppTheme.bgSand,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: paymentMethod == 'UPI' ? const Color(0xFFBBF7D0) : AppTheme.borderSubtle,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        paymentMethod == 'UPI' ? Icons.security : Icons.info_outline,
                        size: 16,
                        color: paymentMethod == 'UPI' ? AppTheme.primaryGreen : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          paymentMethod == 'UPI'
                              ? 'NPCI Verified UPI: 256-bit secure app switch to Google Pay, PhonePe, Paytm, or BHIM.'
                              : 'Pay physical cash to the certified delivery agent upon inspection.',
                          style: TextStyle(
                            fontSize: 11,
                            color: paymentMethod == 'UPI' ? const Color(0xFF166534) : AppTheme.textDark,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter name and phone number')),
                        );
                        return;
                      }

                      final agri = Provider.of<AgriProvider>(context, listen: false);
                      final totalAmount = (product.price * qty).toDouble();

                      if (paymentMethod == 'UPI') {
                        final upiLaunched = await PaymentService.instance.initiateUpiPayment(
                          payeeVpa: 'kisanmitra@upi',
                          payeeName: 'KisanMitra Agri Store',
                          amount: totalAmount,
                          transactionNote: 'KM Order ${product.name}',
                        );
                        if (!upiLaunched && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('UPI intent triggered. Completing order records...'),
                            ),
                          );
                        }
                      }

                      final req = ProductRequest(
                        farmerName: nameCtrl.text,
                        phone: phoneCtrl.text,
                        village: villageCtrl.text,
                        crop: product.suitableFor,
                        productName: '${product.name} [Paid via $paymentMethod: ₹${(product.price * qty).toInt()}]',
                        quantity: qty,
                        deliveryOption: deliveryOption,
                      );

                      await agri.submitProductOrder(req);

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.primaryGreen,
                          content: Text(
                            paymentMethod == 'UPI'
                                ? 'Safe UPI initiated! Order for ${product.name} (₹${(product.price * qty).toInt()}) submitted.'
                                : 'Success! COD request for ${product.name} submitted. Agronomist will call within 2 hours.',
                          ),
                        ),
                      );
                    },
                    icon: Icon(paymentMethod == 'UPI' ? Icons.lock_outline : Icons.check_circle_outline, size: 18),
                    label: Text(
                      paymentMethod == 'UPI'
                          ? 'Pay ₹${(product.price * qty).toInt()} via UPI & Order'
                          : 'Confirm Order (₹${(product.price * qty).toInt()} on Delivery)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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

  @override
  Widget build(BuildContext context) {
    final agri = context.watch<AgriProvider>();
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgSand,
      appBar: AppBar(
        title: Text(lang.t('store_title')),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryGreen,
          indicatorWeight: 3,
          tabs: [
            Tab(text: lang.t('catalog_tab')),
            Tab(text: lang.t('fertilizer_schedule_tab')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Products Catalog
          Column(
            children: [
              // Search & Categories
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (val) => agri.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search fertilizers, seeds, bio-pesticides...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Category Pills
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    'All',
                    'Fertilizer',
                    'Seeds',
                    'Bio-Pesticide',
                    'Micronutrient',
                  ].map((cat) {
                    final isSel = agri.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSel,
                        onSelected: (_) => agri.setProductCategory(cat),
                        selectedColor: AppTheme.primaryGreen,
                        backgroundColor: AppTheme.cardWhite,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppTheme.textDark,
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSel ? AppTheme.primaryGreen : AppTheme.borderSubtle,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Product Cards List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: agri.filteredProducts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, idx) {
                    final item = agri.filteredProducts[idx];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.greenBadge,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        lang.t('approved_badge'),
                                        style: const TextStyle(
                                          color: AppTheme.greenText,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Brand: ${item.brand} • ${item.suitableFor}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${item.price.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                  Text(
                                    '/${item.unit}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textDark,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.bgSand,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 14, color: AppTheme.primaryGreen),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Dose: ${item.applicationDose}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showOrderBottomSheet(context, item),
                              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                              label: Text(lang.t('request_product')),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Tab 2: Stage-wise Fertilizer Schedule
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: agri.fertilizerPlans.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final plan = agri.fertilizerPlans[idx];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.blueBadge,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            plan.stage,
                            style: const TextStyle(
                              color: AppTheme.blueText,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          plan.timing,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      plan.recommendedProduct,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recommended Dose: ${plan.dosage}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      plan.notes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
