import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const UberDemoApp());

const navy = Color(0xFF0F2A5C);
const gold = Color(0xFFC9A24B);

String euro(double v) => '${v.toStringAsFixed(2).replaceAll('.', ',')} €';

class UberDemoApp extends StatelessWidget {
  const UberDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Démo Course',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
      ),
      home: const HomeScreen(),
    );
  }
}

enum RideStatus { idle, searching, driverComing, onTrip, done }

class RideOption {
  final String name;
  final int minutes;
  final double price;
  final IconData icon;
  const RideOption(this.name, this.minutes, this.price, this.icon);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const options = [
    RideOption('Économique', 5, 12.50, Icons.directions_car),
    RideOption('Confort', 4, 16.90, Icons.local_taxi),
    RideOption('Van', 8, 24.00, Icons.airport_shuttle),
  ];

  int selected = 0;
  RideStatus status = RideStatus.idle;
  Timer? timer;

  void requestRide() {
    timer?.cancel();
    setState(() => status = RideStatus.searching);
    const steps = [RideStatus.driverComing, RideStatus.onTrip, RideStatus.done];
    var i = 0;
    timer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (i >= steps.length) {
        t.cancel();
        return;
      }
      setState(() => status = steps[i]);
      i++;
    });
  }

  void reset() {
    timer?.cancel();
    setState(() => status = RideStatus.idle);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: MapPainter())),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: Colors.white,
                  elevation: 3,
                  shape: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.menu, color: navy),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(blurRadius: 16, color: Colors.black26)],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: status == RideStatus.idle ? idlePanel() : statusPanel(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget handle() => Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget placeRow(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.black54, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget optionTile(int i) {
    final o = options[i];
    final sel = i == selected;
    return GestureDetector(
      onTap: () => setState(() => selected = i),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFEEF3FB) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel ? navy : const Color(0xFFE0E4EA),
            width: sel ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(o.icon, color: navy),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${o.minutes} min',
                      style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            Text(euro(o.price),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget bigButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: navy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onPressed,
        child: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget idlePanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        handle(),
        placeRow(Icons.my_location, navy, 'Point de départ', 'Ma position'),
        placeRow(Icons.place, Colors.redAccent, 'Destination', 'Centre-ville'),
        const Divider(height: 24),
        for (var i = 0; i < options.length; i++) optionTile(i),
        const SizedBox(height: 4),
        bigButton('Demander une course', requestRide),
      ],
    );
  }

  Widget statusPanel() {
    final title = switch (status) {
      RideStatus.searching => 'Recherche d’un chauffeur…',
      RideStatus.driverComing => 'Karim arrive dans 3 min',
      RideStatus.onTrip => 'En route vers votre destination',
      _ => 'Course terminée',
    };
    final showDriver =
        status == RideStatus.driverComing || status == RideStatus.onTrip;
    final done = status == RideStatus.done;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        handle(),
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (status == RideStatus.searching) const LinearProgressIndicator(),
        if (showDriver)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: navy,
              child: Text('K', style: TextStyle(color: Colors.white)),
            ),
            title: const Text('Karim · 4,9 ★',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Toyota Corolla · AB-123-CD'),
            trailing: const Icon(Icons.phone, color: navy),
          ),
        if (done)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: gold),
                const SizedBox(width: 8),
                Text('Total : ${euro(options[selected].price)}',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        const SizedBox(height: 12),
        bigButton(done ? 'Nouvelle course' : 'Annuler', reset),
      ],
    );
  }
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFE9EEF3));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * .62, s.height * .05, s.width * .3, s.height * .12),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFFD3E8D0),
    );

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < 5; i++) {
      canvas.drawLine(Offset(s.width * i / 5, 0), Offset(s.width * i / 5, s.height), road);
    }
    for (var i = 1; i < 6; i++) {
      canvas.drawLine(Offset(0, s.height * i / 6), Offset(s.width, s.height * i / 6), road);
    }

    final route = Path()
      ..moveTo(s.width * .2, s.height * .5)
      ..lineTo(s.width * .2, s.height * 2 / 6)
      ..lineTo(s.width * .6, s.height * 2 / 6)
      ..lineTo(s.width * .6, s.height * 1 / 6);
    canvas.drawPath(
      route,
      Paint()
        ..color = const Color(0xFF2F6FED)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(Offset(s.width * .2, s.height * .5), 9, Paint()..color = navy);
    canvas.drawCircle(Offset(s.width * .2, s.height * .5), 4, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(s.width * .6, s.height * 1 / 6), 9, Paint()..color = Colors.redAccent);
    canvas.drawCircle(Offset(s.width * .6, s.height * 1 / 6), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
