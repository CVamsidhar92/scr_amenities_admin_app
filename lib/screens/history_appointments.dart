import 'package:flutter/material.dart';
import 'package:gm_appointments/screens/base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HistoryAppointments extends StatefulWidget {
  @override
  State<HistoryAppointments> createState() => _HistoryAppointmentsState();
}

class _HistoryAppointmentsState extends State<HistoryAppointments> {
  List<Map<String, dynamic>> historyAppointments = []; // Store history appointments

  @override
  void initState() {
    super.initState();
    _loadHistoryAppointments(); // Load history appointments when the widget initializes
  }

  Future<void> _loadHistoryAppointments() async {
    final apiUrl = base_url + 'historyappointments';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        // Add headers or request body if required
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final List<dynamic> untypedAppointments = json.decode(responseBody);

        // Convert the untyped list to a list of maps
        final List<Map<String, dynamic>> typedAppointments =
            untypedAppointments.cast<Map<String, dynamic>>();

        // Sort the appointments by 'date_time' field in ascending order
        typedAppointments.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['date_time']);
          final DateTime dateB = DateTime.parse(b['date_time']);
          return dateA.compareTo(dateB);
        });

        setState(() {
          historyAppointments = typedAppointments;
        });
      } else {
        print('Failed to fetch history appointments. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // Function to handle displaying custom text for null values
  String displayValue(dynamic value) {
    return value == null ? 'N/A' : value.toString();
  }

  // Function to create a custom table heading
  Widget customTableHeading(String text) {
    return Container(
      width: 120, // Adjust the width as needed
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments History'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Enable horizontal scrolling
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Your content here
              DataTable(
                sortColumnIndex: 0, // Index of the 'Date Time' column
                sortAscending: true, // Set to true for ascending order, false for descending
                columns: <DataColumn>[
                  DataColumn(
                    label: customTableHeading("Date & Time"),
                    numeric: true, // Set numeric to true to adjust column width
                  ),
                  DataColumn(
                    label: customTableHeading('Officer Name'),
                    numeric: true, // Set numeric to true to adjust column width
                  ),
                  DataColumn(
                    label: customTableHeading('Purpose'),
                    numeric: true, // Set numeric to true to adjust column width
                  ),
                  DataColumn(
                    label: customTableHeading('Closed Date Time'),
                    numeric: true, // Set numeric to true to adjust column width
                  ),
                  DataColumn(
                    label: customTableHeading('Rescheduled Date Time'),
                    numeric: true, // Set numeric to true to adjust column width
                  ),
                  DataColumn(
                    label: customTableHeading('Status'),
                    numeric: true, // Set numeric to true to adjust column width
                  ),
                  DataColumn(
                    label: customTableHeading('Closed By'),
                    numeric: true, // Set numeric to true to adjust column width
                  ),
                ],
                rows: historyAppointments.map((appointment) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Center(
                          child: Text(
                            DateFormat('dd-MM-yyyy HH:mm:ss')
                                .format(DateTime.parse(appointment['date_time'])),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(displayValue(appointment['officer_name'])),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(displayValue(appointment['purpose'])),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(displayValue(appointment['closed_datetime'])),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(displayValue(appointment['rescheduled_datetime'])),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(displayValue(appointment['status'])),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(displayValue(appointment['closed_by'])),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
