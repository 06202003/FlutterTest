// task_list_tile.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/features/data/datasources/task_remote_datasource.dart';
import 'package:flutter_firebase/features/domain/entities/task_entity.dart';
import 'package:flutter_firebase/features/data/models/task_model.dart';
import 'package:flutter_firebase/features/domain/usecases/get_tasks_usecase.dart';

class TaskListTile extends StatelessWidget {
  final TaskEntity task;

  TaskListTile(this.task);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(task.imageUrl),
      ),
      title: Text(task.title),
      subtitle: Text(
        task.date ?? 'No date available',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showUpdateDialog(context, task);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context, task);
            },
          ),
        ],
      ),
      onTap: () {
        _showDescriptionModal(
          context,
          task.title ?? "No Title available",
          task.description ?? 'No description available',
          task.imageUrl ?? "No Image available",
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, TaskEntity task) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController imageUrlController = TextEditingController();

    // Set initial values in the text fields
    titleController.text = task.title ?? '';
    descriptionController.text = task.description ?? '';
    imageUrlController.text = task.imageUrl ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _updateTask(
                  context,
                  task,
                  titleController.text,
                  descriptionController.text,
                  imageUrlController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteTask(context, task);
                Navigator.of(context).pop();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _performDelete(context, task);
                Navigator.of(context).pop();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showDescriptionModal(
      BuildContext context, String title, String description, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height *
                0.6, // Sesuaikan tinggi sesuai kebutuhan
            child: Column(
              children: [
                // Tambahkan gambar dengan sudut bulat dan rasio aspek 16:9
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Tambahkan ruang di antara gambar dan deskripsi
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    description,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
          contentPadding:
              EdgeInsets.all(10.0), // Sesuaikan padding sesuai kebutuhan
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Tutup dialog
                Navigator.of(context).pop();
              },
              child: Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  void _updateTask(BuildContext context, TaskEntity task, String title,
      String description, String imageUrl) {
    try {
      if (task.id.isNotEmpty) {
        // Get a reference to the Firestore collection
        CollectionReference tasksCollection =
            FirebaseFirestore.instance.collection('tasks');

        // Get a reference to the specific document using its ID
        DocumentReference documentReference = tasksCollection.doc(task.id);

        // Update the document
        documentReference.update({
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'date': DateTime.now().toString(),
        }).then((_) {
          print('Task updated with ID: ${task.id}');
        }).catchError((error) {
          print('Error updating task: $error');
          // Handle error
        });
      } else {
        print('Error updating task: Invalid task ID');
      }
    } catch (e) {
      print('Error updating task: $e');
      // Handle the error as needed
    }
  }

  void _performDelete(BuildContext context, TaskEntity task) {
    try {
      // Get a reference to the Firestore collection
      CollectionReference tasksCollection =
          FirebaseFirestore.instance.collection('tasks');

      // Get a reference to the specific document using its ID
      DocumentReference documentReference =
          tasksCollection.doc(task.id.toString());

      // Delete the document
      documentReference.delete().then((_) {
        print('Task deleted with ID: ${task.id}');
      }).catchError((error) {
        print('Error deleting task: $error');
        // Handle error
      });
    } catch (e) {
      print('Error deleting task: $e');
      // Handle the error as needed
    }
  }
}
