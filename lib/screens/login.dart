import 'package:flutter/material.dart';
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/select_stn.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordObscureText = true;
  bool _rememberMe = false;

  final String apiUrl = base_url + '/login'; // Define your API endpoint

  @override
  void initState() {
    super.initState();
    // Check if the user is already logged in here
    checkIfUserIsLoggedIn();
  }

  Future<void> checkIfUserIsLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      final String username = prefs.getString('username') ?? '';
      final String password = prefs.getString('password') ?? '';

      setState(() {
        _rememberMe = true;
        _usernameController.text = username;
        _passwordController.text = password;
      });
    }

    if (isLoggedIn) {
      final String zone = prefs.getString('zone') ?? '';
      final String division = prefs.getString('division') ?? '';
      final String section = prefs.getString('section') ?? '';
      final String role = prefs.getString('role') ?? '';
      final String id = prefs.getString('id') ?? '';

      // User is logged in, navigate to SelectStn screen with user data
      navigateToSelectStn(zone, division, section, role, id);
    }
  }

  void navigateToSelectStn(String zone, String division, String section, String role, String id) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SelectStn(
          zone: zone,
          division: division,
          section: section,
          role: role,
          id: id,
        ),
      ),
    );
  }

 Future<void> _login() async {
  final username = _usernameController.text;
  final password = _passwordController.text;

  if (username.isEmpty || password.isEmpty) {
    _showErrorSnackBar('Please enter both username and password.');
    return;
  }

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'password': password}),
  );

  print('Response status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final String role = responseData['role'].toString();
    final String id = responseData['id'].toString();

    if (responseData.containsKey('section')) {
      final String zone = responseData['zone'].toString();
      final String division = responseData['division'].toString();
      final String section = responseData['section'].toString();

      // Call navigateToSelectStn with the required arguments
      navigateToSelectStn(zone, division, section, role, id);

      // Save "Remember Me" data if the checkbox is checked
      if (_rememberMe) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);
        prefs.setString('password', password);
        prefs.setBool('rememberMe', true);
      } else {
        // Clear stored username and password
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('username');
        prefs.remove('password');
        prefs.setBool('rememberMe', false);
        // Clear input fields
        _usernameController.text = '';
        _passwordController.text = '';
      }
    } else {
      _showErrorSnackBar('Invalid username or password.');
    }
  } else {
    _showErrorSnackBar('An error occurred. Please try again later.');
  }
}


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.03,
            vertical: screenSize.height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/azadi.jpeg',
                      width: screenSize.width * 0.2,
                      height: screenSize.width * 0.2,
                    ),
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/images/loginLogo.jpeg',
                      width: screenSize.width * 0.2,
                      height: screenSize.width * 0.2,
                    ),
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/images/g20.jpeg',
                      width: screenSize.width * 0.2,
                      height: screenSize.width * 0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.02),
              Text(
                'Station Amenities Admin',
                style: TextStyle(
                  fontSize: screenSize.width * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'South Central Railway',
                style: TextStyle(
                  fontSize: screenSize.width * 0.06,
                   fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.02),

              // Username input field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),

              // Password input field
              TextFormField(
                controller: _passwordController,
                obscureText: _passwordObscureText, // Toggle visibility with this flag
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _passwordObscureText = !_passwordObscureText; // Toggle the password visibility
                      });
                    },
                    child: Icon(
                      _passwordObscureText
                          ? Icons.visibility_off
                          : Icons.visibility, // Toggle the icon based on visibility
                      color: Colors.grey, // Adjust the color as needed
                    ),
                  ),
                ),
              ),

              // Remember Me checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text('Remember Me'),
                controlAffinity: ListTileControlAffinity.leading,
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),

              ElevatedButton(
                onPressed: _login,
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: screenSize.width * 0.05),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
