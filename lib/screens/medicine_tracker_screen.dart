// lib/medicine_tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

// MARK: - App Theme
const Color primaryColor = Colors.blue;

// MARK: - Supabase Client
final supabase = SupabaseClient(
  "https://mlzhsefjtzoncvstgnxr.supabase.co",
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1semhzZWZqdHpvbmN2c3RnbnhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyMDA3OTIsImV4cCI6MjA3Mzc3Njc5Mn0.vUTQTx7K56Hnwiy1iGGlUPwCZv2D8KttIIHOfgj09PU",
);

// MARK: - Search Result Enum
enum SearchStatus { available, outOfStock, notFound, error }

class MedicineSearchResult {
  final SearchStatus status;
  final Medicine? requestedMedicine;
  final List<Medicine>? alternatives;
  final String? message;

  MedicineSearchResult({
    required this.status,
    this.requestedMedicine,
    this.alternatives,
    this.message,
  });
}

// MARK: - Medicine Tracker Screen
class MedicineTrackerScreen extends StatefulWidget {
  const MedicineTrackerScreen({Key? key}) : super(key: key);

  @override
  _MedicineTrackerScreenState createState() => _MedicineTrackerScreenState();
}

class _MedicineTrackerScreenState extends State<MedicineTrackerScreen> {
  String searchText = "";
  List<Medicine> medicines = [];
  bool showingMap = false;
  Location location = Location();
  LocationData? userLocation;
  MedicineSearchResult? searchResult;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    fetchMedicines();
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus permission = await location.requestPermission();
    if (permission == PermissionStatus.granted) {
      userLocation = await location.getLocation();
      setState(() {});
    }
  }

  Future<void> fetchMedicines() async {
    try {
      final response = await supabase.from('medicines').select();
      final data = response as List<dynamic>;

      setState(() {
        medicines = data
            .map((item) => Medicine.fromJson(item as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print("Error fetching medicines: $e");
    }
  }

  Future<void> findMedicine(String name) async {
    setState(() {
      isLoading = true;
      searchResult = null;
    });

    try {
      final response = await supabase
          .from('medicines')
          .select()
          .ilike('name', '%$name%');

      final data = response as List<dynamic>;

      if (data.isEmpty) {
        // Suggest alternatives based on input name
        final alternatives = await getSimilarMedicines(
          Medicine(
            id: "dummy",
            name: name,
            description: name,
            price: null,
            quantity: 0,
            createdAt: null,
          ),
        );
        setState(() {
          searchResult = MedicineSearchResult(
            status: SearchStatus.notFound,
            alternatives: alternatives,
            message:
            "Medicine '$name' not found. Here are some alternatives:",
          );
        });
      } else {
        final med = Medicine.fromJson(data.first);
        if (med.availability) {
          setState(() {
            searchResult = MedicineSearchResult(
              status: SearchStatus.available,
              requestedMedicine: med,
              message: "Medicine is available",
            );
          });
        } else {
          final alternatives = await getSimilarMedicines(med);
          setState(() {
            searchResult = MedicineSearchResult(
              status: SearchStatus.outOfStock,
              requestedMedicine: med,
              alternatives: alternatives,
              message: "Medicine is out of stock. Alternatives:",
            );
          });
        }
      }
    } catch (e) {
      setState(() {
        searchResult = MedicineSearchResult(
          status: SearchStatus.error,
          message: "Error fetching medicine: $e",
        );
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ✅ Proper alternative finder
  Future<List<Medicine>> getSimilarMedicines(Medicine baseMedicine) async {
    try {
      final response =
      await supabase.from('medicines').select().gt('quantity', 0);

      final allMeds = (response as List<dynamic>)
          .map((json) => Medicine.fromJson(json))
          .toList();

      final baseText =
      "${baseMedicine.name} ${baseMedicine.description ?? ""}".toLowerCase();

      final scored = allMeds.map((m) {
        final text = "${m.name} ${m.description ?? ""}".toLowerCase();
        final score = calculateSimilarity(baseText, text);
        return {'medicine': m, 'score': score};
      }).where((item) => item['score'] as double > 0.1).toList();

      scored.sort((a, b) =>
          (b['score'] as double).compareTo(a['score'] as double));

      return scored.take(5).map((e) => e['medicine'] as Medicine).toList();
    } catch (e) {
      return [];
    }
  }

  double calculateSimilarity(String text1, String text2) {
    if (text1.isEmpty || text2.isEmpty) return 0.0;

    final stopWords = {
      "and", "or", "the", "a", "an", "in", "on", "at", "to",
      "for", "of", "with", "mg", "tablet", "capsule"
    };

    final words1 = text1
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !stopWords.contains(w))
        .toSet();
    final words2 = text2
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !stopWords.contains(w))
        .toSet();

    if (words1.isEmpty || words2.isEmpty) return 0.0;

    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;

    return union > 0 ? intersection / union : 0.0;
  }

  List<Medicine> get filteredMedicines {
    final filtered = searchText.isEmpty
        ? medicines
        : medicines
        .where((m) =>
        m.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    filtered.sort((a, b) =>
        (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Medicine Tracker",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // Make transparent to show bg
        elevation: 0, // Remove shadow
        iconTheme: const IconThemeData(color: Colors.white), // White back button
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                        hintText: "Search medicines...", border: InputBorder.none),
                    onSubmitted: (val) {
                      if (val.isNotEmpty) findMedicine(val);
                    },
                    onChanged: (val) {
                      setState(() {
                        searchText = val;
                      });
                    },
                  ),
                ),
                if (searchText.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        searchText = "";
                        searchResult = null;
                      });
                    },
                    child: const Text("Clear",
                        style: TextStyle(color: primaryColor)),
                  )
              ],
            ),
          ),

          if (isLoading) const LinearProgressIndicator(),

          if (searchResult != null)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (searchResult!.requestedMedicine != null)
                      MedicineCard(medicine: searchResult!.requestedMedicine!),

                    if (searchResult!.alternatives != null &&
                        searchResult!.alternatives!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text("Alternative Medicines",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      for (var med in searchResult!.alternatives!)
                        MedicineCard(medicine: med),
                    ],

                    if (searchResult!.message != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(searchResult!.message!,
                            style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: showingMap
                  ? PharmacyMapView(
                  medicines: filteredMedicines, userLocation: userLocation)
                  : ListView.builder(
                itemCount: filteredMedicines.length,
                itemBuilder: (context, index) {
                  return MedicineCard(medicine: filteredMedicines[index]);
                },
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    showingMap = false;
                  });
                },
                icon: Icon(Icons.list,
                    color: showingMap ? Colors.grey : primaryColor),
                label: Text("List",
                    style: TextStyle(
                        color: showingMap ? Colors.grey : primaryColor)),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    showingMap = true;
                  });
                },
                icon: Icon(Icons.map,
                    color: showingMap ? primaryColor : Colors.grey),
                label: Text("Map",
                    style: TextStyle(
                        color: showingMap ? primaryColor : Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// MARK: - Medicine Model
class Medicine {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final int? quantity;
  final String? createdAt;

  // Extra fields for UI
  String get dosage => description ?? "No details";
  bool get availability => (quantity ?? 0) > 0;
  String get pharmacyName => "Default Pharmacy";
  String get pharmacyAddress => "Unknown Address";
  double? get distance => 1.0; // placeholder
  double get latitude => 28.6139;
  double get longitude => 77.2090;

  LatLng get coordinates => LatLng(latitude, longitude);

  Medicine({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.quantity,
    this.createdAt,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'].toString(),
      name: json['name'] ?? "Unknown",
      description: json['description'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity'].toString()),
      createdAt: json['created_at'],
    );
  }
}

// MARK: - Medicine Card Widget
class MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineCard({Key? key, required this.medicine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(medicine.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(medicine.dosage,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text("₹${medicine.price?.toStringAsFixed(2) ?? "0.00"}",
                    style: const TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Row(children: [
                  Icon(Icons.circle,
                      size: 10,
                      color: medicine.availability ? Colors.green : Colors.red),
                  const SizedBox(width: 4),
                  Text(
                      medicine.availability ? "Available" : "Out of Stock",
                      style: TextStyle(
                          color: medicine.availability
                              ? Colors.green
                              : Colors.red,
                          fontSize: 12)),
                ]),
              ])
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.store, color: primaryColor),
            const SizedBox(width: 5),
            Text(medicine.pharmacyName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
          Row(children: [
            const Icon(Icons.location_on, color: Colors.grey),
            const SizedBox(width: 5),
            Expanded(
              child: Text(medicine.pharmacyAddress,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ]),
          Row(children: [
            const Icon(Icons.directions_car, color: Colors.grey),
            const SizedBox(width: 5),
            Text("${medicine.distance?.toStringAsFixed(1)} km away",
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ]),
      ),
    );
  }
}

// MARK: - Map View
class PharmacyMapView extends StatefulWidget {
  final List<Medicine> medicines;
  final LocationData? userLocation;

  const PharmacyMapView({Key? key, required this.medicines, this.userLocation})
      : super(key: key);

  @override
  _PharmacyMapViewState createState() => _PharmacyMapViewState();
}

class _PharmacyMapViewState extends State<PharmacyMapView> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    LatLng startPosition = widget.userLocation != null
        ? LatLng(widget.userLocation!.latitude!,
        widget.userLocation!.longitude!)
        : const LatLng(28.6139, 77.2090);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: startPosition, zoom: 14),
      markers: widget.medicines
          .map((m) => Marker(
        markerId: MarkerId(m.id),
        position: m.coordinates,
        infoWindow: InfoWindow(title: m.pharmacyName),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed),
      ))
          .toSet(),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}