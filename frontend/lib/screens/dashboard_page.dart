import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ac_status_list/screens/login_screen.dart';

class DashboardPage extends StatefulWidget {
  final String userId;
  final String bid;
  final String? ssid; // default ssid (optional)
  final List<String> ssidList; // multiple ssids

  const DashboardPage({
    super.key,
    required this.userId,
    required this.bid,
    this.ssid,
    required this.ssidList
  });
  
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // List<dynamic>? equipmentList;
  Map<String, List<dynamic>> equipmentDataBySsid = {}; // ssid → data
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDeviceData();
  }

  Future<void> fetchDeviceData() async {
    final uri = Uri.parse('http://localhost:8001/item');

    final body = {
      'user': widget.userId,
      'bid': widget.bid,
      'ssid': widget.ssid,
      'ssidList': widget.ssidList
    };

    // ตรวจสอบว่าต้องการดึงข้อมูลสำหรับ SSID เดียวหรือหลาย SSID
    if (widget.ssidList.length == 1) {
      body['ssid'] = widget.ssidList.first;
    } else if (widget.ssidList.isNotEmpty) {
      body['ssidList'] = widget.ssidList;
    } else if (widget.ssid != null) {
      // กรณีที่ ssidList ว่าง แต่มี ssid เดี่ยว (อาจเป็นค่า default หรือมาจาก UI)
      body['ssid'] = widget.ssid;
    }

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body)
      );

      print("🔄 Body request: $body");
      print("🔄 Response status: ${response.statusCode}");
      print("🔄 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['items'] != null) {
          for (var item in jsonResponse['items']) {
            final ssid = item['ssid'];
            final rawData = item['data'];
            final parsedList = rawData is String ? json.decode(rawData) : rawData;
            equipmentDataBySsid[ssid] = parsedList;
          }
        } else if (jsonResponse['data'] != null) {
          final rawData = jsonResponse['data'];
          final parsedList = rawData is String ? json.decode(rawData) : rawData;
          equipmentDataBySsid[widget.ssid!] = parsedList;
        }

        setState(() => isLoading = false);
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = '❌ Item(s) not found';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = '❌ Failed to load device data';
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() {
        errorMessage = '❌ Exception while loading data';
        isLoading = false;
      });
    }
  }

  Widget buildEquipmentCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Equipment ID: ${item['equipmentId'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...item.entries.where((e) => e.key != 'equipmentId').map(
              (entry) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Expanded(child: Text(entry.value.toString())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : equipmentDataBySsid.isEmpty
                  ? const Center(child: Text("❌ No data found"))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: equipmentDataBySsid.entries.map((entry) {
                        final ssid = entry.key;
                        final dataList = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Device: $ssid",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...dataList.map<Widget>((item) =>
                                buildEquipmentCard(Map<String, dynamic>.from(item))),
                            const Divider(thickness: 1.5, height: 32),
                          ],
                        );
                      }).toList(),
                    ),
    );
  }

}



  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text("Dashboard - $userId")),
  //     body: Column(
  //       children: [
  //         const SizedBox(height: 10),
  //         Text("🏢 BID: $bid"),
  //         const SizedBox(height: 10),
  //         Text("📡 Selected Devices:"),
  //         for (var ssid in ssidList) Text("• $ssid"),
  //       ],
  //     ),
  //   );
  // }
// }
