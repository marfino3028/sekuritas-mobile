import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _productTabController;
  late TabController _fundTabController;
  int _selectedCategory = 0;
  int _selectedProduct = 0; // 0=Reksa Dana, 1=Saham

  final _categories = ['Semua', 'Pasar Uang', 'Pendapatan Tetap', 'Saham', 'Campuran'];
  final _fundTabs = ['Watchlist', 'Pasar Uang', 'Pendapatan Tetap'];

  @override
  void initState() {
    super.initState();
    _productTabController = TabController(length: 2, vsync: this);
    _fundTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _productTabController.dispose();
    _fundTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            floating: true,
            snap: true,
            pinned: false,
            automaticallyImplyLeading: false,
            expandedHeight: 168,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gradientStart,
                      AppColors.gradientMid,
                      AppColors.gradientEnd,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Soft gradient orb di sudut kanan-atas (aksen asimetris)
                    Positioned(
                      top: -36,
                      right: -28,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentLight.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -24,
                      left: -30,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heading display rata-kiri + pill statistik
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Explore',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.glassWhite,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: AppColors.glassBorder),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.trending_up,
                                          size: 14, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'Pasar Aktif',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Search bar
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.cardShadow,
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                    spreadRadius: -6,
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Cari Aset Investasi',
                                  hintStyle: TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                                  prefixIcon: Icon(Icons.search,
                                      color: AppColors.primary, size: 20),
                                  border: InputBorder.none,
                                  filled: false,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IHSG horizontal ticker
              _IhsgTicker(),

              const SizedBox(height: 16),

              // Product toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _ToggleButton(
                        label: 'Reksa Dana',
                        isSelected: _selectedProduct == 0,
                        onTap: () => setState(() => _selectedProduct = 0),
                      ),
                      _ToggleButton(
                        label: 'Saham',
                        isSelected: _selectedProduct == 1,
                        onTap: () => setState(() => _selectedProduct = 1),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category filter chips
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategory == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.divider,
                            ),
                            boxShadow: isSelected
                                ? const [
                                    BoxShadow(
                                      color: AppColors.cardShadow,
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                      spreadRadius: -4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Top Reksa Dana section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Top Reksa Dana',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Fund tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 24,
                      offset: Offset(0, 12),
                      spreadRadius: -6,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _fundTabController,
                      tabs: _fundTabs.map((t) => Tab(text: t)).toList(),
                      isScrollable: true,
                      dividerColor: AppColors.divider,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const _FundList(),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _IhsgTicker extends StatelessWidget {
  final List<Map<String, dynamic>> _tickers = const [
    {'name': 'IHSG', 'value': '7.426,50', 'change': '+82,45', 'pct': '+1,12%', 'positive': true},
    {'name': 'LQ45', 'value': '1.043,21', 'change': '+11,83', 'pct': '+1,14%', 'positive': true},
    {'name': 'IDX30', 'value': '572,14', 'change': '+5,22', 'pct': '+0,92%', 'positive': true},
    {'name': 'JII', 'value': '618,55', 'change': '-2,14', 'pct': '-0,34%', 'positive': false},
    {'name': 'SMINFRA', 'value': '382,11', 'change': '+4,56', 'pct': '+1,21%', 'positive': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _tickers.length,
        itemBuilder: (context, index) {
          final t = _tickers[index];
          final isPositive = t['positive'] as bool;
          return Container(
            width: 116,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t['name'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  t['value'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  t['pct'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? AppColors.success : AppColors.error,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                      spreadRadius: -4,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FundList extends StatelessWidget {
  const _FundList();

  static const _funds = [
    {
      'name': 'Sucorinvest Sharia Money Market Fund',
      'company': 'Sucorinvest AM',
      'return1y': '+6,85%',
      'cagr3m': '+1,72%',
      'aum': 'Rp 3,2 T',
      'risk': 'Rendah',
    },
    {
      'name': 'Manulife Dana Kas II',
      'company': 'Manulife AM',
      'return1y': '+5,94%',
      'cagr3m': '+1,45%',
      'aum': 'Rp 5,8 T',
      'risk': 'Rendah',
    },
    {
      'name': 'Bahana Dana Likuid',
      'company': 'Bahana TCW',
      'return1y': '+6,12%',
      'cagr3m': '+1,52%',
      'aum': 'Rp 2,1 T',
      'risk': 'Rendah',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _funds.map((fund) => _FundCard(fund: fund)).toList(),
    );
  }
}

class _FundCard extends StatelessWidget {
  final Map<String, String> fund;
  const _FundCard({required this.fund});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          // Fund avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 14,
                  offset: Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                fund['name']![0],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund['name']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fund['company']!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    _MetricChip(label: '1 Thn', value: fund['return1y']!, positive: true),
                    _MetricChip(label: 'CAGR 3 Bln', value: fund['cagr3m']!, positive: true),
                    _MetricChip(label: 'AUM', value: fund['aum']!, positive: null),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Buy button
          SizedBox(
            width: 56,
            height: 36,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Beli',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final bool? positive;

  const _MetricChip({required this.label, required this.value, required this.positive});

  @override
  Widget build(BuildContext context) {
    Color valueColor = AppColors.textSecondary;
    if (positive == true) valueColor = AppColors.success;
    if (positive == false) valueColor = AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.textHint,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valueColor,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
