import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Vehicle.dart';

void main() {
  //runApp(MyVehicleApp());
  runApp(MyToDoApp());
}

class ApiConstants {
  static const String backendBaseUrl = 'https://parseapi.back4app.com';
  static const String yourClassName = 'VehicleManagement';
  static const String yourAppId = 'vvfzJQuFMiVYT55mH2dExPQYYlJvHY6aDxZqtHqx';
  static const String yourRestApiKey = 'FKDhIui2GpWXVyTSRUsPpVE4QIGXod8uFxKYeLCM';
}

class MyToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Vehicle Table'),
        ),
        body: MyTable(),
      ),
    );
  }
}

class ApiHelper {
  static Uri getApiUrl(String path) {
    return Uri.parse('${ApiConstants.backendBaseUrl}/classes/$path');
  }

  static Map<String, String> getApiHeaders() {
    return {
      'X-Parse-Application-Id': ApiConstants.yourAppId,
      'X-Parse-REST-API-Key': ApiConstants.yourRestApiKey,
      'Content-Type': 'application/json',
    };
  }
}

class MyTable extends StatefulWidget {
  @override
  _MyTableState createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  TextEditingController ownerNameController = TextEditingController();
  TextEditingController regNumberController = TextEditingController();
  TextEditingController makeController = TextEditingController();
  TextEditingController modelController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      ApiHelper.getApiUrl(ApiConstants.yourClassName),
      headers: ApiHelper.getApiHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body)['results'];
      setState(() {
        data = List.from(responseData);
      });
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  void showAddDataForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Data'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: ownerNameController,
                    decoration: InputDecoration(labelText: 'Owner Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter owner name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: regNumberController,
                    decoration: InputDecoration(labelText: 'Registration Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter registration number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: makeController,
                    decoration: InputDecoration(labelText: 'Make'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter make';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: modelController,
                    decoration: InputDecoration(labelText: 'Model'),
                    validator: (value) {
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  addData();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void addData() async {
    final Map<String, dynamic> newData = {
      'OwnerName': ownerNameController.text,
      'RegistrationNumber': regNumberController.text,
      'Make': makeController.text,
      'Model': modelController.text,
    };

    final response = await http.post(
      ApiHelper.getApiUrl(ApiConstants.yourClassName),
      headers: ApiHelper.getApiHeaders(),
      body: jsonEncode(newData),
    );

    if (response.statusCode == 201) {
      // Data added successfully
      print('Data added successfully');
      // Fetch updated data
      fetchData();
    } else {
      // Failed to add data
      print('Failed to add data: ${response.statusCode}');
    }

    // Clear controllers
    ownerNameController.clear();
    regNumberController.clear();
    makeController.clear();
    modelController.clear();
  }

  void deleteData(String objectId) async {
    final response = await http.delete(
      ApiHelper.getApiUrl('${ApiConstants.yourClassName}/$objectId'),
      headers: ApiHelper.getApiHeaders(),
    );

    if (response.statusCode == 200) {
      // Data deleted successfully
      print('Data deleted successfully');
      // Fetch updated data
      fetchData();
    } else {
      // Failed to delete data
      print('Failed to delete data: ${response.statusCode}');
    }
  }

  void editData(String objectId) async {
    ownerNameController ??= TextEditingController();
    regNumberController ??= TextEditingController();
    makeController ??= TextEditingController();
    modelController ??= TextEditingController();

    ownerNameController.text = data.firstWhere((item) => item['objectId'] == objectId)['OwnerName'] ?? '';
    regNumberController.text = data.firstWhere((item) => item['objectId'] == objectId)['RegistrationNumber'] ?? '';
    makeController.text = data.firstWhere((item) => item['objectId'] == objectId)['Make'] ?? '';
    modelController.text = data.firstWhere((item) => item['objectId'] == objectId)['Model'] ?? '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: ownerNameController,
                    decoration: InputDecoration(labelText: 'Owner Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter owner name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: regNumberController,
                    decoration: InputDecoration(labelText: 'Registration Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter registration number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: makeController,
                    decoration: InputDecoration(labelText: 'Make'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter make';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: modelController,
                    decoration: InputDecoration(labelText: 'Model'),
                    validator: (value) {
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  updateData(objectId);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void updateData(String objectId) async {
    final Map<String, dynamic> updatedData = {
      'OwnerName': ownerNameController.text,
      'RegistrationNumber': regNumberController.text,
      'Make': makeController.text,
      'Model': modelController.text,
    };

    final response = await http.put(
      ApiHelper.getApiUrl('${ApiConstants.yourClassName}/$objectId'),
      headers: ApiHelper.getApiHeaders(),
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      // Data updated successfully
      print('Data updated successfully');
      // Fetch updated data
      fetchData();
    } else {
      // Failed to update data
      print('Failed to update data: ${response.statusCode}');
    }

    // Clear controllers
    ownerNameController.clear();
    regNumberController.clear();
    makeController.clear();
    modelController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text('Owner Name')),
            DataColumn(label: Text('Registration Number')),
            DataColumn(label: Text('Make')),
            DataColumn(label: Text('Model')),
            DataColumn(label: Text('Action')),
          ],
          rows: data.map((rowData) {
            return DataRow(
              cells: [
                DataCell(Text(rowData['OwnerName'].toString())),
                DataCell(Text(rowData['RegistrationNumber'].toString())),
                DataCell(Text(rowData['Make'].toString())),
                DataCell(Text(rowData['Model']?.toString() ?? '')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          editData(rowData['objectId']);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteData(rowData['objectId']);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddDataForm(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}