import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List App',
      home: MyHomePage(),
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });

    factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyAppState();
}

class _MyAppState extends State<MyHomePage> {
  final List<Task> tasks = [];
  
  //get DateFormat => null;

  @override
  void initState() {
    super.initState();
    _loadTasks(); 
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskListJson = prefs.getString('tasks');
    if (taskListJson != null) {
      final List<dynamic> decodedList = json.decode(taskListJson);
      final List<Task> loadedTasks = decodedList
          .map<Task>((item) => Task.fromJson(item))
          .toList();
      setState(() {
        tasks.addAll(loadedTasks);
      });
    }
  }

  
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskListJson = json.encode(tasks);
    prefs.setString('tasks', taskListJson);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 238, 190, 186),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 235, 106, 97),
          title: Text('To-Do List App'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (ctx, index) {
                  return ListTile(
                    title: Text(tasks[index].title),
                    subtitle: Text(DateFormat.yMMMd().format(tasks[index].dueDate)),
                    trailing: Checkbox(
                      value: tasks[index].isCompleted,
                      onChanged: (value) {
                        _toggleTaskCompletion(index);
                      },
                    ),
                    onLongPress: () {
                      _deleteTask(index);
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _addTask(context);
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _addTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController descriptionController = TextEditingController();
        DateTime selectedDate = DateTime.now();

        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  ).then((pickedDate) {
                    if (pickedDate != null) {
                      selectedDate = pickedDate;
                    }
                  });
                },
                child: Text('Select Due Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String id = DateTime.now().toString();
                final String title = titleController.text;
                final String description = descriptionController.text;

                if (title.isNotEmpty) {
                  final Task newTask = Task(
                    id: id,
                    title: title,
                    description: description,
                    dueDate: selectedDate,
                  );

                  setState(() {
                    tasks.add(newTask);
                    _saveTasks(); 
                  });

                  Navigator.of(ctx).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      _saveTasks(); 
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _saveTasks(); 
    });
  }
}
