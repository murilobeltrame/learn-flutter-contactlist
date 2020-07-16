import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String contactTable = 'ContactTable';
const String idColumn = 'id';
const String nameColumn = 'name';
const String emailColumn = 'email';
const String phoneColumn = 'phone';
const String imageColumn = 'image';

class ContactHelper {

  static final ContactHelper _instance = ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    else {
      _db = await _initDb();
      return _db;
    }
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'contacts.db');
    return openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute(
        'CREATE TABLE $contactTable ('
            '$idColumn INTEGER PRIMARY KEY, '
            '$nameColumn TEXT, '
            '$emailColumn TEXT, '
            '$phoneColumn TEXT, '
            '$imageColumn TEXT)'
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> result = await dbContact.query(
      contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imageColumn],
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    if (result != null && result.length > 0) {
      return Contact.fromMap(result.first);
    } else return null;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);
  }
  
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(), where: '$idColumn = ?', whereArgs: [contact.id]);
  }

  Future<List<Contact>> getAllContacts() async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.rawQuery('SELECT * FROM $contactTable');
    List<Contact> contacts = List();
    if (maps != null) {
      for (Map map in maps) {
        contacts.add(Contact.fromMap(map));
      }
    }
    return contacts;
  }

  Future<int> getCount() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery('SELECT COUNT(*) FROM $contactTable'));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }

  factory ContactHelper() => _instance;

  ContactHelper.internal();

}

class Contact {

  int id;
  String name;
  String email;
  String phone;
  String image;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    image = map[imageColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: image
    };
    if (id != null) map[idColumn] = id;
    return map;
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, phone: $phone, image: $image)';
  }
}