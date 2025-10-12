import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  // Example data (replace with real data or state management)
  final String appointments = "12";
  final String tests = "5";
  final String prescriptions = "8";
  final String email = "john.doe@example.com";
  final String phone = "+1 (555) 123-4567";
  final String memberSince = "March 2024";

  static const Color appNavy = Color.fromRGBO(20, 33, 61, 1);
  static const Color appLight = Colors.white;

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make transparent to show bg
        elevation: 0, // Remove shadow
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black), // Black back button
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Semi-transparent navy gradient card with avatar and stats
            Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appNavy.withOpacity(0.8),
                    const Color(0x800000FF).withOpacity(0.6)
                  ], // Semi-transparent gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    top: 40,
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      child: const Icon(
                        Icons.person,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatView(title: "Appointments", value: appointments),
                          _StatView(title: "Test Results", value: tests),
                          _StatView(title: "Prescriptions", value: prescriptions),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 24,
                    right: 24,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement edit profile action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.18),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  _InfoSection(
                    title: "Personal Information",
                    items: [
                      _InfoItemData(
                        icon: Icons.email,
                        iconColor: Colors.blue,
                        title: "Email",
                        value: email,
                      ),
                      _InfoItemData(
                        icon: Icons.phone,
                        iconColor: Colors.green,
                        title: "Phone",
                        value: phone,
                      ),
                      _InfoItemData(
                        icon: Icons.calendar_today,
                        iconColor: Colors.orange,
                        title: "Member Since",
                        value: memberSince,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _InfoSection(
                    title: "Health Information",
                    items: [
                      _InfoItemData(
                        icon: Icons.favorite,
                        iconColor: Colors.red,
                        title: "Medical History",
                        value: "View Details",
                      ),
                      _InfoItemData(
                        icon: Icons.medication,
                        iconColor: Colors.purple,
                        title: "Current Medications",
                        value: "3 Active",
                      ),
                      _InfoItemData(
                        icon: Icons.description,
                        iconColor: Colors.indigo,
                        title: "Recent Tests",
                        value: "5 Results",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _StatView extends StatelessWidget {
  final String title;
  final String value;

  const _StatView({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoItemData> items;

  const _InfoSection({Key? key, required this.title, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9), // Semi-transparent white
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Padding(
                  padding: const EdgeInsets.only(left: 62),
                  child: const Divider(height: 1),
                );
              }
              final item = items[index ~/ 2];
              return _InfoItem(item: item);
            }),
          ),
        ),
      ],
    );
  }
}

class _InfoItemData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  _InfoItemData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });
}

class _InfoItem extends StatelessWidget {
  final _InfoItemData item;

  const _InfoItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Handle tap if needed
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.iconColor.withOpacity(0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: item.iconColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.value,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}