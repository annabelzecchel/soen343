import 'dart:typed_data';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:soen343/controllers/profile_controller.dart';
import 'package:soen343/components/auth_service.dart';

class EventCreationForm extends StatefulWidget {
  const EventCreationForm({super.key});

  @override
  _EventCreationFormState createState() => _EventCreationFormState();
}

class _EventCreationFormState extends State<EventCreationForm> {
  final _formKey = GlobalKey<FormState>(); // Form key to validate
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formatController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _youtubeController = TextEditingController();
  final ProfileController _profileController = ProfileController(AuthService());
  final _discountController = TextEditingController();

  FilePickerResult? _filePickerResult;
  Uint8List? _imageBytes;
  String? _fileName;
  String? imageURL;
  String? _email;

  @override
  void initState() {
    super.initState();
    _setUserEmail();
  }

  Future<void> _setUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String email = await _profileController.getEmailById(user.uid);
      setState(() {
        _email = email;
      });
    } 
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDateTime = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));

    if (pickedDateTime != null) {
      final TimeOfDay? pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute);
        setState(() {
          _dateTimeController.text = selectedDateTime.toString();
        });
      }
    }
  }

  void _openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _imageBytes = result.files.first.bytes;
          _fileName = result.files.first.name;
        });
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<String?> _uploadFile() async {
    try {
      print("in upload file function");
      if (_imageBytes != null && _fileName != null) {
        print("inside if");
        
        // Create storage reference
        final ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('images')
            .child(_fileName!);
        
        // Set metadata
        final metadata = firebase_storage.SettableMetadata(
          contentType: 'image/jpeg', // Make sure this matches your actual file type
        );
        
        // Start upload with error handling
        print("Starting upload...");
        final uploadTask = ref.putData(_imageBytes!, metadata);
        
        // Listen for state changes
        uploadTask.snapshotEvents.listen((snapshot) {
          print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
        }, onError: (e) {
          print('Upload error: $e');
        });
        
        // Wait for upload to complete
        final taskSnapshot = await uploadTask.whenComplete(() {});
        print("Upload task completed");
        
        if (taskSnapshot.state == firebase_storage.TaskState.success) {
          imageURL = await taskSnapshot.ref.getDownloadURL();
          print("File uploaded successfully. URL: $imageURL");
          return imageURL;
        } else {
          print("Upload failed with state: ${taskSnapshot.state}");
          return null;
        }
      } else {
        print("No file selected for upload.");
        return null;
      }
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Register New Event',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _openFilePicker(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: _imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _imageBytes!,
                                fit: BoxFit.fill,
                              ),
                            )
                          : const Column(
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 30),
                                Text("Event Banner Image", 
                                  style: TextStyle(color: Colors.black, fontSize: 20)),
                              ]
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.event_available_rounded),
                      hintText: 'Enter Event Name',
                      labelText: 'Event Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter event name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.description_rounded),
                      hintText: 'Enter Event Description',
                      labelText: 'Description',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter event description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                    value: _typeController.text.isEmpty ? null : _typeController.text,
                    onChanged: (String? newValue) {
                      setState(() {
                        _typeController.text = newValue ?? '';
                      });
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.category_rounded),
                      hintText: 'Select Event Type',
                      labelText: 'Type',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'conference',
                        child: Text('Conference'),
                      ),
                      DropdownMenuItem(
                        value: 'workshop',
                        child: Text('Workshop'),
                      ),
                      DropdownMenuItem(
                        value: 'seminar',
                        child: Text('Seminar'),
                      ),
                      DropdownMenuItem(
                        value: 'webinar',
                        child: Text('Webinar'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter event type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                    value: _formatController.text.isEmpty
                        ? null
                        : _formatController.text,
                    onChanged: (String? newValue) {
                      setState(() {
                        _formatController.text = newValue ?? '';
                      });
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.view_agenda_rounded),
                      hintText: 'Select Event Format',
                      labelText: 'Format',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'in-person',
                        child: Text('In person'),
                      ),
                      DropdownMenuItem(
                        value: 'online',
                        child: Text('Online'),
                      ),
                      DropdownMenuItem(
                        value: 'hybrid',
                        child: Text('Hybrid'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter event format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _dateTimeController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.date_range_rounded),
                      hintText: 'Select Date and Time',
                      labelText: 'Date & Time',
                    ),
                    onTap: () => _selectDateTime(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter event description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.location_on_rounded),
                      hintText: 'Enter Event Location',
                      labelText: 'Location',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter event location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _instagramController,
                    decoration: const InputDecoration(
                      icon: Icon(FontAwesomeIcons.instagram),
                      hintText: 'Link your event Instagram',
                      labelText: 'Instagram',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _facebookController,
                    decoration: const InputDecoration(
                      icon: Icon(FontAwesomeIcons.facebook),
                      hintText: 'Link your event Facebook',
                      labelText: 'Facebook',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _youtubeController,
                    decoration: const InputDecoration(
                      icon: Icon(FontAwesomeIcons.youtube),
                      hintText: 'Link your event Youtube',
                      labelText: 'Youtube',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.attach_money_rounded),
                      hintText: 'Enter Event Ticket Price',
                      labelText: 'Ticket Price (enter value in CAD)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ticket price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _discountController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.attach_money_sharp),
                      hintText: 'Enter Event Ticket Discount',
                      labelText: 'Ticket Discount Value (enter value in CAD)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ticket discount value';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        try {
                          // Reference to Firestore collection
                          CollectionReference colRef =
                              FirebaseFirestore.instance.collection("events");
                          
                          imageURL = "https://media.istockphoto.com/id/867944542/photo/blurred-background-vintage-filter-customer-in-coffee-shop-blur-background-with-bokeh.jpg?s=612x612&w=0&k=20&c=c-dctM2vjmV8TfBFd__m_bvAmtdlLlQvOA0WccOSRWw=";
                          // imageURL = await _uploadFile();
                          print(imageURL);
        
                          if (imageURL == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to upload image')),
                            );
                            return;
                          }
        
                          // Add event with creator details
                          await colRef.add({
                            "name": _nameController.text,
                            "description": _descriptionController.text,
                            "type": _typeController.text,
                            "format": _formatController.text,
                            "dateTime": _dateTimeController.text,
                            "location": _locationController.text,
                            "price": _priceController.text,
                            "createdByEmail": _email,
                            "image": imageURL,
                            "discount": _discountController.text,
                            "instagram":_instagramController.text??'none',
                            "facebook":_facebookController.text??'none',
                            "youtube":_youtubeController.text??'none',
                          });
        
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Event stored successfully')),
                          );

                          // Clear the form fields
                          _formKey.currentState?.reset();

                          setState(() {
                            _nameController.clear();
                            _typeController.clear();
                            _descriptionController.clear();
                            _formatController.clear();
                            _dateTimeController.clear();
                            _locationController.clear();
                            _priceController.clear();
                            _discountController.clear();
                            _imageBytes = null;
                            _fileName = null;
                            imageURL = null;  
                            _instagramController.clear();
                            _facebookController.clear();
                            _youtubeController.clear();  
                          });

                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving event: $e')),
                          );
                          print('Error saving event: $e');
                        }
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}