import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  // COMPLIANCE: Nominatim requires a unique User-Agent with contact info.
  // We also add an email parameter to the URL for extra transparency.
  static const String _contactEmail = 'sakshamproject@googlegroups.com'; // Use a project-specific tag
  
  static const Map<String, String> _headers = {
    'User-Agent': 'TravelPlanner_Saksham_Educational_Project_v1.2 (contact:$_contactEmail)',
    'Accept': 'application/json',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  // Reverse geocoding: Coordinates -> Address
  static Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      final url = '$_baseUrl/reverse?format=jsonv2&lat=$lat&lon=$lon&accept-language=en&email=$_contactEmail';
      print('Nominatim Request (Full): $url');
      final response = await http.get(Uri.parse(url), headers: _headers);

      print('Nominatim Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      } else {
        print('Nominatim Error: ${response.body}');
      }
    } catch (e) {
      print('Reverse Geocoding Error: $e');
    }
    return null;
  }

  // Geocoding: Address -> Coordinates
  static Future<LatLng?> geocode(String address) async {
    try {
      final url = '$_baseUrl/search?format=jsonv2&q=${Uri.encodeComponent(address)}&limit=1&email=$_contactEmail';
      print('Nominatim Search Request (Full): $url');
      final response = await http.get(Uri.parse(url), headers: _headers);

      print('Nominatim Search Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        } else {
          print('Nominatim Search Result: Empty');
        }
      } else {
        print('Nominatim Search Error: ${response.body}');
      }
    } catch (e) {
      print('Geocoding Error: $e');
    }
    return null;
  }
}
