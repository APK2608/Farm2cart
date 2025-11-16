import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  AppDatabase._privateConstructor();
  static final AppDatabase instance = AppDatabase._privateConstructor();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'fruit_shop.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE cart (
          productId TEXT PRIMARY KEY,
          qty INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE wishlist (
          productId TEXT PRIMARY KEY
        )
      ''');
    });
  }

  Future<void> saveCart(Map<String, int> cart) async {
    final db = _db;
    if (db == null) return;
    final batch = db.batch();
    await db.delete('cart');
    cart.forEach((productId, qty) {
      batch.insert('cart', {'productId': productId, 'qty': qty});
    });
    await batch.commit(noResult: true);
  }

  Future<Map<String, int>> loadCart() async {
    final db = _db;
    if (db == null) return {};
    final rows = await db.query('cart');
    final map = <String, int>{};
    for (final r in rows) {
      final id = r['productId'] as String?;
      final qty = r['qty'] as int?;
      if (id != null && qty != null) map[id] = qty;
    }
    return map;
  }

  Future<void> saveWishlist(Set<String> wishlist) async {
    final db = _db;
    if (db == null) return;
    final batch = db.batch();
    await db.delete('wishlist');
    for (final id in wishlist) {
      batch.insert('wishlist', {'productId': id});
    }
    await batch.commit(noResult: true);
  }

  Future<Set<String>> loadWishlist() async {
    final db = _db;
    if (db == null) return {};
    final rows = await db.query('wishlist');
    final set = <String>{};
    for (final r in rows) {
      final id = r['productId'] as String?;
      if (id != null) set.add(id);
    }
    return set;
  }
}
