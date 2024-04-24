import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/local_repository_impl.dart';
import '../../domain/entity/spot.dart';

class SpotsListPage extends StatelessWidget {
  const SpotsListPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Spots'),
      ),
      body: Consumer<LocalDBRepository>(
        builder: (context, dbContext, child) => ListView.builder(
          itemCount: dbContext.spots.length,
          itemBuilder: (context, index) {
            final spot = dbContext.spots[index];
            return ListTile(
              title: Text(spot.name),
              subtitle: Text(spot.coordinates),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => dbContext.removeSpot(spot),
              ),
              onLongPress: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditSpotPage(spot: spot)),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SpotPage()),
        ),
        tooltip: 'Add Spot',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditSpotPage extends StatefulWidget {
  final Spot spot;

  const EditSpotPage({super.key, required this.spot});

  @override
  State<EditSpotPage> createState() => _EditSpotPageState();

}

class _EditSpotPageState extends State<EditSpotPage>{
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _coordinatesController;
  //late final List<Collection> _spotInCollections;

  @override void initState() {
    _nameController = TextEditingController(text: widget.spot.name);
    _formKey = GlobalKey<FormState>();
    _coordinatesController = TextEditingController(text: widget.spot.coordinates);
    //_spot =  Provider.of<LocalDBRepository>(context,listen: false).spots[widget.id];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spot Page'),
      ),
      body: Consumer<LocalDBRepository>(
        builder: (context, dbContext, child) => Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Location Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _coordinatesController,
                  decoration: const InputDecoration(labelText: 'Coordinates'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter coordinates';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final name = _nameController.text;
                      final coordinates = _coordinatesController.text;
                      Provider.of<LocalDBRepository>(context,listen: false).updateSpot(
                        Spot(id: widget.spot.id, name: name, coordinates: coordinates),
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
      )
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _coordinatesController.dispose();
    super.dispose();
  }
}

class SpotPage extends StatefulWidget {
  const SpotPage({super.key});

  @override
  State<SpotPage> createState() => _SpotPageState();
}

class _SpotPageState extends State<SpotPage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _coordinatesController;

  @override void initState() {
    super.initState();
    _nameController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _coordinatesController = TextEditingController();
  }

  @override void dispose() {
    super.dispose();
    _nameController.dispose();
    _formKey.currentState?.dispose();
    _coordinatesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Spot'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Location Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _coordinatesController,
                decoration: const InputDecoration(labelText: 'Coordinates'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter coordinates';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text;
                    final coordinates = _coordinatesController.text;
                    Provider.of<LocalDBRepository>(context,listen: false).addSpot(
                      Spot(id: null, name: name, coordinates: coordinates),
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