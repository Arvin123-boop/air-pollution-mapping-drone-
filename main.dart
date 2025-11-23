// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:fl_chart/fl_chart.dart'; // for graphs

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Air Quality Monitor',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: const Color(0xFF0D1117),
//         cardColor: const Color(0xFF161B22),
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int selectedIndex = 0;
//   final DatabaseReference dbRef = FirebaseDatabase.instance.ref("sensorData");
//   Map<String, dynamic>? sensorData;

//   @override
//   void initState() {
//     super.initState();
//     dbRef.onValue.listen((event) {
//       final data = event.snapshot.value;
//       if (data != null && data is Map) {
//         setState(() {
//           sensorData = Map<String, dynamic>.from(data);
//         });
//       }
//     });
//   }

//   double calculateAirDensity(double tempC, double pressurePa) {
//     double tempK = tempC + 273.15;
//     const double R = 287.0; // J/(kg·K) for dry air
//     return pressurePa / (R * tempK);
//   }

//   double calculateAltitude(double pressurePa) {
//     const double P0 = 101325.0; // sea-level standard pressure in Pa
//     return 44330.0 * (1 - pow(pressurePa / P0, 0.1903));
//   }

//   String weatherCondition(double tempC, double pressurePa) {
//     // Simple weather estimation
//     if (pressurePa < 100000 && tempC < 10) return "Cold & Low Pressure";
//     if (pressurePa > 102000 && tempC > 20) return "Warm & High Pressure";
//     return "Normal";
//   }

//   String airQualityStatus(double ppm) {
//     if (ppm <= 50) return "Good";
//     if (ppm <= 100) return "Moderate";
//     if (ppm <= 200) return "Unhealthy for Sensitive";
//     if (ppm <= 300) return "Unhealthy";
//     return "Very Unhealthy";
//   }

//   Color airQualityColor(double ppm) {
//     if (ppm <= 50) return Colors.green;
//     if (ppm <= 100) return Colors.yellow;
//     if (ppm <= 200) return Colors.orange;
//     if (ppm <= 300) return Colors.red;
//     return Colors.purple;
//   }

//   Widget infoCard(String title, String value, {IconData? icon, Color? color}) {
//     return Card(
//       elevation: 4,
//       color: color ?? Theme.of(context).cardColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: ListTile(
//         leading: icon != null ? Icon(icon, color: Colors.lightBlueAccent) : null,
//         title: Text(title, style: const TextStyle(fontSize: 18)),
//         trailing: Text(
//           value,
//           style: const TextStyle(
//               fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Widget menu1() {
//     final data = sensorData;
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Center(
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: Image.asset(
//               'assets/images/zurag.jpg',
//               width: 250,
//               height: 180,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         if (data == null)
//           const Center(
//             child: Padding(
//               padding: EdgeInsets.all(32.0),
//               child: Column(
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 12),
//                   Text("Waiting for data...",
//                       style: TextStyle(fontSize: 18, color: Colors.grey)),
//                 ],
//               ),
//             ),
//           )
//         else
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               infoCard('Temperature',
//                   '${data['temperature']?.toStringAsFixed(2) ?? "—"} °C',
//                   icon: Icons.thermostat),
//               infoCard('Pressure',
//                   '${data['pressure']?.toStringAsFixed(2) ?? "—"} hPa',
//                   icon: Icons.speed),
//               infoCard(
//                   'MQ-135 Gas',
//                   '${(data['air_quality_mq135'] != null ? double.tryParse(data['air_quality_mq135'].toString())?.toStringAsFixed(2) : "—") ?? "—"} ppm',
//                   icon: Icons.science),
//               infoCard('Sound Level (HW-484)',
//                   '${data['sound_level']?.toStringAsFixed(2) ?? "—"}',
//                   icon: Icons.graphic_eq),
//               infoCard('LED Status', data['led_status'] == 1 ? "ON" : "OFF",
//                   icon: Icons.lightbulb_outline),
//             ],
//           ),
//       ],
//     );
//   }

//   Widget menu2() {
//     final data = sensorData;
//     if (data == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     double temp = (data['temperature'] ?? 0).toDouble();
//     double pressure = (data['pressure'] ?? 1013).toDouble() * 100; // hPa -> Pa
//     double airDensity = calculateAirDensity(temp, pressure);
//     double altitude = calculateAltitude(pressure);
//     String weather = weatherCondition(temp, pressure);

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           infoCard("Air Density", "${airDensity.toStringAsFixed(2)} kg/m³",
//               icon: Icons.device_thermostat),
//           infoCard("Altitude", "${altitude.toStringAsFixed(2)} m",
//               icon: Icons.height),
//           infoCard("Weather Condition", weather, icon: Icons.wb_sunny),
//           const SizedBox(height: 24),
//           Text("Air Density & Altitude Graphs",
//               style:
//                   const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           SizedBox(
//             height: 200,
//             child: LineChart(LineChartData(
//               gridData: FlGridData(show: true),
//               titlesData: FlTitlesData(show: true),
//               borderData: FlBorderData(show: true),
//               lineBarsData: [
//                 LineChartBarData(spots: [
//                   FlSpot(0, airDensity),
//                   FlSpot(1, airDensity),
//                   FlSpot(2, airDensity),
//                   FlSpot(3, airDensity),
//                 ], isCurved: true, color: Colors.lightBlueAccent, barWidth: 3),
//                 LineChartBarData(spots: [
//                   FlSpot(0, altitude),
//                   FlSpot(1, altitude),
//                   FlSpot(2, altitude),
//                   FlSpot(3, altitude),
//                 ], isCurved: true, color: Colors.orangeAccent, barWidth: 3),
//               ],
//             )),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget menu3() {
//     final data = sensorData;
//     if (data == null) return const Center(child: CircularProgressIndicator());

//     double ppm =
//         (data['air_quality_mq135'] ?? 0).toDouble(); // MQ-135 PPM value
//     String status = airQualityStatus(ppm);
//     Color color = airQualityColor(ppm);

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Card(
//             color: color,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 children: [
//                   const Text("Air Quality Index",
//                       style:
//                           TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 10),
//                   Text(status,
//                       style: const TextStyle(
//                           fontSize: 30, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   Text("${ppm.toStringAsFixed(2)} ppm",
//                       style: const TextStyle(fontSize: 20)),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> pages = [menu1(), menu2(), menu3()];

//     return Scaffold(
//       body: pages[selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: selectedIndex,
//         selectedItemColor: Colors.lightBlueAccent,
//         unselectedItemColor: Colors.grey,
//         backgroundColor: const Color(0xFF161B22),
//         onTap: (index) {
//           setState(() {
//             selectedIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Sensors"),
//           BottomNavigationBarItem(icon: Icon(Icons.thermostat), label: "Air Stats"),
//           BottomNavigationBarItem(icon: Icon(Icons.science), label: "Air Quality"),
//         ],
//       ),
//     );
//   }
// }
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Quality Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        cardColor: const Color(0xFF161B22),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("sensorData");
  Map<String, dynamic>? sensorData;

  // Lists to store dynamic graph data
  final List<double> airDensityList = [];
  final List<double> altitudeList = [];
  final int maxDataPoints = 20; // maximum points on graph

  @override
  void initState() {
    super.initState();
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          sensorData = Map<String, dynamic>.from(data);

          // Update graphs
          double temp = (sensorData?['temperature'] ?? 0).toDouble();
          double pressure = (sensorData?['pressure'] ?? 1013).toDouble() * 100; // hPa -> Pa
          double airDensity = calculateAirDensity(temp, pressure);
          double altitude = calculateAltitude(pressure);

          if (airDensityList.length >= maxDataPoints) airDensityList.removeAt(0);
          if (altitudeList.length >= maxDataPoints) altitudeList.removeAt(0);

          airDensityList.add(airDensity);
          altitudeList.add(altitude);
        });
      }
    });
  }

  double calculateAirDensity(double tempC, double pressurePa) {
    double tempK = tempC + 273.15;
    const double R = 287.0; // J/(kg·K) for dry air
    return pressurePa / (R * tempK);
  }

  double calculateAltitude(double pressurePa) {
    const double P0 = 101325.0; // sea-level standard pressure in Pa
    return 44330.0 * (1 - pow(pressurePa / P0, 0.1903));
  }

  String weatherCondition(double tempC, double pressurePa) {
    if (pressurePa < 100000 && tempC < 10) return "Cold & Low Pressure";
    if (pressurePa > 102000 && tempC > 20) return "Warm & High Pressure";
    return "Normal";
  }

  String airQualityStatus(double ppm) {
    if (ppm <= 50) return "Good";
    if (ppm <= 100) return "Moderate";
    if (ppm <= 200) return "Unhealthy for Sensitive";
    if (ppm <= 300) return "Unhealthy";
    return "Very Unhealthy";
  }

  Color airQualityColor(double ppm) {
    if (ppm <= 50) return Colors.green;
    if (ppm <= 100) return Colors.yellow;
    if (ppm <= 200) return Colors.orange;
    if (ppm <= 300) return Colors.red;
    return Colors.purple;
  }

  Widget infoCard(String title, String value, {IconData? icon, Color? color}) {
    return Card(
      elevation: 4,
      color: color ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Colors.lightBlueAccent) : null,
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: Text(
          value,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget menu1() {
    final data = sensorData;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/zurag.jpg',
              width: 250,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (data == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("Waiting for data...",
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              infoCard('Temperature',
                  '${data['temperature']?.toStringAsFixed(2) ?? "—"} °C',
                  icon: Icons.thermostat),
              infoCard('Pressure',
                  '${data['pressure']?.toStringAsFixed(2) ?? "—"} hPa',
                  icon: Icons.speed),
              infoCard(
                  'MQ-135 Gas',
                  '${(data['air_quality_mq135'] != null ? double.tryParse(data['air_quality_mq135'].toString())?.toStringAsFixed(2) : "—") ?? "—"} ppm',
                  icon: Icons.science),
              infoCard('Sound Level (HW-484)',
                  '${data['sound_level']?.toStringAsFixed(2) ?? "—"}',
                  icon: Icons.graphic_eq),
              infoCard('LED Status', data['led_status'] == 1 ? "ON" : "OFF",
                  icon: Icons.lightbulb_outline),
            ],
          ),
      ],
    );
  }

  Widget menu2() {
    if (sensorData == null) return const Center(child: CircularProgressIndicator());

    double temp = (sensorData?['temperature'] ?? 0).toDouble();
    double pressure = (sensorData?['pressure'] ?? 1013).toDouble() * 100; // hPa -> Pa
    String weather = weatherCondition(temp, pressure);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          infoCard("Weather Condition", weather, icon: Icons.wb_sunny),
          const SizedBox(height: 16),
          Text("Air Density & Altitude",
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(airDensityList.length,
                        (i) => FlSpot(i.toDouble(), airDensityList[i])),
                    isCurved: true,
                    color: Colors.lightBlueAccent,
                    barWidth: 3,
                  ),
                  LineChartBarData(
                    spots: List.generate(altitudeList.length,
                        (i) => FlSpot(i.toDouble(), altitudeList[i])),
                    isCurved: true,
                    color: Colors.orangeAccent,
                    barWidth: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget menu3() {
    final data = sensorData;
    if (data == null) return const Center(child: CircularProgressIndicator());

    double ppm =
        (data['air_quality_mq135'] ?? 0).toDouble();
    String status = airQualityStatus(ppm);
    Color color = airQualityColor(ppm);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text("Air Quality Index",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(status,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("${ppm.toStringAsFixed(2)} ppm",
                      style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [menu1(), menu2(), menu3()];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF161B22),
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Sensors"),
          BottomNavigationBarItem(icon: Icon(Icons.thermostat), label: "Air Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.science), label: "Air Quality"),
        ],
      ),
    );
  }
}
