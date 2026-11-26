import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_device_compass/flutter_device_compass.dart';

import 'models/waypoint.dart';
import 'widgets/compass.dart';

void main() {
  runApp(const KGpsLocatorApp());
}

class KGpsLocatorApp extends StatelessWidget {
  const KGpsLocatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'kGPS-Locator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? latitude;
  double? longitude;
  double? altitude;
  double heading = 45.0;

  String gpsStatus = 'Aguardando GPS...';
  String compassStatus = 'Aguardando bússola...';

  StreamSubscription<Position>? gpsSubscription;
  StreamSubscription<CompassEvent>? compassSubscription;

  Waypoint? navegandoPara;

  final List<Waypoint> waypoints = [
    const Waypoint(name: 'WP001', latitude: -23.164281, longitude: -45.896756),
    const Waypoint(name: 'WP002', latitude: -23.189425, longitude: -46.026272),
    const Waypoint(name: 'WP003', latitude: -23.811881, longitude: -45.396372),
  ];

  @override
  void initState() {
    super.initState();
    iniciarGPS();
    iniciarBussola();
  }

  Future<void> iniciarGPS() async {
    try {
      final servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) {
        if (!mounted) return;
        setState(() => gpsStatus = 'Ative a localização do dispositivo.');
        return;
      }

      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        if (!mounted) return;
        setState(() => gpsStatus = 'Permissão de localização não concedida.');
        return;
      }

      if (permissao == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => gpsStatus =
            'Permissão negada permanentemente. Altere nas configurações.');
        return;
      }

      await gpsSubscription?.cancel();
      gpsSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1,
        ),
      ).listen(
        (Position position) {
          if (!mounted) return;
          setState(() {
            latitude = position.latitude;
            longitude = position.longitude;
            altitude = position.altitude;
            gpsStatus = 'GPS ativo';
          });
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() => gpsStatus = 'Erro ao obter localização.');
          debugPrint('Erro GPS: $error');
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => gpsStatus = 'Falha ao iniciar GPS.');
      debugPrint('Falha GPS: $error');
    }
  }

  void iniciarBussola() {
    compassSubscription?.cancel();
    compassSubscription = FlutterCompass.events?.listen(
      (CompassEvent event) {
        if (!mounted) return;
        if (event.heading == null) {
          setState(() => compassStatus = 'Sensor de bússola indisponível.');
          return;
        }
        setState(() {
          heading = event.heading!;
          compassStatus = 'Bússola ativa';
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() => compassStatus = 'Erro no sensor de bússola.');
        debugPrint('Erro bússola: $error');
      },
    );

    if (compassSubscription == null && mounted) {
      setState(() => compassStatus = 'Sensor de bússola indisponível.');
    }
  }

  void navegarPara(Waypoint waypoint) {
    setState(() => navegandoPara = waypoint);
    debugPrint('Você acionou o Navegar para ${waypoint.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navegando para ${waypoint.name}')),
    );
  }

  void pararNavegacao() {
    if (navegandoPara != null) {
      debugPrint('Você parou o Navegar para ${navegandoPara!.name}');
    }
    setState(() => navegandoPara = null);
  }

  void adicionarWaypoint() {
    debugPrint('Você clicou no botão Add Waypoint');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ação Add Waypoint registrada (conforme Etapa 1 do roteiro).'),
      ),
    );
  }

  void excluirWaypoint(Waypoint waypoint) {
    setState(() => waypoints.remove(waypoint));
    debugPrint('Você acionou o excluir Waypoint ${waypoint.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${waypoint.name} excluído')),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _infoRow('Latitude', latitude?.toStringAsFixed(6) ?? '--'),
              _infoRow('Longitude', longitude?.toStringAsFixed(6) ?? '--'),
              _infoRow(
                'Altitude',
                altitude == null ? '--' : '${altitude!.toStringAsFixed(1)} m',
              ),
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(gpsStatus, style: const TextStyle(fontSize: 12)),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(compassStatus, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationInfo() {
    final waypoint = navegandoPara!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NAVEGANDO PARA',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(waypoint.name, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            const Text('Distância: -- m'),
          ],
        ),
      ),
    );
  }

  Widget _buildWaypointList() {
    if (waypoints.isEmpty) {
      return const Center(child: Text('Nenhum waypoint cadastrado.'));
    }

    return ListView.builder(
      itemCount: waypoints.length,
      itemBuilder: (context, index) {
        final waypoint = waypoints[index];
        return Dismissible(
          key: ValueKey(waypoint.name),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),
          onDismissed: (_) => excluirWaypoint(waypoint),
          child: ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(waypoint.name),
            subtitle: Text(
              '${waypoint.latitude.toStringAsFixed(6)}, '
              '${waypoint.longitude.toStringAsFixed(6)}',
            ),
            selected: navegandoPara?.name == waypoint.name,
            onLongPress: () => navegarPara(waypoint),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    gpsSubscription?.cancel();
    compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('kGPS-Locator')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Compass(heading: heading),
            const SizedBox(height: 8),
            Text(
              'Heading: ${heading.toStringAsFixed(1)}°',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildLocationInfo(),
            const SizedBox(height: 8),
            if (navegandoPara != null) _buildNavigationInfo(),
            Expanded(child: _buildWaypointList()),
          ],
        ),
      ),
      floatingActionButton: navegandoPara == null
          ? null
          : FloatingActionButton.extended(
              onPressed: pararNavegacao,
              icon: const Icon(Icons.stop),
              label: const Text('STOP'),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton.icon(
          onPressed: adicionarWaypoint,
          icon: const Icon(Icons.add_location_alt),
          label: const Text('Add Waypoint'),
        ),
      ),
    );
  }
}
