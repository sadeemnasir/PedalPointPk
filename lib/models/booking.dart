class Booking {
  final String? id;
  final String refCode;
  final String? customerId;
  final String? cycleId;
  final String bikeTitle;
  final String city;
  final String delivery;
  final String startDate;
  final String endDate;
  final int days;
  final String customerName;
  final String phone;
  final String cnic;
  final int totalAmount;
  final String status;
  final String timestamp;

  const Booking({
    this.id,
    required this.refCode,
    this.customerId,
    this.cycleId,
    required this.bikeTitle,
    required this.city,
    required this.delivery,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.customerName,
    required this.phone,
    required this.cnic,
    required this.totalAmount,
    this.status = 'confirmed',
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'refCode': refCode,
        'customerId': customerId,
        'cycleId': cycleId,
        'bikeTitle': bikeTitle,
        'city': city,
        'delivery': delivery,
        'startDate': startDate,
        'endDate': endDate,
        'days': days,
        'customerName': customerName,
        'phone': phone,
        'cnic': cnic,
        'totalAmount': totalAmount,
        'status': status,
        'timestamp': timestamp,
      };

  Map<String, dynamic> toSupabaseInsert() => {
        'ref_code': refCode,
        if (customerId != null) 'customer_id': customerId,
        if (cycleId != null && cycleId!.length > 10) 'cycle_id': cycleId,
        'bike_title': bikeTitle,
        'city': city,
        'delivery': delivery,
        'start_date': startDate,
        'end_date': endDate,
        'days': days,
        'customer_name': customerName,
        'phone': phone,
        'cnic': cnic,
        'total_amount': totalAmount,
        'status': status,
      };

  factory Booking.fromSupabase(Map<String, dynamic> json) => Booking(
        id: json['id']?.toString(),
        refCode: json['ref_code'] as String? ?? '#PP-000000',
        customerId: json['customer_id']?.toString(),
        cycleId: json['cycle_id']?.toString(),
        bikeTitle: json['bike_title'] as String? ?? '',
        city: json['city'] as String? ?? '',
        delivery: json['delivery'] as String? ?? 'Hub Pickup',
        startDate: json['start_date'] as String? ?? '',
        endDate: json['end_date'] as String? ?? '',
        days: (json['days'] as num?)?.toInt() ?? 1,
        customerName: json['customer_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        cnic: json['cnic'] as String? ?? '',
        totalAmount: (json['total_amount'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? 'confirmed',
        timestamp: json['created_at']?.toString() ?? '',
      );

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id']?.toString(),
        refCode: json['refCode'] as String,
        customerId: json['customerId']?.toString(),
        cycleId: json['cycleId']?.toString(),
        bikeTitle: json['bikeTitle'] as String,
        city: json['city'] as String,
        delivery: json['delivery'] as String,
        startDate: json['startDate'] as String,
        endDate: json['endDate'] as String,
        days: json['days'] as int,
        customerName: json['customerName'] as String,
        phone: json['phone'] as String,
        cnic: json['cnic'] as String,
        totalAmount: json['totalAmount'] as int,
        status: json['status'] as String? ?? 'confirmed',
        timestamp: json['timestamp'] as String,
      );
}
