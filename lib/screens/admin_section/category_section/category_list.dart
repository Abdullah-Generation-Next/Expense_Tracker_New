import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../../const/const.dart';

class CategoryScreen extends StatefulWidget {
  final String adminId;

  const CategoryScreen({Key? key, required this.adminId}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool alreadyExists = false;

  Future<void> _showAddCategoryDialog(BuildContext context, {QueryDocumentSnapshot? category}) async {
    if (category != null) {
      // _categoryController.text = category['name'].toString().contains('name') ? category['name'] : "";
      _categoryController.text = category['name'];
    } else {
      _categoryController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(category == null ? 'Add Category' : 'Edit Category'),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      CupertinoIcons.clear,
                      color: Colors.black,
                    )),
              ],
            ),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _categoryController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(hintText: 'Enter category name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category name cannot be empty';
                  }
                  if (alreadyExists) {
                    return 'Category with this name already exists. Try another name.';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _submitCategoryForm(context, category);
                },
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(category == null ? 'Create' : 'Update'),
                style: ButtonStyle(
                  // ignore: deprecated_member_use
                  backgroundColor: MaterialStatePropertyAll(themecolor),
                  // ignore: deprecated_member_use
                  foregroundColor: MaterialStatePropertyAll(kwhite),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _submitCategoryForm(BuildContext context, QueryDocumentSnapshot? category) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final categoryCollection =
          FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).collection('categories');

      final categoryName = _categoryController.text.trim().replaceAll(' ', '').toLowerCase();

      final querySnapshot = await categoryCollection.get();

      final duplicateExists = querySnapshot.docs.any((doc) {
        final existingName = doc['name']?.toString().trim().replaceAll(' ', '').toLowerCase();
        return existingName == categoryName && (category == null || doc.id != category.id);
      });

      if (duplicateExists) {
        Fluttertoast.showToast(
          msg: "Category with the same name already exists. Try adding a new one!",
        );
        setState(() {
          isLoading = false;
          alreadyExists = true;
        });
        _formKey.currentState!.validate();
        return;
      }

      if (category == null) {
        // Add new category
        await categoryCollection.add({
          'name': _categoryController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        Fluttertoast.showToast(msg: "Category added successfully!");
      } else {
        // Update existing category
        await categoryCollection.doc(category.id).update({
          'name': _categoryController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        Fluttertoast.showToast(msg: "Category updated successfully!");
      }

      _categoryController.clear();
      Navigator.pop(context);
      setState(() {
        isLoading = false;
        alreadyExists = false;
      });
    } catch (error) {
      Fluttertoast.showToast(msg: "Failed to process category: $error");
      Navigator.pop(context);
    } finally {
      setState(() {
        isLoading = false;
        alreadyExists = false;
      });
    }
  }

  Future<void> _deleteCategory(String categoryId) async {
    try {
      final categoryCollection =
          FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).collection('categories');

      await categoryCollection.doc(categoryId).delete();

      Fluttertoast.showToast(msg: "Category deleted successfully!");
    } catch (error) {
      Fluttertoast.showToast(msg: "Failed to delete category: $error");
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, categoryId, {String? categoryName}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss the dialog.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this Category "${categoryName}" ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                _deleteCategory(categoryId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryCollection =
        FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).collection('categories');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: themecolor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: kwhite),
        // title: Text(
        //   'Categories ${totalCategoryCount}',
        //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: kwhite),
        // ),
        title: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).collection('categories').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: kwhite,
                ),
              );
            }
            if (snapshot.hasError) {
              return Text(
                'Categories (Error)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: kwhite,
                ),
              );
            }
            final totalCategories = snapshot.data?.docs.length ?? 0;
            return Text(
              'Categories ($totalCategories)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                color: kwhite,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            tooltip: "Add Category",
            icon: Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoryCollection.orderBy('name', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themecolor),
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No Categories Yet Created 😑😶 \n Try Creating one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
              ),
            );
          }

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                color: Colors.grey[100],
                elevation: 3,
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                child: ListTile(
                  tileColor: kwhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: Text(
                    category['name'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    category['createdAt'] != null
                        ? DateFormat('dd-MM-yyyy hh:mm a').format(
                            (category['createdAt'] as Timestamp).toDate(),
                          )
                        : 'No date',
                    style: TextStyle(fontSize: 10),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey),
                    onPressed: () =>
                        _showDeleteConfirmationDialog(context, category.id, categoryName: category['name']),
                  ),
                  onTap: () => _showAddCategoryDialog(context, category: category),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
