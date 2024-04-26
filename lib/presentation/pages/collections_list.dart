import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/local_repository_impl.dart';
import '../../domain/entity/collection.dart';

class CollectionsListPage extends StatelessWidget{
  const CollectionsListPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Collections'),
      ),
      body: Consumer<LocalDBRepository>(
        builder: (context, dbContext, child) => ListView.builder(
          itemCount: dbContext.collections.length,
          itemBuilder: (context, index) {
            final collection = dbContext.collections[index];
            return ListTile(
              title: Text(collection.name),
              subtitle: Text(collection.description),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => dbContext.removeCollection(collection),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditCollectionPage(collection: collection)),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CollectionPage()),
        ),
        tooltip: 'Add Collection',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Page to create a new collection
class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {

  late final TextEditingController _nameController;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _descriptionController;

  @override void initState() {
    super.initState();
    _nameController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _descriptionController = TextEditingController();
  }

  @override void dispose() {
    super.dispose();
    _nameController.dispose();
    _formKey.currentState?.dispose();
    _descriptionController.dispose();
  }

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

/// Page to edit existent Collection
class EditCollectionPage extends StatefulWidget {
  final Collection collection;

  const EditCollectionPage({super.key, required this.collection});

  @override
  State<EditCollectionPage> createState() => _EditCollectionPageState();

}

class _EditCollectionPageState extends State<EditCollectionPage>{
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override void initState() {
    _nameController = TextEditingController(text: widget.collection.name);
    _formKey = GlobalKey<FormState>();
    _descriptionController = TextEditingController(text: widget.collection.description);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Collection Page'),
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
                      return 'Please enter a Collection name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final name = _nameController.text;
                      final description = _descriptionController.text;
                      Provider.of<LocalDBRepository>(context,listen: false).updateCollectionInfo(
                        Collection(id: widget.collection.id, name: name, description: description),
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}