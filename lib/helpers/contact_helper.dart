import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nomeColumn = "nomeColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {

  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, "contactsnew.db");

    /*
      DELETA DB
      await deleteDatabase(path);
    */

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
       await db.execute(
         "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, "
                                    "$nomeColumn TEXT, "
                                    "$emailColumn TEXT, "
                                    "$phoneColumn TEXT, "
                                    "$imgColumn TEXT)"
       );
    });
  }

  Future<Contact> saveContact(Contact contact) async {

    Database database = await db;
    contact.id = await database.insert(contactTable, contact.toMap());
    return contact;
  }
  
  Future<Contact> getContact(int id) async {
    Database database = await db;
    List<Map> maps = await database.query(contactTable,
    columns: [idColumn, nomeColumn, emailColumn, phoneColumn, imgColumn],
    where: "$idColumn = ?",
    whereArgs: [id]);
    if(maps.length > 0) {
      return Contact.fromMap(maps.first);
    }
  }

  Future<int> deleteContact(int id) async{
    Database database = await db;
    return await database.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database database = await db;
    return await database.update(contactTable,
                                 contact.toMap(),
                                 where: "$idColumn = ?",
                                 whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database database = await db;
    List listMap  = await database.rawQuery("SELECT * FROM $contactTable ORDER BY nomeColumn");
    List<Contact> listaContatos = List();
    for(Map m in listMap) {
      listaContatos.add(Contact.fromMap(m));
    }
    return listaContatos;
  }

  Future<int> getNumber() async {
    Database database = await db;
    return Sqflite.firstIntValue(await database.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database database = await db;
    if(database.isOpen) {
      database.close();
    }
  }

}

class Contact {

  int id;
  String nome;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map) {

    id = map[idColumn];
    nome = map[nomeColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeColumn: nome,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, nome: $nome, email: $email, telefone: $phone, img: $img)";
  }


}