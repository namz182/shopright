import 'models.dart';

class SeedData {
  const SeedData._();

  static const List<(String, String)> categories = [
    ('Essential Staples', 'essential-staples'),
    ('Cooking Goods', 'cooking-goods'),
    ('Pantry Items', 'pantry-items'),
    ('Bakery', 'bakery'),
    ('Dairy', 'dairy'),
    ('Fresh Produce', 'fresh-produce'),
    ('Beverages', 'beverages'),
    ('Household', 'household'),
  ];

  static const List<Map<String, String?>> products = [
    {
      'name': 'Breakfast Meal 25kg',
      'unit': '25 kg',
      'icon': 'wheat',
      'category': 'Essential Staples',
    },
    {
      'name': 'Roller Meal 10kg',
      'unit': '10 kg',
      'icon': 'wheat',
      'category': 'Essential Staples',
    },
    {
      'name': 'Cooking Oil 2.5L',
      'unit': '2.5 L',
      'icon': 'oil',
      'category': 'Cooking Goods',
    },
    {
      'name': 'Vegetable Oil 1L',
      'unit': '1 L',
      'icon': 'oil',
      'category': 'Cooking Goods',
    },
    {
      'name': 'White Sugar 2kg',
      'unit': '2 kg',
      'icon': 'sugar',
      'category': 'Pantry Items',
    },
    {
      'name': 'Brown Sugar 1kg',
      'unit': '1 kg',
      'icon': 'sugar',
      'category': 'Pantry Items',
    },
    {
      'name': 'Brown Bread',
      'unit': 'loaf',
      'icon': 'bread',
      'category': 'Bakery',
    },
    {
      'name': 'White Bread Loaf',
      'unit': 'loaf',
      'icon': 'bread',
      'category': 'Bakery',
    },
    {
      'name': 'Fresh Milk 1L',
      'unit': '1 L',
      'icon': 'milk',
      'category': 'Dairy',
    },
    {
      'name': 'Powdered Milk 500g',
      'unit': '500 g',
      'icon': 'milk',
      'category': 'Dairy',
    },
    {
      'name': 'Salt 1kg',
      'unit': '1 kg',
      'icon': 'salt',
      'category': 'Cooking Goods',
    },
    {
      'name': 'Chicken Stock Cubes',
      'unit': 'pack',
      'icon': 'cube',
      'category': 'Cooking Goods',
    },
    {
      'name': 'Tomatoes 1kg',
      'unit': '1 kg',
      'icon': 'tomato',
      'category': 'Fresh Produce',
    },
    {
      'name': 'Onions 1kg',
      'unit': '1 kg',
      'icon': 'onion',
      'category': 'Fresh Produce',
    },
    {
      'name': 'Potatoes 5kg',
      'unit': '5 kg',
      'icon': 'potato',
      'category': 'Fresh Produce',
    },
    {
      'name': 'Carrots 1kg',
      'unit': '1 kg',
      'icon': 'carrot',
      'category': 'Fresh Produce',
    },
    {
      'name': 'Rice 5kg',
      'unit': '5 kg',
      'icon': 'rice',
      'category': 'Pantry Items',
    },
    {
      'name': 'Spaghetti Pasta',
      'unit': '500 g',
      'icon': 'pasta',
      'category': 'Pantry Items',
    },
    {
      'name': 'Mango Juice 2L',
      'unit': '2 L',
      'icon': 'juice',
      'category': 'Beverages',
    },
    {
      'name': 'Toilet Paper 12 Pack',
      'unit': '12 pk',
      'icon': 'toilet',
      'category': 'Household',
    },
  ];

  static const List<Map<String, dynamic>> stores = [
    {
      'name': 'Shoprite Ndola',
      'slug': 'shoprite-ndola',
      'location': 'Ndola, Copperbelt',
      'distance_km': 2.1,
    },
    {
      'name': 'Local Market (Chifubu)',
      'slug': 'local-market-chifubu',
      'location': 'Chifubu, Ndola',
      'distance_km': 1.4,
    },
    {
      'name': 'Pick n Pay Copperbelt',
      'slug': 'pick-n-pay-copperbelt',
      'location': 'Ndola, Copperbelt',
      'distance_km': 3.8,
    },
    {
      'name': 'Melissa Supermarket',
      'slug': 'melissa-supermarket',
      'location': 'Ndola, Copperbelt',
      'distance_km': 4.5,
    },
  ];

  /// product name -> (store name -> price in ZMW).
  static const Map<String, Map<String, double>> prices = {
    'Breakfast Meal 25kg': {
      'Shoprite Ndola': 670.00,
      'Local Market (Chifubu)': 690.00,
      'Pick n Pay Copperbelt': 720.00,
      'Melissa Supermarket': 710.00,
    },
    'Cooking Oil 2.5L': {
      'Local Market (Chifubu)': 135.00,
      'Shoprite Ndola': 142.00,
      'Pick n Pay Copperbelt': 149.00,
      'Melissa Supermarket': 145.00,
    },
    'White Sugar 2kg': {
      'Pick n Pay Copperbelt': 55.00,
      'Shoprite Ndola': 59.00,
      'Local Market (Chifubu)': 60.00,
      'Melissa Supermarket': 63.00,
    },
  };

  static const double budget = 1200.00;

  static const List<ShoppingItem> shoppingList = [
    ShoppingItem(name: 'Breakfast Meal 25kg', category: 'Essential Staples', quantity: 2),
    ShoppingItem(name: 'Cooking Oil 2.5L', category: 'Cooking Goods', quantity: 1),
    ShoppingItem(name: 'White Sugar 2kg', category: 'Pantry Items', quantity: 1),
  ];

  static const List<Map<String, dynamic>> sampleComparisons = [
    {
      'reference': 'CMP-904-ZM21',
      'budget': 1200.00,
      'total_lowest': 860.00,
      'total_cheapest_store': 985.00,
      'total_savings': 125.00,
      'items_count': 3,
      'created_at': null, // "today"
      'items': [
        {'product_name': 'Breakfast Meal 25kg', 'product_unit': '25 kg', 'quantity': 2, 'store_name': 'Shoprite Ndola', 'unit_price': 670.00, 'line_total': 1340.00},
        {'product_name': 'Cooking Oil 2.5L', 'product_unit': '2.5 L', 'quantity': 1, 'store_name': 'Local Market (Chifubu)', 'unit_price': 135.00, 'line_total': 135.00},
        {'product_name': 'White Sugar 2kg', 'product_unit': '2 kg', 'quantity': 1, 'store_name': 'Pick n Pay Copperbelt', 'unit_price': 55.00, 'line_total': 55.00},
      ],
    },
    {
      'reference': 'CMP-882-ZM09',
      'budget': 1500.00,
      'total_lowest': 1245.50,
      'total_cheapest_store': 1300.50,
      'total_savings': 55.00,
      'items_count': 5,
      'created_at': 'yesterday',
      'items': [
        {'product_name': 'Roller Meal 10kg', 'product_unit': '10 kg', 'quantity': 1, 'store_name': 'Local Market (Chifubu)', 'unit_price': 355.00, 'line_total': 355.00},
        {'product_name': 'Fresh Milk 1L', 'product_unit': '1 L', 'quantity': 2, 'store_name': 'Shoprite Ndola', 'unit_price': 24.50, 'line_total': 49.00},
        {'product_name': 'Tomatoes 1kg', 'product_unit': '1 kg', 'quantity': 1, 'store_name': 'Local Market (Chifubu)', 'unit_price': 28.00, 'line_total': 28.00},
        {'product_name': 'Onions 1kg', 'product_unit': '1 kg', 'quantity': 1, 'store_name': 'Local Market (Chifubu)', 'unit_price': 22.00, 'line_total': 22.00},
        {'product_name': 'Rice 5kg', 'product_unit': '5 kg', 'quantity': 1, 'store_name': 'Shoprite Ndola', 'unit_price': 791.50, 'line_total': 791.50},
      ],
    },
    {
      'reference': 'CMP-856-ZM72',
      'budget': 450.00,
      'total_lowest': 395.00,
      'total_cheapest_store': 430.00,
      'total_savings': 35.00,
      'items_count': 2,
      'created_at': '2026-07-28',
      'items': [
        {'product_name': 'Mango Juice 2L', 'product_unit': '2 L', 'quantity': 1, 'store_name': 'Melissa Supermarket', 'unit_price': 210.00, 'line_total': 210.00},
        {'product_name': 'Toilet Paper 12 Pack', 'product_unit': '12 pk', 'quantity': 1, 'store_name': 'Pick n Pay Copperbelt', 'unit_price': 185.00, 'line_total': 185.00},
      ],
    },
  ];
}
