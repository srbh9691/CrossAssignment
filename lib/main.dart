import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Vehicle.dart';

void main() {
  //runApp(MyVehicleApp());
  runApp(MyApp());
}

class ApiConstants {
  static const String backendBaseUrl = 'https://parseapi.back4app.com';
  static const String yourClassName = 'TaskList';
  static const String yourAppId = 'vvfzJQuFMiVYT55mH2dExPQYYlJvHY6aDxZqtHqx';
  static const String yourRestApiKey =
      'FKDhIui2GpWXVyTSRUsPpVE4QIGXod8uFxKYeLCM';
}

class Task {
  final String? objectId;
  final String title;
  final String description;
  bool? done;

  Task({
    this.objectId,
    required this.title,
    required this.description,
    this.done,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      objectId: json['objectId'],
      title: json['Title'],
      description: json['Description'],
      done: json['Done'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Description': description,
      'Done': done ?? false,
    };
  }
}

class TaskService {
  Future<List<Task>> fetchTasks() async {
    final response = await http.get(
      Uri.parse(
          '${ApiConstants.backendBaseUrl}/classes/${ApiConstants.yourClassName}'),
      headers: {
        'X-Parse-Application-Id': ApiConstants.yourAppId,
        'X-Parse-REST-API-Key': ApiConstants.yourRestApiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> tasksJson = json.decode(response.body)['results'];
      return tasksJson.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  Future<void> addTask(Task task) async {
    final response = await http.post(
      Uri.parse(
          '${ApiConstants.backendBaseUrl}/classes/${ApiConstants.yourClassName}'),
      headers: {
        'X-Parse-Application-Id': ApiConstants.yourAppId,
        'X-Parse-REST-API-Key': ApiConstants.yourRestApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add task');
    }
  }

  Future<void> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse(
          '${ApiConstants.backendBaseUrl}/classes/${ApiConstants.yourClassName}/${task.objectId}'),
      headers: {
        'X-Parse-Application-Id': ApiConstants.yourAppId,
        'X-Parse-REST-API-Key': ApiConstants.yourRestApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(Task task) async {
    final response = await http.delete(
      Uri.parse(
          '${ApiConstants.backendBaseUrl}/classes/${ApiConstants.yourClassName}/${task.objectId}'),
      headers: {
        'X-Parse-Application-Id': ApiConstants.yourAppId,
        'X-Parse-REST-API-Key': ApiConstants.yourRestApiKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  Future<void> updateDoneStatus(Task task) async {
    final response = await http.put(
      Uri.parse(
          '${ApiConstants.backendBaseUrl}/classes/${ApiConstants.yourClassName}/${task.objectId}'),
      headers: {
        'X-Parse-Application-Id': ApiConstants.yourAppId,
        'X-Parse-REST-API-Key': ApiConstants.yourRestApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Done': task.done ?? false, // Ensure 'done' has a default value
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update done status');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService taskService = TaskService();
  late Future<List<Task>> _tasksFuture;
  bool _allTasksDone = false;

  @override
  void initState() {
    super.initState();
    _refreshTaskList();
  }

  Future<void> _refreshTaskList() async {
    setState(() {
      _tasksFuture = taskService.fetchTasks();
    });
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () async {
                final newTask = Task(
                  title: titleController.text,
                  description: descriptionController.text,
                );
                try {
                  await taskService.addTask(newTask);
                  print('Task added successfully');
                  Navigator.of(context).pop();
                  _refreshTaskList(); // Refresh task list after adding task
                } catch (e) {
                  print('Error adding task: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditTaskDialog(BuildContext context, Task task) async {
    TextEditingController titleController =
        TextEditingController(text: task.title);
    TextEditingController descriptionController =
        TextEditingController(text: task.description);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                final updatedTask = Task(
                  objectId: task.objectId,
                  title: titleController.text,
                  description: descriptionController.text,
                );
                try {
                  await taskService.updateTask(updatedTask);
                  print('Task updated successfully');
                  Navigator.of(context).pop();
                  _refreshTaskList(); // Refresh task list after updating task
                } catch (e) {
                  print('Error updating task: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteTask(Task task) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      try {
        await taskService.deleteTask(task);
        print('Task deleted successfully');
        _refreshTaskList(); // Refresh task list after deleting task
      } catch (e) {
        print('Error deleting task: $e');
      }
    }
  }

  void _viewTaskDetails(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }

  void _updateDoneStatus(Task task) async {
    if (task.done != null) {
      //task.done = !task.done!; // Toggle the 'done' status if it's not null
      taskService.updateDoneStatus(task).then((_) {
        print('Done status updated successfully');
        setState(() {
          // Update the state to reflect the changes in the UI
        });
      }).catchError((error) {
        print('Error updating done status: $error');
        // Handle error if the update fails
        // You can consider rolling back the local change if needed
      });
    }
  }

  Future<void> _markAllTasks(bool value) async {
    try {
      List<Task> tasks = await _tasksFuture; // Fetch tasks

      tasks.forEach((task) {
        task.done = value; // Toggle 'Done' status for all tasks locally
      });

      await Future.wait(tasks.map((task) async {
        await taskService.updateDoneStatus(task); // Update tasks in batch
      }));

      setState(() {
        _allTasksDone = value;
      });

      print('All tasks marked as ${value ? 'Done' : 'Not Done'} successfully');
    } catch (error) {
      print('Error marking all tasks: $error');
      // Handle error if marking tasks fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 96.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Complete All'),
                Checkbox(
                  value: _allTasksDone,
                  onChanged: (value) {
                    _markAllTasks(value ?? false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Task task = snapshot.data![index];
                return ListTile(
                  title: Row(
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: task.done ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                task.done = value ?? false;
                                print('Done ' + value.toString());
                              });
                              _updateDoneStatus(task);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditTaskDialog(context, task);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _confirmDeleteTask(task);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Text(task.description),
                  onTap: () {
                    _viewTaskDetails(context, task);
                  },
                  onLongPress: () {
                    _showEditTaskDialog(context, task);
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  TaskDetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${task.title}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Description: ${task.description}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Done: ${task.done ?? false ? 'Yes' : 'No'}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
