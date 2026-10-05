import 'package:flutter/material.dart';
import 'package:ac_status_list/screens/dashboard_page.dart';
import 'package:ac_status_list/services/account_service.dart';
import 'package:ac_status_list/constants/building_mapping.dart';
import 'package:ac_status_list/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;
  final String password;
  final List<String> buildings;

  const SettingsScreen({
    super.key,
    required this.userId,
    required this.buildings,
    required this.password,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int currentStep = 1;
  String? selectedBuilding;
  String? selectedDevice;

  List<String> selectedDevices = [];

  final List<String> deviceOptions = [
    "AC-Unit-01",
    "AC-Unit-02",
    "AC-Unit-03",
    "AC-Unit-04"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.buildings.isNotEmpty) {
      selectedBuilding = widget.buildings[0];
    }
    selectedDevice = deviceOptions[0];
  }

  void _goToDeviceStep() {
    setState(() {
      currentStep = 2;
    });
  }

  void _finalSubmit() async {
    if (selectedBuilding == null || selectedDevices.isEmpty) return;

    final selectedBid = buildingMapping[selectedBuilding];
    // final ssidtest = selectedDevices;
    // List<String> conflictDevices = [];

    // // 🔍 เช็กว่า ssid ไหนถูกใช้ใน building อื่นอยู่แล้ว
    // for (final ssid in selectedDevices) {
    //   final checkRes = await AccountService.checkSsidOwner(
    //     userId: widget.userId,
    //     buildingName: selectedBuilding!,
    //     ssid: ssid
    //   );

    //   if (checkRes != null && checkRes['status'] == 'conflict') {
    //     conflictDevices.add('$ssid (in ${checkRes['building_name']})');
    //   }
    // }

    // if (conflictDevices.isNotEmpty) {
    //   showDialog(
    //     context: context,
    //     builder: (_) => AlertDialog(
    //       title: const Text("❌ Conflicting Devices"),
    //       content: Text(
    //         'The following devices are already assigned to other buildings:\n\n${conflictDevices.join('\n')}',
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(context),
    //           child: const Text("OK"),
    //         ),
    //       ],
    //     ),
    //   );
    //   return; // ✅ บล็อกไม่ให้ไปต่อ
    // }


    final success = await AccountService.addDevice(
      userId: widget.userId,
      buildingName: selectedBuilding!,
      bid: selectedBid!,
      ssidList: selectedDevices,
    );
    
    if (success) {
      // ถ้าทุก device บันทึกสำเร็จ ไปหน้า Dashboard พร้อมส่งรายชื่อ device
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            userId: widget.userId,
            bid: selectedBid!,
            ssidList: selectedDevices,
            ssid: selectedDevices.length == 1 ? selectedDevices.first : null,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to update device list')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userId} Setup'),
        leading: currentStep == 2
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => currentStep = 1),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Center(
        child: currentStep == 1 ? _buildStep1() : _buildStep2(),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.house),
        const Text("Select your building:", style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        ...widget.buildings.map((building) {
          return Container(
            width: 250,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: selectedBuilding == building
                    ? Colors.blueGrey
                    : Colors.white,
                foregroundColor: selectedBuilding == building
                    ? Colors.white
                    : Colors.black,
                side: BorderSide(color: Colors.blueGrey.shade200, width: 2),
              ),
              onPressed: () {
                setState(() {
                  selectedBuilding = building;
                });
              },
              child: Text(building, style: const TextStyle(fontSize: 16)),
            ),
          );
        }).toList(),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _goToDeviceStep,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: const Text("Next"),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Select your devices:", style: TextStyle(fontSize: 18)),
        ...deviceOptions.map((device) {
          final isSelected = selectedDevices.contains(device);
          return CheckboxListTile(
            title: Text(device),
            value: isSelected,
            onChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  selectedDevices.add(device);
                } else {
                  selectedDevices.remove(device);
                }
              });
            },
          );
        }).toList(),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _finalSubmit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: const Text("Go to Dashboard"),
        ),
      ],
    );
  }

}
