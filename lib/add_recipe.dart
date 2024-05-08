import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:newobjectdetectionyolov5/sql_helper.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  List<Map<String, dynamic>> _recipe = [];

  bool _isLoading = true;

  void _refreshRecipe() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _recipe = data;
      _isLoading = false;
    });
  }
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  Future<void> _addItem() async {
    await SQLHelper.createItem(
      _titleController.text, _ingredientsController.text, _instructionsController.text
    );
    _refreshRecipe();
  }

   Future<void> _updateItem() async {
    await SQLHelper.createItem(
      _titleController.text, _ingredientsController.text, _instructionsController.text
    );
    _refreshRecipe();
  }
  void _showForm(int? id) async {
    if (id != null){

      final existingRecipe = 
      _recipe.firstWhere((element) => element['id'] == id );
      _titleController.text = existingRecipe['title'];
      _ingredientsController.text = existingRecipe['ingredients'];
      _instructionsController.text = existingRecipe['instructions'];
    }
    showModalBottomSheet(context: context, isScrollControlled: true,
    builder: (_) => Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15,
        bottom: MediaQuery.of(context).viewInsets.bottom + 100,
        
      ),child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: 'Recipe Title'),
            ),
        
            SizedBox(height: 20,),
        
            TextField(
              controller: _ingredientsController,
              decoration: InputDecoration(hintText: 'Ingredients'),
            ),
        
            SizedBox(height: 20,),
        
            TextField(
              controller: _instructionsController,
              decoration: InputDecoration(hintText: 'Instructions'),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: () async {
              if (id == null){
                await _addItem();
              }
              if (id != null){
                await _updateItem();
              }

              _titleController.text ='';
              _ingredientsController.text = '';
              _instructionsController.text = '';

              Navigator.of(context).pop();
            }, child: Text(id == null ? 'Create New' : 'Update'))
          ],
        ),
      ),
    ));
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.pink, 
      title: Text('ADD RECIPE'),
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add),
       onPressed: () => _showForm(null)  ),
        
    );
  }
}