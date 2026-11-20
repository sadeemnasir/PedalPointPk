import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/booking.dart';
import '../../models/cycle.dart';
import '../../services/auth_service.dart';
import '../../services/backend_service.dart';
import '../../services/receipt_pdf_service.dart';

class BusinessDashboard extends StatefulWidget {
  final AppUser user;
  const BusinessDashboard({super.key, required this.user});

  @override
  State<BusinessDashboard> createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  final _backend = BackendService();
  late Future<List<CycleModel>> _cyclesFuture;
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _cyclesFuture = _backend.fetchBusinessCycles();
      _bookingsFuture = _backend.fetchBusinessBookings();
    });
  }

  void _showAddCycleDialog() {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '5');
    final gearsCtrl = TextEditingController(text: '1x10 Speed Shimano Deore');
    final suspCtrl = TextEditingController(text: 'RockShox Judy 100mm');
    final sizeCtrl = TextEditingController(text: 'Medium / Large 29er');
    final descCtrl = TextEditingController();
    final imgCtrl = TextEditingController(
      text:
          'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?auto=format&fit=crop&w=900&q=85',
    );

    String category = 'Mountain MTB';
    final selectedCities = <String>{widget.user.cityHub ?? 'Islamabad'};
    const allCities = [
      'Islamabad',
      'Lahore',
      'Skardu',
      'Hunza',
      'Peshawar',
      'Karachi',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text(
            'Post New Bicycle to Fleet',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bicycle Model / Title *',
                        hintText: 'e.g. Trek Marlin 7 Mountain MTB',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Mountain MTB', child: Text('Mountain MTB')),
                        DropdownMenuItem(
                            value: 'Road Bike', child: Text('Road Bike')),
                        DropdownMenuItem(
                            value: 'Electric E-Bike',
                            child: Text('Electric E-Bike')),
                        DropdownMenuItem(
                            value: 'City Hybrid', child: Text('City Hybrid')),
                      ],
                      onChanged: (v) => setDialogState(() => category = v!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Daily Rent (PKR) *',
                              hintText: '2000',
                            ),
                            validator: (v) => int.tryParse(v ?? '') == null
                                ? 'Enter valid rate'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Available Stock *',
                              hintText: '5',
                            ),
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              return (n == null || n < 1)
                                  ? 'Enter stock >= 1'
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: gearsCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Gears / Drivetrain'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: suspCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Suspension / Fork'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: sizeCtrl,
                      decoration: const InputDecoration(labelText: 'Frame Size'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: imgCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Bicycle Image URL'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Condition & Description',
                        hintText: 'Describe condition, brakes, included lock, etc.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pickup City Hubs:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: allCities.map((city) {
                        final selected = selectedCities.contains(city);
                        return FilterChip(
                          label: Text(city),
                          selected: selected,
                          onSelected: (val) {
                            setDialogState(() {
                              if (val) {
                                selectedCities.add(city);
                              } else if (selectedCities.length > 1) {
                                selectedCities.remove(city);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await _backend.addCycle(
                  CycleModel(
                    id: '',
                    title: titleCtrl.text.trim(),
                    category: category,
                    price: int.parse(priceCtrl.text.trim()),
                    stockCount: int.parse(stockCtrl.text.trim()),
                    rating: 5.0,
                    gears: gearsCtrl.text.trim(),
                    suspension: suspCtrl.text.trim(),
                    size: sizeCtrl.text.trim(),
                    cities: selectedCities.toList(),
                    image: imgCtrl.text.trim(),
                    description: descCtrl.text.trim().isEmpty
                        ? 'Maintained by ${widget.user.businessName ?? widget.user.fullName}.'
                        : descCtrl.text.trim(),
                  ),
                );
                if (!mounted) return;
                Navigator.pop(ctx);
                _refresh();
              },
              child: const Text('Publish Cycle'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 650;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 74,
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.user.businessName ?? 'Business Fleet Portal',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Manager: ${widget.user.fullName} • ${widget.user.cityHub ?? 'Pakistan'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: _refresh,
            ),
            if (narrow)
              IconButton(
                tooltip: 'Sign Out',
                icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
                onPressed: () => AuthService().signOut(),
              )
            else
              TextButton.icon(
                onPressed: () => AuthService().signOut(),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign Out'),
              ),
            SizedBox(width: narrow ? 4 : 12),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pedal_bike), text: 'Bicycles & Stock'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Bookings'),
            ],
          ),
        ),
        floatingActionButton: narrow
            ? FloatingActionButton(
                tooltip: 'Post New Bicycle',
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                onPressed: _showAddCycleDialog,
                child: const Icon(Icons.add),
              )
            : FloatingActionButton.extended(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                onPressed: _showAddCycleDialog,
                icon: const Icon(Icons.add),
                label: const Text('Post New Bicycle'),
              ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: TabBarView(
              children: [
                // TAB 1: FLEET INVENTORY & STOCK
                FutureBuilder<List<CycleModel>>(
                  future: _cyclesFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final cycles = snap.data ?? [];
                    if (cycles.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.pedal_bike,
                                size: 64, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 12),
                            const Text(
                              'No bicycles posted yet.',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap "Post New Bicycle" to list cycles with stock & rates for customers.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(narrow ? 12 : 18, 18, narrow ? 12 : 18, 90),
                      itemCount: cycles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final c = cycles[i];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    c.image,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.pedal_bike, size: 42),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${c.category} • PKR ${c.price}/day • Hubs: ${c.cities.join(', ')}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Gears: ${c.gears} • Frame: ${c.size}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: c.stockCount > 0
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: c.stockCount > 0
                                          ? const Color(0xFFA7F3D0)
                                          : const Color(0xFFFECACA),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.remove, size: 16),
                                        onPressed: c.stockCount > 0
                                            ? () async {
                                                await _backend.updateCycleStock(
                                                    c.id, c.stockCount - 1);
                                                _refresh();
                                              }
                                            : null,
                                      ),
                                      Text(
                                        'Stock: ${c.stockCount}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          color: c.stockCount > 0
                                              ? const Color(0xFF047857)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.add, size: 16),
                                        onPressed: () async {
                                          await _backend.updateCycleStock(
                                              c.id, c.stockCount + 1);
                                          _refresh();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: c.isAvailable,
                                  onChanged: (val) async {
                                    await _backend.toggleCycleAvailability(
                                        c.id, val);
                                    _refresh();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    await _backend.deleteCycle(c.id);
                                    _refresh();
                                  },
                                ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                // TAB 2: INCOMING BOOKINGS
                FutureBuilder<List<Booking>>(
                  future: _bookingsFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final bookings = snap.data ?? [];
                    if (bookings.isEmpty) {
                      return const Center(
                        child: Text(
                          'No customer bookings received yet.',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(narrow ? 12 : 18, 18, narrow ? 12 : 18, 90),
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final b = bookings[i];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Flex(
                              direction: narrow ? Axis.vertical : Axis.horizontal,
                              crossAxisAlignment: narrow
                                  ? CrossAxisAlignment.stretch
                                  : CrossAxisAlignment.center,
                              children: [
                                narrow
                                    ? _bookingInfo(b)
                                    : Expanded(child: _bookingInfo(b)),
                                if (narrow) const SizedBox(height: 10),
                                Row(
                                  mainAxisSize: narrow
                                      ? MainAxisSize.max
                                      : MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'PKR ${b.totalAmount}',
                                      style: const TextStyle(
                                        color: Color(0xFF059669),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    if (!narrow) const SizedBox(width: 16),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: 'Download PDF Receipt',
                                          icon: const Icon(
                                              Icons.picture_as_pdf_outlined),
                                          onPressed: () =>
                                              ReceiptPdfService.downloadReceipt(
                                                  b),
                                        ),
                                        if (b.id != null)
                                          PopupMenuButton<String>(
                                            onSelected: (status) async {
                                              await _backend
                                                  .updateBookingStatus(
                                                      b.id!, status);
                                              _refresh();
                                            },
                                            itemBuilder: (_) => const [
                                              PopupMenuItem(
                                                  value: 'confirmed',
                                                  child: Text('Confirmed')),
                                              PopupMenuItem(
                                                  value: 'active',
                                                  child: Text('Active Ride')),
                                              PopupMenuItem(
                                                  value: 'completed',
                                                  child: Text('Completed')),
                                              PopupMenuItem(
                                                  value: 'cancelled',
                                                  child: Text('Cancelled')),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bookingInfo(Booking b) {
    return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 8,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Chip(
                                            label: Text(b.refCode),
                                            backgroundColor:
                                                const Color(0xFFE0F2FE),
                                          ),
                                          Text(
                                            b.bikeTitle,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Chip(
                                            label: Text(b.status.toUpperCase()),
                                            backgroundColor:
                                                const Color(0xFFD1FAE5),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Rider: ${b.customerName} • Phone: ${b.phone} • CNIC: ${b.cnic}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Hub: ${b.city} (${b.delivery}) • ${b.startDate} to ${b.endDate} (${b.days} Days)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  );
  }
}