import 'dart:convert';
import 'package:http/http.dart' as http;

class AccountService {
  static Future<bool> addDevice({
    required String userId,
    required String buildingName,
    required String bid,
    required List<String> ssidList,
  }) async {
    final response = await http.post(
      Uri.parse('http://localhost:8001/add-device'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user': userId,
        'building_name': buildingName,
        'bid': bid,
        'ssidList': ssidList,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> checkSsidOwner({
  required String userId,
  required String buildingName,
  required String ssid,
  }) async {
      final uri = Uri.parse(
      'http://localhost:8001/check-ssid-owner'
      '?user=${Uri.encodeComponent(userId)}'
      '&ssid=${Uri.encodeComponent(ssid)}'
      '&building_name=${Uri.encodeComponent(buildingName)}',
      // '?user=admin@example.com'
      // '&ssid=AC-Unit-03'
      // '&building_name=Building B',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['message'].toString().startsWith('✅')) {
        return result;
      }
    }
    return null;
  }

}
