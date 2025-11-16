import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const FruitShopApp());

class FruitShopApp extends StatelessWidget {
  const FruitShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fruit Shop',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const RootScreen(),
      ),
    );
  }
}

// ----------------------
// App State (cart + wishlist)
// ----------------------
class AppState extends ChangeNotifier {
  final Map<Product, int> _cart = {};
  final Set<Product> _wishlist = {};

  Map<Product, int> get cart => Map.unmodifiable(_cart);
  Set<Product> get wishlist => Set.unmodifiable(_wishlist);

  void addToCart(Product p) {
    _cart[p] = (_cart[p] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromCart(Product p) {
    if (!_cart.containsKey(p)) {
      return;
    }
    final qty = _cart[p]! - 1;
    if (qty <= 0) {
      _cart.remove(p);
    } else {
      _cart[p] = qty;
    }
    notifyListeners();
  }

  void setQuantity(Product p, int q) {
    if (q <= 0) {
      _cart.remove(p);
    } else {
      _cart[p] = q;
    }
    notifyListeners();
  }

  int quantityOf(Product p) => _cart[p] ?? 0;

  void toggleWishlist(Product p) {
    if (_wishlist.contains(p)) {
      _wishlist.remove(p);
    } else {
      _wishlist.add(p);
    }
    notifyListeners();
  }

  bool isWishlisted(Product p) => _wishlist.contains(p);

  double get total {
    double sum = 0.0;
    _cart.forEach((p, q) => sum += p.price * q);
    return sum;
  }
}

// ----------------------
// Sample product model & sample data
// ----------------------
class Product {
  final String id;
  final String name;
  final String subtitle;
  final double price;
  final String assetImage; // path under assets/images/

  Product({required this.id, required this.name, required this.subtitle, required this.price, required this.assetImage});

  @override
  bool operator ==(Object other) => other is Product && id == other.id;
  @override
  int get hashCode => id.hashCode;
}

final List<Product> sampleProducts = [
  Product(id: 'tender', name: 'Tender', subtitle: '500g to 1.2 kg', price: 200.0, assetImage: 'assets/images/tender.png'),
  Product(id: 'raw', name: 'Raw Mango', subtitle: '1 Kg', price: 100.0, assetImage: 'assets/images/raw.png'),
  Product(id: 'sidhura', name: 'Sidhura', subtitle: '500g', price: 200.0, assetImage: 'assets/images/sidhura.png'),
  Product(id: 'coconut', name: 'Coconut', subtitle: 'King Coconut', price: 80.0, assetImage: 'assets/images/coconut.png'),
  Product(id: 'mango_juice', name: 'Mango Juice', subtitle: '1 L', price: 120.0, assetImage: 'assets/images/mango_juice.png'),
];

// ----------------------
// Root with bottom navigation
// ----------------------
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 1; // start at Home
  final _pages = [
    const LogoScreen(),
    const HomeScreen(),
    const WishlistScreen(),
    const CartScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) => _buildNavItem(i)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        onPressed: () => setState(() => _index = 2),
        child: const Icon(Icons.bookmark),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(int i) {
    final icons = [Icons.home, Icons.home, Icons.bookmark_border, Icons.shopping_cart, Icons.person];
    final labels = ['Logo', 'Home', 'Wishlist', 'My Cart', 'My Account'];
    final active = i == _index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = i),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icons[i], color: active ? Colors.black : Colors.grey[600]),
            const SizedBox(height: 4),
            Text(labels[i], style: TextStyle(fontSize: 11, color: active ? Colors.black : Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// ----------------------
// Logo / Splash screen
// ----------------------
class LogoScreen extends StatelessWidget {
  const LogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/welcome.png', width: 220, height: 220, errorBuilder: (_, __, ___) => const Icon(Icons.local_florist, size: 200,)),
            const SizedBox(height: 20),
            const Text('WELCOME', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Fresh fruits, local picks', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ----------------------
// Home Screen with search, carousel and grid
// ----------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.yellow[50]),
                    child: Row(children: const [Icon(Icons.search), SizedBox(width: 8), Text('Search')]),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(color: Colors.yellow[700], borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.place, color: Colors.white),
                )
              ],
            ),
          ),
          // simple banner
          SizedBox(
            height: 150,
            child: PageView(
              children: List.generate(3, (i) => _buildBanner(i)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: sampleProducts.map((p) => ProductCard(product: p)).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBanner(int index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.yellow[50]),
          child: Center(child: Text(index == 0 ? 'LIMITED OFFER' : index == 1 ? 'TOP PICKS' : 'SUMMER OFFER')),
        ),
      );
}

// ----------------------
// Product card and detail
// ----------------------
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetail(product: product))),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.yellow[50]),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(product.assetImage, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.local_florist, size: 56)),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(product.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () => Provider.of<AppState>(context, listen: false).addToCart(product),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ProductDetail extends StatelessWidget {
  final Product product;
  const ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: Text(product.name), backgroundColor: Colors.yellow[700]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset(product.assetImage, width: 200, height: 200, errorBuilder: (_, __, ___) => const Icon(Icons.local_florist, size: 160))),
            const SizedBox(height: 16),
            Text(product.subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
                    onPressed: () {
                      app.addToCart(product);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to cart'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(app.isWishlisted(product) ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                  onPressed: () => app.toggleWishlist(product),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ----------------------
// Wishlist, Cart and Account screens
// ----------------------
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final items = app.wishlist.toList();
    return SafeArea(
      child: items.isEmpty
          ? const Center(child: Text('No items in wishlist'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => ListTile(
                leading: Image.asset(items[i].assetImage, width: 48, height: 48, errorBuilder: (_, __, ___) => const Icon(Icons.local_florist)),
                title: Text(items[i].name),
                subtitle: Text('₹${items[i].price.toStringAsFixed(0)}'),
                trailing: IconButton(icon: const Icon(Icons.remove_circle), onPressed: () => app.toggleWishlist(items[i])),
              ),
            ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final cart = app.cart.entries.toList();
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text('Your cart is empty'))
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (_, i) {
                      final p = cart[i].key;
                      final q = cart[i].value;
                      return ListTile(
                        leading: Image.asset(p.assetImage, width: 48, height: 48, errorBuilder: (_, __, ___) => const Icon(Icons.local_florist)),
                        title: Text(p.name),
                        subtitle: Text('Qty: $q'),
                        trailing: Text('₹${(p.price * q).toStringAsFixed(0)}'),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ₹${app.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
                  onPressed: cart.isEmpty ? null : () {},
                  child: const Text('Checkout'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) => const SafeArea(child: Center(child: Text('Account (stub)')));
}
