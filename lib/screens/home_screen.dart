import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../data/cycles.dart';
import '../models/booking.dart';
import '../models/cycle.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';
import '../services/receipt_pdf_service.dart';
import '../widgets/booking_sheet.dart';
import '../widgets/cycle_card.dart';
import '../widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  final AppUser? currentUser;
  const HomeScreen({super.key, this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _fleetKey = GlobalKey();
  final GlobalKey _howKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _reviewsKey = GlobalKey();

  String cityFilter = 'All';
  String categoryFilter = 'All';
  DateTime? searchDate;
  int bookingCount = 0;
  List<Booking> bookings = [];
  List<CycleModel> availableCycles = cyclesDatabase;

  final cities = const [
    'All Pakistan Cities',
    'Islamabad',
    'Lahore',
    'Skardu',
    'Hunza',
    'Peshawar',
    'Karachi',
  ];

  final categories = const [
    'All Cycles',
    'Mountain MTB',
    'Road Bikes',
    'Electric E-Bikes',
    'City Hybrids',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cycles = await BackendService().fetchAvailableCycles();
    final data = await BackendService().fetchCustomerBookings();
    if (!mounted) return;
    setState(() {
      availableCycles = cycles;
      bookings = data;
      bookingCount = data.length;
    });
  }

  List<CycleModel> get filteredCycles {
    final category = _categoryValue(categoryFilter);
    return availableCycles.where((bike) {
      final categoryMatch = category == 'All' || bike.category == category;
      final cityMatch = cityFilter == 'All' || bike.cities.contains(cityFilter);
      return categoryMatch && cityMatch;
    }).toList();
  }

  String _categoryValue(String display) {
    switch (display) {
      case 'Mountain MTB':
        return 'Mountain MTB';
      case 'Road Bikes':
        return 'Road Bike';
      case 'Electric E-Bikes':
        return 'Electric E-Bike';
      case 'City Hybrids':
        return 'City Hybrid';
      default:
        return 'All';
    }
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showBooking(CycleModel cycle) async {
    final booking = await showModalBottomSheet<Booking>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingSheet(
        cycle: cycle,
        initialCity: cityFilter == 'All' ? cycle.cities.first : cityFilter,
        currentUser: widget.currentUser,
      ),
    );

    if (booking == null || !mounted) return;
    await _loadData();
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => _ReceiptDialog(booking: booking),
    );
  }

  void _applySearch() {
    setState(() {});
    _scrollTo(_fleetKey);
  }

  Future<void> _pickSearchDate() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: searchDate ?? DateTime.now(),
    );
    if (value != null) setState(() => searchDate = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 78,
            backgroundColor: Colors.white.withOpacity(0.96),
            surfaceTintColor: Colors.white,
            titleSpacing: 0,
            title: _Header(
              bookingCount: bookingCount,
              onHome: () => _scrollTo(_fleetKey),
              onFleet: () => _scrollTo(_fleetKey),
              onHow: () => _scrollTo(_howKey),
              onFeatures: () => _scrollTo(_featuresKey),
              onReviews: () => _scrollTo(_reviewsKey),
              userName: widget.currentUser?.fullName,
              onLogout: () => AuthService().signOut(),
              onBookings: _showBookings,
              onMenu: _showMobileMenu,
            ),
          ),
          SliverToBoxAdapter(child: _Hero()),
          SliverToBoxAdapter(
            child: Container(
              key: _fleetKey,
              child: _FleetSection(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              key: _howKey,
              child: const _HowItWorks(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              key: _featuresKey,
              child: const _Features(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              key: _reviewsKey,
              child: const _Reviews(),
            ),
          ),
          const SliverToBoxAdapter(child: _Footer()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0175C2),
        foregroundColor: Colors.white,
        onPressed: () => _scrollTo(_fleetKey),
        child: const Icon(Icons.pedal_bike),
      ),
    );
  }

  Widget _Hero() {
    final compact = MediaQuery.sizeOf(context).width < 700;
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        compact ? 52 : 72,
        18,
        compact ? 52 : 70,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF02569B),
            Color(0xFF02569B),
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text(
                  '●  Available in Lahore • Islamabad • Skardu • Hunza • Peshawar • Karachi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFA7F3D0),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'PEDAL YOUR WAY ACROSS ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 34 : 58,
                  fontWeight: FontWeight.w900,
                  height: 1.03,
                ),
              ),
              Text(
                'PAKISTAN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF99F6E4),
                  fontSize: compact ? 34 : 58,
                  fontWeight: FontWeight.w900,
                  height: 1.03,
                ),
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 760),
                child: Text(
                  'Pakistan’s premier bicycle rental platform. Rent top-tier Mountain MTBs, Road Bikes & Electric E-Bikes for city commuting or northern adventures.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 16,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _SearchBox(
                cityFilter: cityFilter,
                categoryFilter: categoryFilter,
                searchDate: searchDate,
                cities: cities,
                categories: categories,
                onCity: (v) => setState(() => cityFilter = v == 'All Pakistan Cities' ? 'All' : v),
                onCategory: (v) => setState(() => categoryFilter = v),
                onDate: _pickSearchDate,
                onSearch: _applySearch,
              ),
              const SizedBox(height: 38),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 42,
                runSpacing: 20,
                children: [
                  _Stat(value: '200+', label: 'Inspected Cycles'),
                  _Stat(value: '6 Cities', label: 'Pickup Locations'),
                  _Stat(value: '4.9/5', label: 'Rider Rating'),
                  _Stat(value: '24/7', label: 'Roadside Support'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _FleetSection() {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1050 ? 3 : width >= 700 ? 2 : 1;

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.fromLTRB(18, compactPad(context), 18, compactPad(context) + 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 800;
                  final chips = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: narrow ? WrapAlignment.start : WrapAlignment.end,
                    children: categories.map((cat) {
                      final active = categoryFilter == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: active,
                        onSelected: (_) => setState(() => categoryFilter = cat),
                        selectedColor: const Color(0xFF0175C2),
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: active ? Colors.white : const Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      );
                    }).toList(),
                  );
                  const title = SectionTitle(
                    eyebrow: 'Our Premium Fleet',
                    title: 'Select Your Ride',
                    description:
                        'High-performance bicycles maintained by certified mechanics before every rental.',
                  );
                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [title, const SizedBox(height: 20), chips],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: title),
                      const SizedBox(width: 30),
                      Flexible(child: chips),
                    ],
                  );
                },
              ),
              if (cityFilter != 'All') ...[
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF8FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD9EEFF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt_outlined, size: 16, color: Color(0xFF0175C2)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Filtered by City Hub: $cityFilter',
                          style: const TextStyle(
                            color: Color(0xFF02569B),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => cityFilter = 'All'),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 26),
              if (filteredCycles.isEmpty)
                _EmptyFleet(
                  onReset: () => setState(() {
                    cityFilter = 'All';
                    categoryFilter = 'All Cycles';
                  }),
                )
              else
                _ResponsiveGrid(
                  columns: columns,
                  spacing: 22,
                  children: [
                    for (final cycle in filteredCycles)
                      CycleCard(
                        cycle: cycle,
                        onBook: () => _showBooking(cycle),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBookings() async {
    final data = await BackendService().fetchCustomerBookings();
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => _BookingsDialog(bookings: data),
    );
  }

  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF0175C2),
                  child: Icon(Icons.pedal_bike, color: Colors.white),
                ),
                title: Text(
                  widget.currentUser?.fullName ?? 'PedalPoint Menu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: widget.currentUser == null
                    ? null
                    : Text(
                        widget.currentUser!.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              _menuItem(Icons.home_outlined, 'Home', () {
                Navigator.pop(context);
              }),
              _menuItem(Icons.pedal_bike, 'Browse Cycles', () {
                Navigator.pop(context);
                _scrollTo(_fleetKey);
              }),
              _menuItem(Icons.list_alt, 'How It Works', () {
                Navigator.pop(context);
                _scrollTo(_howKey);
              }),
              _menuItem(Icons.shield_outlined, 'Why Choose Us', () {
                Navigator.pop(context);
                _scrollTo(_featuresKey);
              }),
              _menuItem(Icons.star_border, 'Rider Reviews', () {
                Navigator.pop(context);
                _scrollTo(_reviewsKey);
              }),
              _menuItem(Icons.receipt_long_outlined, 'My Saved Rentals', () {
                Navigator.pop(context);
                _showBookings();
              }),
              const Divider(),
              _menuItem(Icons.logout, 'Sign Out', () {
                Navigator.pop(context);
                AuthService().signOut();
              }),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _menuItem(IconData icon, String text, VoidCallback action) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0175C2)),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      onTap: action,
    );
  }
}

class _Header extends StatelessWidget {
  final String? userName;
  final VoidCallback onLogout;
  final int bookingCount;
  final VoidCallback onHome;
  final VoidCallback onFleet;
  final VoidCallback onHow;
  final VoidCallback onFeatures;
  final VoidCallback onReviews;
  final VoidCallback onBookings;
  final VoidCallback onMenu;

  const _Header({
    this.userName,
    required this.onLogout,
    required this.bookingCount,
    required this.onHome,
    required this.onFleet,
    required this.onHow,
    required this.onFeatures,
    required this.onReviews,
    required this.onBookings,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final wide = screenWidth >= 1100;
    final tiny = screenWidth < 400;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tiny ? 10 : 18),
      child: Row(
        children: [
          Flexible(
            child: InkWell(
            onTap: onHome,
            child: Row(
              children: [
                Container(
                  width: tiny ? 38 : 44,
                  height: tiny ? 38 : 44,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    gradient: LinearGradient(
                      colors: [Color(0xFF02569B), Color(0xFF0175C2), Color(0xFF00B4AB)],
                    ),
                  ),
                  child: const Icon(Icons.pedal_bike, color: Colors.white),
                ),
                SizedBox(width: tiny ? 8 : 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PedalPoint',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: tiny ? 18 : 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (!tiny)
                        const Text(
                          'CYCLE RENTAL PAKISTAN',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 1.2,
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
          const SizedBox(width: 8),
          const Spacer(),
          if (wide)
            Row(
              children: [
                _nav('Home', onHome),
                _nav('Cycle Fleet', onFleet),
                _nav('How It Works', onHow),
                _nav('Why Choose Us', onFeatures),
                _nav('Reviews', onReviews),
                TextButton.icon(
                  onPressed: onBookings,
                  icon: const Icon(Icons.receipt_long_outlined, size: 17),
                  label: Row(
                    children: [
                      const Text('My Rentals'),
                      if (bookingCount > 0) ...[
                        const SizedBox(width: 5),
                        CircleAvatar(
                          radius: 9,
                          backgroundColor: const Color(0xFF10B981),
                          child: Text(
                            '$bookingCount',
                            style: const TextStyle(fontSize: 9, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout, size: 16),
                  label: Text(userName != null ? userName!.split(' ').first : 'Sign Out'),
                ),
              ],
            )
          else
            Row(
              children: [
                IconButton(
                  tooltip: 'My Rentals',
                  onPressed: onBookings,
                  icon: Badge(
                    isLabelVisible: bookingCount > 0,
                    label: Text('$bookingCount'),
                    child: const Icon(Icons.receipt_long_outlined),
                  ),
                ),
                IconButton(
                  tooltip: 'Sign Out',
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
                ),
                IconButton(
                  tooltip: 'Menu',
                  onPressed: onMenu,
                  icon: const Icon(Icons.menu),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _nav(String text, VoidCallback action) => TextButton(
        onPressed: action,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
}

class _SearchBox extends StatelessWidget {
  final String cityFilter;
  final String categoryFilter;
  final DateTime? searchDate;
  final List<String> cities;
  final List<String> categories;
  final ValueChanged<String> onCity;
  final ValueChanged<String> onCategory;
  final VoidCallback onDate;
  final VoidCallback onSearch;

  const _SearchBox({
    required this.cityFilter,
    required this.categoryFilter,
    required this.searchDate,
    required this.cities,
    required this.categories,
    required this.onCity,
    required this.onCategory,
    required this.onDate,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 800;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Flex(
        direction: compact ? Axis.vertical : Axis.horizontal,
        children: [
          Expanded(
            flex: compact ? 0 : 1,
            child: _selector(
              'CITY HUB',
              Icons.location_on_outlined,
              cities,
              cityFilter == 'All' ? 'All Pakistan Cities' : cityFilter,
              onCity,
            ),
          ),
          SizedBox(
            width: compact ? 0 : 10,
            height: compact ? 10 : 0,
          ),
          Expanded(
            flex: compact ? 0 : 1,
            child: _selector(
              'CYCLE TYPE',
              Icons.pedal_bike,
              categories,
              categoryFilter,
              onCategory,
            ),
          ),
          SizedBox(
            width: compact ? 0 : 10,
            height: compact ? 10 : 0,
          ),
          Expanded(
            flex: compact ? 0 : 1,
            child: InkWell(
              onTap: onDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'PICKUP DATE',
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                child: Text(
                  searchDate == null ? 'Select date' : _formatDate(searchDate!),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          SizedBox(
            width: compact ? 0 : 10,
            height: compact ? 12 : 0,
          ),
          Expanded(
            flex: compact ? 0 : 1,
            child: SizedBox(
              width: compact ? double.infinity : null,
              child: ElevatedButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search),
                label: const Text('Find Cycles'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selector(
    String label,
    IconData icon,
    List<String> values,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: values.contains(value) ? value : values.first,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: values
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(
                  v,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ))
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF6EE7B7),
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyFleet extends StatelessWidget {
  final VoidCallback onReset;

  const _EmptyFleet({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.pedal_bike, size: 54, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          const Text(
            'No Bicycles Match Selection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try switching categories or clearing city filters.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onReset,
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('1', 'Search & Choose', 'Browse our verified fleet of MTBs, Road, and E-bikes based on your city and riding needs.', 'Pick your city'),
      ('2', 'Configure & Book', 'Select rental dates, choose safety gear add-ons (Helmet, GPS, Bags), and fill customer details.', 'Instant calculation'),
      ('3', 'Doorstep or Hub Pickup', 'Collect your cycle from our city hub or opt for doorstep delivery directly to your hotel or home.', 'Verified handover'),
      ('4', 'Pedal Away!', 'Enjoy your journey with 24/7 roadside assistance. Return the bike at any designated city hub.', 'Hassle-free return'),
    ];

    return Container(
      color: const Color(0xFFF1F5F9),
      padding: EdgeInsets.fromLTRB(18, compactPad(context), 18, compactPad(context) + 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              const SectionTitle(
                eyebrow: 'Simple Rental Process',
                title: 'How PedalPoint Works',
                description: 'Get riding in four simple steps anywhere in Pakistan.',
                centered: true,
              ),
              const SizedBox(height: 42),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 600 ? 2 : 1;
                  return _ResponsiveGrid(
                    columns: cols,
                    spacing: 18,
                    children: [for (final step in steps) _StepCard(data: step)],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final (String, String, String, String) data;

  const _StepCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFE0F2FE),
              child: Text(
                data.$1,
                style: const TextStyle(
                  color: Color(0xFF0175C2),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              data.$2,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              data.$3,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${data.$4}  →',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0175C2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Features extends StatelessWidget {
  const _Features();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.local_shipping_outlined, 'Doorstep Delivery', 'We deliver tuned cycles straight to your residence or hotel across Lahore, Islamabad, Skardu & Hunza.'),
      (Icons.build_outlined, 'Certified Maintenance', 'Every bicycle undergoes a rigorous 25-point mechanical tune-up including hydraulic disc brake inspection.'),
      (Icons.phone_in_talk_outlined, '24/7 Roadside Assistance', 'Experiencing a flat tire or chain drop? Our mobile mechanics dispatch to your exact location fast.'),
      (Icons.schedule, 'Flexible Hourly & Daily Rates', 'Rent for 4 hours for a quick city tour or up to 30 days for extended northern mountain expeditions.'),
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(18, compactPad(context), 18, compactPad(context) + 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              const SectionTitle(
                eyebrow: 'The PedalPoint Advantage',
                title: 'Why Choose PedalPoint?',
                description: 'Built specifically for cycling enthusiasts and eco-friendly travelers across Pakistan.',
                centered: true,
              ),
              const SizedBox(height: 42),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 600 ? 2 : 1;
                  return _ResponsiveGrid(
                    columns: cols,
                    spacing: 16,
                    children: [
                      for (final item in items)
                        Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF8FF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(item.$1, color: const Color(0xFF0175C2)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                item.$2,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.$3,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews();

  @override
  Widget build(BuildContext context) {
    const reviews = [
      ('SA', 'Saad Ali', 'Islamabad • Rented Mountain MTB', 'Rented two Trek Marlin MTBs for a 4-day trip in Skardu. The bikes were exceptionally well tuned, smooth gears, and included helmets & mini-pumps. Best rental service in Pakistan!'),
      ('MA', 'Mariam Ahmed', 'Lahore • Rented Electric E-Bike', 'The E-bike made exploring Lahore\'s Gulberg and Old City effortless! Delivery was right on time at my hotel. Will definitely rent again.'),
      ('BH', 'Bilal Hassan', 'Peshawar • Rented City Hybrid', 'Awesome experience in Hunza Valley! The GPS tracker and pannier bags add-ons made our bike touring super convenient. 10/10 service.'),
    ];

    return Container(
      color: const Color(0xFF0F172A),
      padding: EdgeInsets.fromLTRB(18, compactPad(context), 18, compactPad(context) + 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              const Text(
                'RIDER COMMUNITY',
                style: TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Loved By Cyclists Across Pakistan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 42),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth >= 900 ? 3 : constraints.maxWidth >= 600 ? 2 : 1;
                  return _ResponsiveGrid(
                    columns: cols,
                    spacing: 18,
                    children: [
                      for (final r in reviews)
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '★★★★★',
                              style: TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 13,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '"${r.$4}"',
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 12,
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Color(0xFF334155)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFF0175C2),
                                  child: Text(
                                    r.$1,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.$2,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      r.$3,
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020617),
      padding: const EdgeInsets.fromLTRB(18, 48, 18, 25),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 600 ? 2 : 1;
                  return _ResponsiveGrid(
                    columns: cols,
                    spacing: 30,
                    children: [
                      _footerCol(
                        'PedalPoint',
                        'Pakistan\'s leading cycle rental app. Dedicated exclusively to providing high-quality bicycles for city commutes and mountain trails.',
                        Icons.pedal_bike,
                      ),
                      _footerList(
                        'Hub Locations',
                        const [
                          'Islamabad: F-6 Markaz Hub',
                          'Lahore: Gulberg III Phase',
                          'Skardu: Airport Road Point',
                          'Hunza: Main Bazaar Karimabad',
                          'Peshawar: University Road Hub',
                          'Karachi: DHA Phase 6 Point',
                        ],
                      ),
                      _footerList(
                        'Cycle Fleet',
                        const [
                          'Mountain MTBs (Trek, Giant)',
                          'Road Racing Bikes (Specialized)',
                          'Electric Pedal-Assist E-Bikes',
                          'City & Trekking Hybrids',
                        ],
                      ),
                      _footerList(
                        'Helpline & Support',
                        const [
                          '+92 (051) 8899770',
                          'support@pedalpoint.pk',
                          '08:00 AM - 10:00 PM Daily',
                        ],
                      ),
                    ],
                  );
                },
              ),
              const Divider(color: Color(0xFF1E293B), height: 45),
              const Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 6,
                children: [
                  Text(
                    '© 2026 PedalPoint Cycle Rentals. All rights reserved.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                  ),
                  Text(
                    'Flutter Web / Material Design 3 Architecture',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerCol(String title, String body, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF0175C2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          body,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _footerList(String title, List<String> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        ...values.map(
          (v) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(
              '• $v',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReceiptDialog extends StatelessWidget {
  final Booking booking;

  const _ReceiptDialog({required this.booking});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: const BoxDecoration(
                color: Color(0xFF059669),
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0x33FFFFFF),
                    child: Icon(Icons.check, color: Colors.white, size: 34),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _receiptRow('Receipt Ref', booking.refCode),
                  _receiptRow('Rider Name', booking.customerName),
                  _receiptRow('CNIC / Passport', booking.cnic),
                  _receiptRow('WhatsApp', booking.phone),
                  _receiptRow('Reserved Cycle', booking.bikeTitle),
                  _receiptRow('Pick-Up Hub', booking.city),
                  _receiptRow('Delivery', booking.delivery),
                  _receiptRow('Rental Dates', '${booking.startDate} to ${booking.endDate}'),
                  _receiptRow('Duration', '${booking.days} Days'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Fees Paid',
                          style: TextStyle(
                            color: Color(0xFF047857),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'PKR ${_money(booking.totalAmount)}',
                          style: const TextStyle(
                            color: Color(0xFF047857),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              await ReceiptPdfService.printReceipt(booking);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not open print dialog: $e'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.print_outlined),
                          label: const Text('Print'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await ReceiptPdfService.downloadReceipt(booking);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Receipt PDF downloaded.'),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not download PDF: $e'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Download PDF'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _money(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _BookingsDialog extends StatelessWidget {
  final List<Booking> bookings;

  const _BookingsDialog({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.receipt_long, color: Color(0xFF0175C2)),
          SizedBox(width: 8),
          Text(
            'My PedalPoint Rentals',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
      content: SizedBox(
        width: 650,
        height: 420,
        child: bookings.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, size: 54, color: Color(0xFFCBD5E1)),
                    SizedBox(height: 12),
                    Text(
                      'No rental bookings found yet.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Book your first bicycle from the catalogue!',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final b = bookings[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Chip(
                                    label: Text(
                                      b.refCode,
                                      style: const TextStyle(
                                        color: Color(0xFF0175C2),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFE0F2FE),
                                    side: BorderSide.none,
                                  ),
                                  Text(
                                    b.bikeTitle,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${b.city} • ${b.days} Days (${b.startDate} - ${b.endDate})',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                'Rider: ${b.customerName}',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'PKR ${_money(b.totalAmount)}',
                          style: const TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  static String _money(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

/// Section vertical padding that shrinks on phones.
double compactPad(BuildContext context) =>
    MediaQuery.sizeOf(context).width < 700 ? 44 : 68;

/// Lays children out in [columns] equal-width columns. Each row's cards are
/// stretched to the same height, and no fixed heights are needed, so content
/// can never overflow on narrow phones.
class _ResponsiveGrid extends StatelessWidget {
  final int columns;
  final double spacing;
  final List<Widget> children;

  const _ResponsiveGrid({
    required this.columns,
    required this.spacing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final slice = children.sublist(
        i,
        i + columns > children.length ? children.length : i + columns,
      );
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < columns; j++) ...[
                if (j > 0) SizedBox(width: spacing),
                Expanded(child: j < slice.length ? slice[j] : const SizedBox()),
              ],
            ],
          ),
        ),
      );
      if (i + columns < children.length) rows.add(SizedBox(height: spacing));
    }
    return Column(children: rows);
  }
}