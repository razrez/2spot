import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_spot/domain/entity/collection.dart';

import '../../data/local_repository_impl.dart';
import '../../domain/entity/spot.dart';
import 'collections_list.dart';

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
              onTap: () => Navigator.push(
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

/// Page to create a new spot
class SpotPage extends StatefulWidget {
  const SpotPage({super.key});

  @override
  State<SpotPage> createState() => _SpotPageState();
}

class _SpotPageState extends State<SpotPage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _coordinatesController;

  final List<String> _selectedLocations = [];
  final List<String> _locations = ['Location 1', "Location 2", 'Location 3', 'Location 4'];

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
      body: Column(
        children: [
          Form(
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
        ],
      ),
    );
  }
}

/// Page to edit existent spot
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

  late final List<Collection> spotCollections;
  late final List<Collection> notSpotCollections;
  Collection? selectedCollection;
  String textInfo = "Please select a collection";

  late final TextEditingController collectionController;

  @override void initState() {
    _nameController = TextEditingController(text: widget.spot.name);
    _formKey = GlobalKey<FormState>();
    _coordinatesController = TextEditingController(text: widget.spot.coordinates);
    collectionController = TextEditingController();

    spotCollections = Provider
        .of<LocalDBRepository>(context, listen: false)
        .collections
        .where((collection) => collection.spots.contains(widget.spot))
        .toList();

    notSpotCollections  = Provider
        .of<LocalDBRepository>(context, listen: false)
        .collections
        .where((collection) => !collection.spots.contains(widget.spot))
        .toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Spot Page'),
        ),
        body: Column(
          children: [
            Form(
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
            // ListView.builder(
            //   itemCount: spotCollections.length,
            //   itemBuilder: (context, index) {
            //     final collection = spotCollections[index];
            //     return ListTile(
            //       title: Text(collection.name),
            //       subtitle: Text(collection.description),
            //       trailing: IconButton(
            //         icon: const Icon(Icons.delete),
            //         onPressed: () {
            //           setState(() {
            //             spotCollections.remove(collection);
            //             notSpotCollections.add(collection);
            //           });
            //           Provider.of<LocalDBRepository>(context, listen: false)
            //               .removeSpotFromCollection(collection, widget.spot);
            //         },
            //         alignment: Alignment.center,
            //       ),
            //       onTap: () => Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => EditCollectionPage(collection: collection)),
            //       ),
            //     );
            //   },
            // ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Consumer<LocalDBRepository>(
                    builder: (context, dbContext, child) =>
                      DropdownMenu<Collection>(
                        controller: collectionController,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        leadingIcon: const Icon(Icons.search),
                        label: const Text('Collection'),
                        inputDecorationTheme: const InputDecorationTheme(
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                        ),

                        dropdownMenuEntries:
                          dbContext.collections.map<DropdownMenuEntry<Collection>>(
                                (Collection collection) {
                              if (collection.spots.contains(widget.spot)) {
                                return DropdownMenuEntry<Collection>(
                                  value: collection,
                                  label: collection.name,
                                  leadingIcon: const Icon(Icons.favorite),
                                );
                              }
                              else {
                                return DropdownMenuEntry<Collection>(
                                  value: collection,
                                  label: collection.name,
                                  leadingIcon: const Icon(Icons.favorite_border),
                                );
                              }
                            },
                          ).toList(),

                        onSelected: (Collection? collection) {
                          if (collection != null && !collection.spots.contains(widget.spot)){
                            setState(() {
                              selectedCollection = collection;
                              textInfo = '"${widget.spot.name}" added to "${selectedCollection?.name}" collection';
                            });

                            Provider.of<LocalDBRepository>(context, listen: false)
                                .addSpotToCollection(collection, widget.spot);
                          }

                          else if (collection != null && collection.spots.contains(widget.spot)) {
                            setState(() {
                              selectedCollection = collection;
                              textInfo = '"${widget.spot.name}" removed from "${selectedCollection?.name}" collection';
                            });

                            Provider.of<LocalDBRepository>(context, listen: false)
                                .removeSpotFromCollection(collection, widget.spot);
                          }

                        },
                      ),
                  ),
                ],
              ),
            ),
            if (selectedCollection != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(textInfo),
                  const Icon(Icons.info_outline, color: Colors.yellow,)
                ],
              )
            else
              Text(textInfo)
          ],
        ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _coordinatesController.dispose();
    collectionController.dispose();
    super.dispose();
  }
}



