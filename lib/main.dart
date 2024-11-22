import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

void main() => runApp(GpsApp());

class GpsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GPS App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _surnameController,
              decoration: InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: _latitudeController,
              decoration: InputDecoration(labelText: 'Latitud'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _longitudeController,
              decoration: InputDecoration(labelText: 'Longitud'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final surname = _surnameController.text;
                final latitude = double.tryParse(_latitudeController.text) ?? 0.0;
                final longitude = double.tryParse(_longitudeController.text) ?? 0.0;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      name: name,
                      surname: surname,
                      latitude: latitude,
                      longitude: longitude,
                    ),
                  ),
                );
              },
              child: Text('Ver ubicación'),
            ),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  final String name;
  final String surname;
  final double latitude;
  final double longitude;

  MapScreen({
    required this.name,
    required this.surname,
    required this.latitude,
    required this.longitude,
  });

  Future<String> _getLocationDetails(double lat, double lon) async {
    final placemarks = await placemarkFromCoordinates(lat, lon);
    final place = placemarks.first;
    return '${place.locality}, ${place.country}';
  }

  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      markerId: MarkerId('marker'),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: '$name $surname',
        snippet: 'Cargando...',
        onTap: () async {
          final locationDetails = await _getLocationDetails(latitude, longitude);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(locationDetails)),
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Mapa')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15,
        ),
        markers: {marker},
      ),
    );
  }
}
