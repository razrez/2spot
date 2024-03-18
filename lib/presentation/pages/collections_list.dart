import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/local_repository_impl.dart';
import '../../domain/entity/collection.dart';

class CollectionsListPage extends StatelessWidget{
  const CollectionsListPage({super.key});

  @override
  Widget build(BuildContext context) {

    // data load
    //Provider.of<Collections>(context, listen: false).loadData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Spots'),
      ),
      body: Consumer<LocalDBRepository>(
        builder: (context, dbContext, child) => ListView.builder(
          itemCount: dbContext.collections.length,
          itemBuilder: (context, index) {
            final collection = dbContext.collections[index];
            return Column(
              children: [
                ListTile(
                  title: Text(collection.name),
                  subtitle: Text(collection.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => dbContext.removeCollection(collection),
                  ),
                ),
                Column(
                  children: collection.spots.map((spot) {
                    return ListTile(
                      title: Text(spot.name),
                      subtitle: Text(spot.coordinates),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CollectionPage()),
        ),
        tooltip: 'Add Spot',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Collection'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Collection Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a collection name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text;
                    final description = _descriptionController.text;
                    Provider.of<LocalDBRepository>(context,listen: false).addCollection(
                      Collection(id: null, name: name, description: description),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}