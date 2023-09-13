import 'package:flutter/material.dart';
import 'package:todo_app/sql_helper.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> _journals = [];

  //This function is used to fetch all data from the databse
  void _refreshJournals() async {
    var data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
    });
  }

  //Loading the diary when the app starts
  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  //This function is triggered when the floating button is pressed
  //It will also be triggered when you want to edit/update an item
  void _showForm(int? id) async {
    // id == null -> create new item
    // id != null -> update an existing item

    if (id != null) {
      //The textfield should contain the text already inserted when updating
      var existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    } else {
      _titleController.text = '';
      _descriptionController.text = '';
    }

    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      isScrollControlled: true,
      context: context,
      elevation: 10,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 0, 8),
              child: Text(id == null ? "Create New Note" : "Edit Note",
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Title"),
                  filled: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
              child: TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Description"),
                    filled: true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
              child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () async {
                        setState(() async {
                          if (_titleController.text.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                "Enter Title",
                                style: TextStyle(fontSize: 17),
                              ),
                              backgroundColor: Colors.red,
                            ));
                          } else {
                            if (id == null) {
                              await _addItem();
                            } else {
                              await _updateItem(id);
                            }
                            _refreshJournals();
                          }
                          _titleController.text = '';
                          _descriptionController.text = '';
                          Navigator.of(context).pop();
                        });
                      },
                      child: Text(id == null ? "Create" : "Update"))),
            )
          ],
        ),
      ),
    );
  }

  //Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  //Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  //Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Succesfully deleted a note!")));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        title: const Text(
          "Notes",
          style: TextStyle(fontSize: 30),
        ),
        elevation: 5,
      ),
      body: ListView.builder(
        itemCount: _journals.length,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 15,
        ),
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.all(10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 3),
              child: Text(
                _journals[index]['title'],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 10),
              child: Text(_journals[index]['description']),
            ),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => _showForm(_journals[index]['id']),
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.yellow,
                      )),
                  IconButton(
                      onPressed: () => _deleteItem(
                            _journals[index]['id'],
                          ),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        backgroundColor: Colors.yellow,
        onPressed: () => _showForm(null),
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
