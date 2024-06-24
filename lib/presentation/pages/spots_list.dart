import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_spot/data/dto/spot_of_collection.dart';
import 'package:to_spot/domain/entity/collection.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/local_repository_impl.dart';
import '../../data/location_service.dart';
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
  late final LocationService _locationController;

  File ? _selectedImage;

  Future<void> _getInitialLocation() async {
    var hasPermission = await _locationController.checkPermission();
    if (!hasPermission) {
      hasPermission = await _locationController.requestPermission();
    }

    // in case of failure will be returned geolocation of Kazan city
    final position = await _locationController.getCurrentLocation();
    setState(() {
      _coordinatesController.text = '${position.lat}, ${position.long}';
    });

  }

  Future _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }

  Future _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if(returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }

  @override void initState() {
    _locationController = Provider.of<LocationService>(context,listen: false);
    _nameController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _coordinatesController = TextEditingController(text: 'getting current location...');
    _getInitialLocation();
    super.initState();
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    MaterialButton(
                        color: Colors.blue,
                        child: const Text(
                            "Pick Image from Gallery",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            )
                        ),
                        onPressed: () {
                          _pickImageFromGallery();
                        }
                    ),
                    MaterialButton(
                        color: Colors.red,
                        child: const Text(
                            "Pick Image from Camera",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            )
                        ),
                        onPressed: () {
                          _pickImageFromCamera();
                        }
                    ),
                    const SizedBox(height: 20,),
                    _selectedImage != null ? Image.file(_selectedImage!) : const Text("Please selected an image"),
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
                    const SizedBox(height: 20,),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final name = _nameController.text;
                          final coordinates = _coordinatesController.text;
                          if (_selectedImage != null){
                            final imageBytes = _selectedImage!.readAsBytesSync();
                            Provider.of<LocalDBRepository>(context,listen: false).addSpot(
                              Spot(id: null, name: name, coordinates: coordinates, image: imageBytes),
                            );
                          }

                          else {
                            Provider.of<LocalDBRepository>(context,listen: false).addSpot(
                              Spot(id: null, name: name, coordinates: coordinates),
                            );
                          }

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
  late final TextEditingController _collectionController;

  late final List<SpotOfCollectionId> spotsOfCollections;
  Collection? selectedCollection;

  String textInfo = "Please select a collection";
  File ? _selectedImage;

  Future _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }

  Future _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if(returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }

  Future<void> _initImageFile(Uint8List uint8list) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/image.png');
    await Future.wait([file.create()]);
    file.writeAsBytesSync(uint8list);

    setState(() {
      _selectedImage = file;
    });
  }

  @override void initState() {
    _nameController = TextEditingController(text: widget.spot.name);
    _formKey = GlobalKey<FormState>();
    _coordinatesController = TextEditingController(text: widget.spot.coordinates);
    _collectionController = TextEditingController();
    spotsOfCollections = Provider.of<LocalDBRepository>(context, listen: false).spotsOfCollections;

    if (widget.spot.image != null){
      _initImageFile(widget.spot.image!);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Spot Page'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      MaterialButton(
                          color: Colors.blue,
                          child: const Text(
                              "Pick Image from Gallery",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              )
                          ),
                          onPressed: () {
                            _pickImageFromGallery();
                          }
                      ),
                      MaterialButton(
                          color: Colors.red,
                          child: const Text(
                              "Pick Image from Camera",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              )
                          ),
                          onPressed: () {
                            _pickImageFromCamera();
                          }
                      ),
                      const SizedBox(height: 20,),
                      _selectedImage != null ? Image.file(_selectedImage!) : const Text("select an image"),
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
                              Spot(id: widget.spot.id, name: name, coordinates: coordinates, image: _selectedImage!.readAsBytesSync()),
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

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Consumer<LocalDBRepository>(
                      builder: (context, dbContext, child) =>
                          DropdownMenu<Collection>(
                            controller: _collectionController,
                            enableFilter: true,
                            requestFocusOnTap: true,
                            leadingIcon: const Icon(Icons.search),
                            label: const Text('Collection'),
                            width: 223,
                            inputDecorationTheme: const InputDecorationTheme(
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                            ),

                            dropdownMenuEntries:
                            dbContext.collections.map<DropdownMenuEntry<Collection>>((Collection collection)
                            {
                              //spotsOfCollections.firstWhere((sc) => sc.collectionId == collection.id!  && sc.spotId == widget.spot.id!) != null
                              if ( spotsOfCollections.indexWhere((element) => element.collectionId == collection.id! && element.spotId == widget.spot.id!) != -1) {
                                return DropdownMenuEntry<Collection>(
                                  value: collection,
                                  label: collection.name,
                                  leadingIcon: const Icon(Icons.favorite, color: Colors.red,),
                                );
                              }

                              else {
                                return DropdownMenuEntry<Collection>(
                                  value: collection,
                                  label: collection.name,
                                  leadingIcon: const Icon(Icons.favorite_border),
                                );
                              }
                            }).toList(),

                            onSelected: (Collection? collection) {
                              var elementIndex = spotsOfCollections.indexWhere((element) => element.collectionId == collection?.id! && element.spotId == widget.spot.id!);
                              if (collection != null
                                  && elementIndex == -1)
                              {
                                setState(() {
                                  selectedCollection = collection;
                                  textInfo = '"${widget.spot.name}" added to "${selectedCollection?.name}" collection';
                                  spotsOfCollections.add(SpotOfCollectionId(collectionId: collection.id!, spotId: widget.spot.id!));
                                });

                                Provider.of<LocalDBRepository>(context, listen: false)
                                    .addSpotToCollection(collection, widget.spot);
                              }

                              else if (collection != null)
                              {
                                setState(() {
                                  selectedCollection = collection;
                                  textInfo = '"${widget.spot.name}" removed from "${selectedCollection?.name}" collection';
                                  spotsOfCollections.removeAt(elementIndex);
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
        ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _coordinatesController.dispose();
    _collectionController.dispose();
    super.dispose();
  }
}