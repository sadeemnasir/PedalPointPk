import 'package:flutter/material.dart';
import '../models/cycle.dart';
import '../models/booking.dart';
import '../models/app_user.dart';
import '../services/backend_service.dart';

class BookingSheet extends StatefulWidget {
  final CycleModel cycle;
  final String initialCity;
  final AppUser? currentUser;

  const BookingSheet({
    super.key,
    required this.cycle,
    this.initialCity = 'Islamabad',
    this.currentUser,
  });

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _cnic = TextEditingController();
  final _phone = TextEditingController();

  String city = 'Islamabad';
  String delivery = 'Hub Pickup';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));

  bool helmet = false;
  bool gps = false;
  bool bags = false;
  bool repair = false;

  int get days {
    final value = endDate.difference(startDate).inDays;
    return value > 0 ? value : 1;
  }

  int get addonsPerDay =>
      (helmet ? 200 : 0) +
      (gps ? 300 : 0) +
      (bags ? 250 : 0) +
      (repair ? 150 : 0);

  int get deliveryFee => delivery == 'Doorstep Delivery' ? 500 : 0;

  int get total => (widget.cycle.price * days) + (addonsPerDay * days) + deliveryFee;

  @override
  void initState() {
    super.initState();
    if (widget.cycle.cities.contains(widget.initialCity)) {
      city = widget.initialCity;
    } else {
      city = widget.cycle.cities.first;
    }
    if (widget.currentUser != null) {
      _name.text = widget.currentUser!.fullName;
      _phone.text = widget.currentUser!.phone ?? '';
      _cnic.text = widget.currentUser!.cnic ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _cnic.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected == null) return;

    setState(() {
      if (isStart) {
        startDate = selected;
        if (!endDate.isAfter(startDate)) {
          endDate = startDate.add(const Duration(days: 1));
        }
      } else {
        endDate = selected;
        if (!endDate.isAfter(startDate)) {
          endDate = startDate.add(const Duration(days: 1));
        }
      }
    });
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final ref =
        '#PP-${100000 + now.millisecondsSinceEpoch % 900000}';

    final draftBooking = Booking(
      refCode: ref,
      customerId: widget.currentUser?.id,
      cycleId: widget.cycle.id,
      bikeTitle: widget.cycle.title,
      city: city,
      delivery: delivery,
      startDate: _date(startDate),
      endDate: _date(endDate),
      days: days,
      customerName: _name.text.trim(),
      phone: _phone.text.trim(),
      cnic: _cnic.text.trim(),
      totalAmount: total,
      timestamp: _date(now),
    );

    final savedBooking = await BackendService().createBooking(draftBooking);

    if (!mounted) return;
    Navigator.pop(context, savedBooking);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 620;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
      child: FractionallySizedBox(
        widthFactor: width > 900 ? 0.58 : 1,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.94,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0175C2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.pedal_bike, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PedalPoint Rental Checkout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Step-by-step reservation',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(compact ? 16 : 24),
                    children: [
                      _selectedBike(),
                      const SizedBox(height: 20),
                      _heading(Icons.calendar_month, '1. Rental Duration & Location'),
                      const SizedBox(height: 12),
                      _responsiveFields(
                        compact,
                        [
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: city,
                            decoration: const InputDecoration(
                              labelText: 'Pick-Up City Hub',
                            ),
                            items: widget.cycle.cities
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) => setState(() => city = v!),
                          ),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: delivery,
                            decoration: const InputDecoration(
                              labelText: 'Delivery Option',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Hub Pickup',
                                child: Text('Self Pickup at Hub (Free)'),
                              ),
                              DropdownMenuItem(
                                value: 'Doorstep Delivery',
                                child: Text('Doorstep Delivery (+PKR 500)'),
                              ),
                            ],
                            onChanged: (v) => setState(() => delivery = v!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _responsiveFields(
                        compact,
                        [
                          _dateField(
                            'Start Date',
                            startDate,
                            () => _pickDate(true),
                          ),
                          _dateField(
                            'End Date',
                            endDate,
                            () => _pickDate(false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                'Calculated Total Duration:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0175C2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$days ${days == 1 ? 'Day' : 'Days'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _heading(Icons.shield_outlined, '2. Equipment Add-ons (Per Day)'),
                      const SizedBox(height: 10),
                      _addon('Safety Helmet', 200, helmet, (v) => setState(() => helmet = v)),
                      _addon('GPS Tracker', 300, gps, (v) => setState(() => gps = v)),
                      _addon('Pannier Bags', 250, bags, (v) => setState(() => bags = v)),
                      _addon('Mini Repair Kit', 150, repair, (v) => setState(() => repair = v)),
                      const SizedBox(height: 20),
                      _heading(Icons.person_outline, '3. Rider Details'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Full Name *'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 10),
                      _responsiveFields(
                        compact,
                        [
                          TextFormField(
                            controller: _cnic,
                            decoration: const InputDecoration(
                              labelText: 'CNIC / Passport No *',
                              hintText: '35202-0000000-0',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                          TextFormField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'WhatsApp Phone *',
                              hintText: '+92 300 1234567',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL PAYABLE AMOUNT',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'PKR ${_money(total)}',
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _confirm,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(compact ? 'Pay' : 'Confirm & Pay'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _selectedBike() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9EEFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.pedal_bike, color: Color(0xFF0175C2), size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cycle.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${widget.cycle.category} • PKR ${_money(widget.cycle.price)}/day',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Chip(
            label: Text('In Stock', style: TextStyle(fontSize: 10)),
            backgroundColor: Color(0xFFD1FAE5),
            labelStyle: TextStyle(color: Color(0xFF059669)),
            side: BorderSide.none,
          ),
        ],
      ),
    );
  }

  Widget _heading(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0175C2)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF0175C2),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _addon(
    String name,
    int price,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 7),
      color: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: CheckboxListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        secondary: Text(
          '+$price PKR',
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _responsiveFields(bool compact, List<Widget> children) {
    if (compact) {
      return Column(
        children: children
            .map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: child,
                ))
            .toList(),
      );
    }
    return Row(
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 10),
        Expanded(child: children[1]),
      ],
    );
  }

  Widget _dateField(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month, size: 19),
        ),
        child: Text(
          _date(date),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _money(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}