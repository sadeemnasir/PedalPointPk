class CycleModel {
  final String id;
  final String? ownerId;
  final String? businessName;
  final String title;
  final String category;
  final int price;
  final int stockCount;
  final double rating;
  final String gears;
  final String suspension;
  final String size;
  final List<String> cities;
  final String image;
  final String description;
  final bool isAvailable;

  const CycleModel({
    required this.id,
    this.ownerId,
    this.businessName,
    required this.title,
    required this.category,
    required this.price,
    this.stockCount = 5,
    required this.rating,
    required this.gears,
    required this.suspension,
    required this.size,
    required this.cities,
    required this.image,
    required this.description,
    this.isAvailable = true,
  });

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    final profileData = json['profiles'] as Map<String, dynamic>?;
    final rawCities = json['cities'];
    List<String> parsedCities = ['Islamabad'];
    if (rawCities is List) {
      parsedCities = rawCities.map((e) => e.toString()).toList();
    }

    final parsedStock = (json['stock_count'] as num?)?.toInt() ?? 1;

    return CycleModel(
      id: json['id'].toString(),
      ownerId: json['owner_id']?.toString(),
      businessName: profileData?['business_name'] as String?,
      title: json['title'] as String? ?? 'Cycle',
      category: json['category'] as String? ?? 'Mountain MTB',
      price: (json['price'] as num?)?.toInt() ?? 1500,
      stockCount: parsedStock,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      gears: json['gears'] as String? ?? 'Standard Shimano',
      suspension: json['suspension'] as String? ?? 'Front Fork',
      size: json['size'] as String? ?? 'Medium / Large',
      cities: parsedCities.isEmpty ? ['Islamabad'] : parsedCities,
      image: json['image'] as String? ??
          'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?auto=format&fit=crop&w=900&q=85',
      description: json['description'] as String? ?? '',
      isAvailable: (json['is_available'] as bool? ?? true) && parsedStock > 0,
    );
  }

  Map<String, dynamic> toInsertJson(String ownerId) => {
        'owner_id': ownerId,
        'title': title,
        'category': category,
        'price': price,
        'stock_count': stockCount,
        'rating': rating,
        'gears': gears,
        'suspension': suspension,
        'size': size,
        'cities': cities,
        'image': image,
        'description': description,
        'is_available': stockCount > 0 ? isAvailable : false,
      };
}
