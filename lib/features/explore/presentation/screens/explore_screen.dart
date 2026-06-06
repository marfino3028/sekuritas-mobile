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
            expandedHeight: 130,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Search bar
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
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
                              prefixIcon: Icon(Icons.search, color: AppColors.textHint, size: 20),
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.divider,
                            ),
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
                    const Text(
                      'Top Reksa Dana',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
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
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
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
      height: 86,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _tickers.length,
        itemBuilder: (context, index) {
          final t = _tickers[index];
          final isPositive = t['positive'] as bool;
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
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
          margin: const EdgeInsets.all(4),
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          // Fund avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                fund['name']![0],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
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
                Row(
                  children: [
                    _MetricChip(label: '1 Thn', value: fund['return1y']!, positive: true),
                    const SizedBox(width: 8),
                    _MetricChip(label: 'CAGR 3 Bln', value: fund['cagr3m']!, positive: true),
                    const SizedBox(width: 8),
                    _MetricChip(label: 'AUM', value: fund['aum']!, positive: null),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Buy button
          SizedBox(
            width: 52,
            height: 32,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
