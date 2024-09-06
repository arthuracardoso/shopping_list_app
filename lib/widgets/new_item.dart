import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category_model.dart';
import 'package:shopping_list_app/models/grocery_model.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<StatefulWidget> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false; // Só para saber se está enviando a informação

  // Método para salvar o item
  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https('flutter-prep-b7f8f-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title,
          },
        ),
      );

      response.body;
      response.statusCode;
      final Map<String, dynamic> resData = jsonDecode(response.body);

      /// Para que não dê um aviso de que não é para utilizar "context" em uma função assíncrona
      /// Pode checar colocando esse if com o argumento "!context.mounted"
      /// Para assegurar ao flutter que não estaremos referenciando um context desatualizado,
      /// ou que não faz mais parte da tela.
      /// Basicamente, se o contexto não estiver ativo "mounted" retorna sem executar
      /// o "Navigator.of(context).pop()". Ou seja, se o Widget que esse contexto pertence
      /// não faz mais parte da tela, retorna e não executa o código posterior
      if (!context.mounted) {
        return;
      }

      /// Por que aparece o "Don't use 'BuildContext's across async gaps"?
      /// Porque, quando tem o "await" o Flutter fica sem saber se o "context" ainda será
      /// o mesmo quando a operação for finalizada, e que ele pode estar então se referenciando
      /// a um Widget que não existe mais.
      Navigator.of(context).pop(GroceryModel(
        id: resData['name'],
        name: _enteredName,
        quantity: _enteredQuantity,
        category: _selectedCategory,
      ));
      /*Navigator.of(context).pop(
        GroceryModel(
          id: DateTime.now().toString(),
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add new item')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50, // Para limitar a quantidade de caracteres
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be between 1 and 50 characters';
                    }
                    return null;
                  },
                  onSaved: (newValue) => _enteredName = newValue!,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    /// Tem que usar o "Expanded" porque o TextFormField é unconstrained
                    /// no eixo horizontal, assim como "Row()", ai dá erro se não colocar
                    /// dentro do Expanded, para que ocupe apenas o espaço disponível
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        initialValue: _enteredQuantity.toString(),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Must be a valid positive number';
                          }
                          return null;
                        },
                        onSaved: (newValue) =>
                            _enteredQuantity = int.tryParse(newValue!)!,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(category.value.title),
                                ],
                              ),
                            )
                        ],
                        onChanged: (value) {
                          // Aqui precisa do "setState" porque uma mudança de valor irá acarretar numa mudança na UI
                          // Não precisa chamar o "onSaved" porque já estamos colocando na variável
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!
                                  .reset(); // Faz com que resete todos os valores entrados
                            },
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: _isSending ? null : _saveItem,
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Add Item'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
