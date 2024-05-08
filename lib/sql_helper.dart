import 'package:sqflite/sqflite.dart' as sql;
import 'package:flutter/foundation.dart';

class SQLHelper{
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE recipe(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT, 
      ingredients TEXT,
      instructions TEXT,
      createdAt TIMESTAP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'recipes.db',
      version: 1,
      onCreate: (sql.Database database, int version) async{
        await createTables(database);
      }
    ); 
  }
  
  static Future<int> createItem(String title, String? ingredients, String instructions) async {
    final db = await SQLHelper.db();

    final data  = {'title':title, 'ingredients': ingredients, 'instructions':instructions};
    final id = await db.insert(
      'recipe',
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace
      );
      return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db(); 
    return db.query('recipe');
  }

  static Future<List<Map<String, dynamic>>> getItem(String ingredients) async {
    final db = await SQLHelper.db();
    return db.query('recipe',where: "ingredients = ?");
  }
  static Future<int> updateItem(
    int id, String title, String? ingredients, String instructions) async {
      final db = await SQLHelper.db();

      final data = {
        'title': title,
        'ingredients': ingredients,
        'instructions': instructions,
        'createdAt': DateTime.now().toString()
      };

      final result = 
      await db.update('recipe', data, where: "id = ?", whereArgs: [id]);
      return result;
    }

    static Future <void> deleteItem(int id) async {
      final db = await SQLHelper.db();
      try{
        await db.delete("recipe", where: "id = ?",whereArgs: [id] );
      } catch (error){
        debugPrint("Something Went Wrong $error");
      }

    }
    
} 