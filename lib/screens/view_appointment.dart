import 'package:flutter/material.dart';
import 'package:gm_appointments/screens/history_appointments.dart';
import 'package:gm_appointments/screens/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gm_appointments/screens/base_url.dart';
import 'dart:async';

class ViewAppointments extends StatefulWidget {
  final int userRole;

  const ViewAppointments({Key? key, required this.userRole}) : super(key: key);

  @override
  _ViewAppointmentsState createState() => _ViewAppointmentsState();
}

class _ViewAppointmentsState extends State<ViewAppointments> {
  List<Appointment> appointments = [];
  DateTime? selectedDate;
  bool isLoading = false;
  List<String> dropdownOptions = [
    "-Status-",
    "Completed",
    "Cancelled",
    "Rescheduled"
  ];
  bool showRescheduledInput = false;
  bool showCompletedInput = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    fetchData();

    // Set up a timer to refresh the data every 5 seconds, but only for GM (userRole == 0)
    if (widget.userRole == 0) {
      _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
        fetchData();
      });
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    final apiUrl = base_url + 'getappointments';

    try {
      setState(() {
        isLoading = true;
      });

      final String formattedDate =
          DateFormat('yyyy-MM-dd').format(selectedDate!);

      final Map<String, dynamic> requestBody = {
        'date': formattedDate,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          appointments = jsonData
              .map((data) => Appointment.fromJson(data, widget.userRole))
              .toList();
        });
      } else {
        print('API error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildCompletedDateTimeInput(Appointment appointment) {
    return Visibility(
      visible: appointment.showCompletedDateTimeInput,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Completed Date and Time',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(
              text: DateFormat('dd-MM-yyyy HH:mm:ss')
                  .format(appointment.dataField3),
            ),
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: appointment.dataField3,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(appointment.dataField3),
                );

                if (pickedTime != null) {
                  setState(() {
                    appointment.dataField3 = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRescheduledDateTimeInput(Appointment appointment) {
    return Visibility(
      visible: appointment.showRescheduledDateTimeInput,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Rescheduled Date and Time',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(
              text: appointment.rescheduledDateTime != null
                  ? DateFormat('dd-MM-yyyy HH:mm:ss')
                      .format(appointment.rescheduledDateTime!)
                  : '',
            ),
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: appointment.rescheduledDateTime ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                    appointment.rescheduledDateTime ?? DateTime.now(),
                  ),
                );

                if (pickedTime != null) {
                  setState(() {
                    appointment.rescheduledDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
      fetchData();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }



  Future<void> _closeAppointment(int index) async {
    final appointment = appointments[index];
    final apiUrl = base_url + 'closeappointment';

    try {
      final Map<String, dynamic> requestBody = {
        'id': appointment.id.toString(),
        'status': 'closed',
        'closed_by': 'GM',
        'closed_datetime': DateTime.now().toLocal().toString(),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          appointment.closedDateTime = DateTime.now();
          appointments[index] = appointment;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment Closed Successfully'),
          ),
        );

        await fetchData();
      } else {
        print('API error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _submit(int index) async {
    final appointment = appointments[index];

    if (appointment.selectedOption == "-Status-") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a status.'),
        ),
      );
      return;
    }

    // Update the database with status and closedBy as Secry. GM
    final apiUrl = base_url + 'updateappointment';

    try {
      final String formattedClosedDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final Map<String, dynamic> requestBody = {
        'id': appointment.id.toString(),
        'status': appointment.selectedOption,
        'closed_by': 'Secry.GM',
        'closed_datetime': formattedClosedDateTime, // Convert to desired format
      };

      if (showRescheduledInput) {
        final rescheduledDateTime = DateTime
            .now(); // Replace this with your rescheduled date and time logic
        final formattedRescheduledDateTime = DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(rescheduledDateTime); // Convert to desired format
        requestBody['rescheduled_datetime'] = formattedRescheduledDateTime;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Show a SnackBar for successful update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment Updated Successfully'),
          ),
        );

        // Refresh the data
        await fetchData();
      } else {
        print('API error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Appointments'),
        actions: [
         IconButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryAppointments(),
      ),
    );
  },
  icon: Icon(Icons.history),
),
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchData();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected Date: ${DateFormat('dd-MM-yyyy').format(selectedDate!)}',
                    style: TextStyle(fontSize: 18),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _selectDate(context);
                    },
                    child: Text('Select Date'),
                  ),
                ],
              ),
            ),
            appointments.isEmpty && !isLoading
                ? Center(
                    child: Text(
                      'No data found.',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: ListView.builder(
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = appointments[index];
                            final formattedDate = DateFormat('dd-MM-yyyy')
                                .format(appointment.dataField3);
                            final formattedTime = DateFormat('HH:mm:ss')
                                .format(appointment.dataField3);

                            return Card(
                              child: ListTile(
                                title: Text(
                                  appointment.dataField1,
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appointment.dataField2,
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      'Date: $formattedDate',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Time: $formattedTime',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (widget.userRole != 0)
                                            DropdownButton<String>(
                                              value: appointment.selectedOption,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  appointment.selectedOption =
                                                      newValue!;
                                                  showCompletedInput =
                                                      newValue == 'Completed';
                                                  showRescheduledInput =
                                                      newValue == 'Rescheduled';

                                                  // Toggle the visibility of Completed Date and Time input field
                                                  appointment
                                                          .showCompletedDateTimeInput =
                                                      newValue == 'Completed';

                                                  // Toggle the visibility of Rescheduled Date and Time input field
                                                  appointment
                                                          .showRescheduledDateTimeInput =
                                                      newValue == 'Rescheduled';
                                                });
                                              },
                                              items: dropdownOptions
                                                  .map((String status) {
                                                return DropdownMenuItem<String>(
                                                  value: status,
                                                  child: Text(status),
                                                );
                                              }).toList(),
                                            ),
                                          _buildCompletedDateTimeInput(
                                              appointment),
                                          _buildRescheduledDateTimeInput(
                                              appointment),
                                          if (widget.userRole == 0)
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _closeAppointment(index),
                                                child: Text('Close'),
                                              ),
                                            ),
                                          if (appointment.selectedOption !=
                                              "-Status-")
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: ElevatedButton(
                                                onPressed: () => _submit(index),
                                                child: Text('Submit'),
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.green,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                                  textStyle:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class Appointment {
  final int id;
  final String dataField1;
  final String dataField2;
  DateTime dataField3;
  String selectedOption;
  DateTime? closedDateTime;
  DateTime? rescheduledDateTime;
  String closedBy;
  bool showCompletedDateTimeInput = false;
  bool showRescheduledDateTimeInput = false;

  Appointment({
    required this.id,
    required this.dataField1,
    required this.dataField2,
    required this.dataField3,
    required this.selectedOption,
    required this.closedBy,
    this.closedDateTime,
    this.rescheduledDateTime,
  });

  factory Appointment.fromJson(Map<String, dynamic> json, int userRole) {
    String closedBy = userRole == 0 ? 'GM' : 'Secry. GM';

    return Appointment(
      id: json['id'],
      dataField1: json['officer_name'],
      dataField2: json['purpose'],
      dataField3: DateTime.parse(json['date_time']),
      selectedOption: "-Status-",
      closedBy: closedBy,
      closedDateTime: json['closed_datetime'] != null
          ? DateTime.parse(json['closed_datetime'])
          : null,
      rescheduledDateTime: json['rescheduled_datetime'] != null
          ? DateTime.parse(json['rescheduled_datetime'])
          : null,
    );
  }
}
