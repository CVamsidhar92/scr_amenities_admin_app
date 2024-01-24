import 'package:flutter/material.dart';
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/home.dart';
import 'package:scr_amenities_admin/screens/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateAmenity extends StatefulWidget {
  final String id;
  final String role;
  final String zone;
  final String division;
  final String section;
  final String station;

  // Constructor for CreateAmenity widget
  const CreateAmenity({
    Key? key,
    required this.id,
    required this.role,
    required this.zone,
    required this.division,
    required this.section,
    required this.station,
  }) : super(key: key);

  @override
  State<CreateAmenity> createState() => _CreateAmenityState();
}

class _CreateAmenityState extends State<CreateAmenity> {
  // Global key to identify the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Controllers for handling text input
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _divisionController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _locationDetailsController =
      TextEditingController();
  final TextEditingController _stallNameController = TextEditingController();
  final TextEditingController _roomTarrifController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  String? selectedService; // To track the selected radio value
  final List<String> radioTitles = [
    'Free',
    'Paid'
  ]; // Titles for the radio buttons

  // Lists for dropdown menu options
  List<String> managedByOptions = ['By Railway', 'Contractor', 'Cell Kitchen'];

  // Variables to track selected values and visibility of fields
  String? _zoneName;
  String? _divisionName;
  String? _sectionName;
  String? _stationName;
  String? _amenityType;
  String? _stallName;
  String? _roomTarrif;
  String? _natureStall;
  String? _roomType;
  String? _managedBy;
  String? _locationName;
  String? _locationDetails;
  bool showStallAndNatureFields = false;
  bool showRoomTypeAndRoomTarrifFields = false;
  XFile? _pickedImage;
  Image? _image;

  // Lists for dropdown menu options
  List<Map<String, String>> amenityType = [
    {'amenity_name': '-Select-'}
  ];
  List<Map<String, String>> natureStall = [
    {'nature_name': '-Select-'}
  ];
  List<Map<String, String>> roomType = [
    {'room_type': '-Select-'}
  ];
  String? selectedAmenityType;
  String? selectedNatureStall;
  String? selectedRoomType;

  // Location instance for handling location data
  final Location location = Location();

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with widget data
    _zoneController.text = widget.zone;
    _divisionController.text = widget.division;
    _sectionController.text = widget.section;
    _stationController.text = widget.station;

    // Fetch amenity, nature stall, and room type data
    getAmenity();
    getNatureStall();
    getRoomType();

    // Check and request location permission
    _checkLocationPermission();
  }

  // Function to handle image Picking from the Camera
  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();

    try {
      final pickedImage = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Set the image quality (0 to 100)
      );

      final File imageFile;
      if (pickedImage != null) {
        imageFile = File(pickedImage.path);

        setState(() {
          _pickedImage = XFile(
            imageFile.path,
            bytes: File(imageFile.path).readAsBytesSync(),
          );
        });
      } else {
        print('User canceled the camera capture');
      }
    } catch (e) {
      print('Error picking image from camera: $e');
    }
  }

  // Function to handle image picking from the gallery

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _pickedImage = pickedImage;
    });
  }

  // Function to show the image picker dialog
  Future<void> _showImagePickerDialog() async {
    XFile? pickedImage = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          contentPadding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
                child: Text('Take a Picture'),
              ),
              SizedBox(height: 8), // Adjust the height between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
                child: Text('Choose from Gallery'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to fetch amenity data
  Future<void> getAmenity() async {
    final String url = base_url + '/getamenity';

    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      final fetchedData = jsonDecode(res.body);
      if (fetchedData is List) {
        setState(() {
          // Add "--" to the beginning of the amenityType list
          amenityType = [
                {'amenity_name': ''}
              ] +
              List<Map<String, String>>.from(fetchedData.map((item) {
                return {
                  'amenity_name': item['amenity_name'] as String,
                };
              }));
          selectedAmenityType = "--";
        });
      }
    } else {
      // Handle the error case
      print('Failed to fetch data');
    }
  }

  // Function to fetch nature stall data
  Future<void> getNatureStall() async {
    final String url = base_url + '/getnaturestall';

    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      final fetchedData = jsonDecode(res.body);
      if (fetchedData is List) {
        setState(() {
          // Add "--" to the beginning of the natureStall list
          natureStall = [
                {'nature_name': ''}
              ] +
              List<Map<String, String>>.from(fetchedData.map((item) {
                return {
                  'nature_name': item['nature_name'] as String,
                };
              }));
          selectedNatureStall = "";
        });
      }
    } else {
      // Handle the error case
      print('Failed to fetch data');
    }
  }

  // Function to fetch room type data
  Future<void> getRoomType() async {
    final String url = base_url + '/getrrroom';

    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      final fetchedData = jsonDecode(res.body);
      if (fetchedData is List) {
        setState(() {
          // Add "--" to the beginning of the natureStall list
          roomType = [
                {'room_type': ''}
              ] +
              List<Map<String, String>>.from(fetchedData.map((item) {
                return {
                  'room_type': item['room_type'] as String,
                };
              }));
          selectedRoomType = "";
        });
      }
    } else {
      // Handle the error case
      print('Failed to fetch data');
    }
  }

  // Function to check location permission
  Future<void> _checkLocationPermission() async {
    final hasPermission = await location.requestPermission();
    if (hasPermission == PermissionStatus.granted) {
      // Handle permission granted
    }
  }

  // Function to get current location
  void _getCurrentLocation() async {
    try {
      final LocationData? locationData = await location.getLocation();

      if (locationData != null) {
        setState(() {
          _latitudeController.text = locationData.latitude.toString();
          _longitudeController.text = locationData.longitude.toString();
        });
      } else {
        print('Location data is null. Check the location configuration.');
      }
    } catch (e) {
      print('Error getting location: $e');
      // Handle the error here, for example, by showing a snackbar or dialog.
    }
  }

  // Function to send data to the backend
  Future<void> sendDataToBackend(String imagePath) async {
    final String url = base_url + '/postfeedamenities';
    final request = http.MultipartRequest('POST', Uri.parse(url));

    // Prepare the data to send to the backend
    Map<String, dynamic> data = {
      'zone': _zoneName,
      'division': _divisionName,
      'section': _sectionName,
      'station_name': _stationName,
      'amenity_type': _amenityType,
      'service_type': selectedService,
      'managed_by': _managedBy,
      'stall_name': _stallNameController.text,
      'nature_stall': selectedNatureStall,
      'room_type': selectedRoomType,
      'tarrif': _roomTarrifController.text,
      'location_name': _locationNameController.text,
      'location_details': _locationDetailsController.text,
      'latitude': _latitudeController.text,
      'longitude': _longitudeController.text,
      'created_by': widget.id
    };

    // Add the image file to the request
    if (imagePath.isNotEmpty) {
      try {
        var file = await http.MultipartFile.fromPath(
          'image/',
          imagePath,
        );
        request.files.add(file);
      } catch (e) {
        print('Error adding image file to request: $e');
        return;
      }
    }

    // Add other form data to the request
    for (var entry in data.entries) {
      request.fields[entry.key] = entry.value.toString();
    }

    try {
      // Send the request
      var response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        // Data sent successfully, show a success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data inserted successfully.'),
            duration: Duration(seconds: 3),
          ),
        );
        // Navigate to the Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(
                id: widget.id,
                role: widget.role,
                zone: widget.zone,
                division: widget.division,
                section: widget.section,
                selectedStation: widget.station),
          ),
        );
      } else {
        // Handle the error case
        print('Failed to send data to the backend');
        // You can show an error message to the user or perform error handling as needed
      }
    } catch (e) {
      showSnackbar('Error updating location: $e');
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

// Function to show the full image
  void _showFullImage(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Amenity',
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Login(),
              ));
            },
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.logout_outlined,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  readOnly: true,
                  controller: _zoneController,
                  decoration: InputDecoration(
                    labelText: 'Zone Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Zone Name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _zoneName = value;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  readOnly: true,
                  controller: _divisionController,
                  decoration: InputDecoration(
                    labelText: 'Division Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Division Name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _divisionName = value;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  readOnly: true,
                  controller: _sectionController,
                  decoration: InputDecoration(
                    labelText: 'Section Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Section Name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _sectionName = value;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  readOnly: true,
                  controller: _stationController,
                  decoration: InputDecoration(
                    labelText: 'Station Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Station Name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _stationName = value;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                DropdownButtonFormField<String>(
                  items: amenityType.map((amenity) {
                    return DropdownMenuItem<String>(
                      value: amenity['amenity_name'],
                      child: Text(amenity['amenity_name']!),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Amenity Type',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value == '-Select-') {
                      return 'Please select Amenity Type';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _amenityType = value;
                      // Update the visibility of fields based on the selected value
                      showStallAndNatureFields = (value == 'Catering');
                      showRoomTypeAndRoomTarrifFields =
                          (value == 'Waiting Hall' || value == 'Retiring Room');
                    });
                  },
                  value:
                      _amenityType, // Track the selected value in _amenityType
                ),
                Visibility(
                  visible: showStallAndNatureFields,
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _stallNameController,
                        decoration: InputDecoration(
                          labelText: 'Stall Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Stall Name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _stallName = value;
                        },
                      ),
                      SizedBox(
                        height: screenSize.height * 0.02,
                      ),
                      DropdownButtonFormField<String>(
                        items: natureStall.map((nature) {
                          return DropdownMenuItem<String>(
                            value: nature['nature_name'],
                            child: Text(nature['nature_name']!),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Nature of Stall',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value == '-Select-') {
                            return 'Please select Nature of Stall';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedNatureStall =
                                value; // Assign the selected value to selectedNatureStall
                          });
                        },
                        value:
                            selectedNatureStall, // Track the selected value in selectedNatureStall
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                Visibility(
                  visible: showRoomTypeAndRoomTarrifFields,
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        items: roomType.map((roomtype) {
                          return DropdownMenuItem<String>(
                            value: roomtype['room_type'],
                            child: Text(roomtype['room_type']!),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Room Type',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value == '-Select-') {
                            return 'Please select Room Type';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedRoomType =
                                value; // Assign the selected value to selectedNatureStall
                          });
                        },
                        value:
                            selectedRoomType, // Track the selected value in selectedNatureStall
                      ),
                      SizedBox(
                        height: screenSize.height * 0.02,
                      ),
                      TextFormField(
                        controller: _roomTarrifController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Room Tarrif',
                          hintText: 'eg:-25',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Room Tarrif';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _roomTarrif = value;
                        },
                      ),
                      SizedBox(
                        height: screenSize.height * 0.02,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedService =
                              radioTitles[0]; // Select the first option
                        });
                      },
                      child: Text(
                        'Service Type:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                ),
                Row(
                  children: radioTitles.map((title) {
                    return Row(
                      children: [
                        Radio<String>(
                          value: title,
                          groupValue: selectedService,
                          onChanged: (value) {
                            setState(() {
                              selectedService = value;
                            });
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedService = title;
                            });
                          },
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  items: managedByOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Managed By',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value == '-Select-') {
                      return 'Please select Managed By';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _managedBy = value;
                    });
                  },
                  value: _managedBy, // Track the selected value in _managedBy
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _locationNameController,
                  decoration: InputDecoration(
                    labelText: 'Location Name',
                    hintText: 'eg:- Platforms,Portico,Cellar',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Location Name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _locationName = value;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _locationDetailsController,
                  decoration: InputDecoration(
                    labelText: 'Location Details',
                    hintText: 'eg:- Near by Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Location Details';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _locationName = value;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _showImagePickerDialog,
                      child: Text('Select Image Source'),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    if (_pickedImage != null)
                      TextButton(
                        onPressed: () {
                          _showFullImage(_pickedImage!.path);
                        },
                        child: Text(
                          'View Image',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue[900]),
                        ),
                      )
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  controller: _latitudeController,
                  decoration: InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Latitude';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _locationName = value;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  controller: _longitudeController,
                  decoration: InputDecoration(
                    labelText: 'Longitude',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Longitude';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _locationDetails = value;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    _getCurrentLocation(); // Call _getCurrentLocation when the button is pressed
                  },
                  child: Text('Get Location'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedService?.isNotEmpty == true) {
                        // If selectedService is not null and not empty, proceed with form submission.
                        _formKey.currentState!.save();
                        sendDataToBackend(_pickedImage?.path ?? '');
                      } else {
                        // Display an error message for the radio buttons.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select a Service Type'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
