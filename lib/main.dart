import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      scaffoldBackgroundColor: Color(0xffccdbdc),
    ),
    home: ToDo(),
  ));
}

class ToDo extends StatefulWidget {
  const ToDo({super.key});

  @override
  State<ToDo> createState() => _ToDoState();
}

class _ToDoState extends State<ToDo> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _toDoList = [];
  bool isButtonActive = false;

  void _addToDo() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _toDoList.add(_controller.text);
        _controller.clear();
      });
      _saveNotes();
    }
  }

  void _deleteToDo(int index) {
    setState(() {
      _toDoList.removeAt(index);
    });
    _saveNotes();
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_toDoList);
    await prefs.setString('todo_list', encodedData);
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('todo_list');

    if (encodedData != null) {
      setState(() {
        _toDoList.clear();
        _toDoList.addAll(List<String>.from(jsonDecode(encodedData)));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateButtonState);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Color(0xFF003249),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              color: Colors.white,
              size: 35,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'ToDo List',
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.blueGrey.shade200, width: 2))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
// Text field
                  Expanded(
                    child: Material(
                      elevation: 3,
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: TextField(
                        maxLines: 3,
                        style: TextStyle(fontSize: 16.0),
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'What next To-Do?',
                          hintStyle: TextStyle(
                              color: Color(0xFFc2c2c2), fontSize: 16.0),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
// Add Button
                  ElevatedButton(
                    onPressed: isButtonActive
                        ? () {
                            _addToDo();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff007EA7),
                        minimumSize: Size(42, 40),
                        padding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 3),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                ],
              ),
            ),
// Task list
            Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 24),
                  itemCount: _toDoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteToDo(index);
                        },
                        background: Container(
                          decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              color: Color(0xffD59E9A)),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Color(0xff9AD1D5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            title: Text(_toDoList[index]),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
