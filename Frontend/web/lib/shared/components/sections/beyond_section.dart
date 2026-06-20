import 'package:flutter/material.dart';
import '../../../util/theme/app_colors.dart';

class BeyondSection extends StatelessWidget {
  const BeyondSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F7F8), // Matches the light blue/teal background in your image
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Top Kits for Ages 4-7", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text("View All Kits →", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 10),
              const Align(alignment: Alignment.centerLeft, child: Text("Matching the three core mindsets of childhood development.", style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 40),

              // The 3-Card Grid
              LayoutBuilder(builder: (context, constraints) {
                return constraints.maxWidth >= 768 ? _buildGrid(3) : _buildGrid(1);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(int crossAxisCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 0.8, // Adjust for card height
      children: [
        _KitCard(title: "Artistic Mindset", subtitle: "Creative", desc: "Focus on color theory, structural design, and visual storytelling.", color: AppColors.cartTeal, img: "assets/images/img1.jpg"),
        _KitCard(title: "Analytic Mindset", subtitle: "Scientific", desc: "Observational science, biological patterns, and data collection.", color: AppColors.teal, img: "assets/images/img2.jpg"),
        _KitCard(title: "Logic Mindset", subtitle: "Critical Thinking", desc: "Mechanical engineering, puzzle-solving, and algorithmic thinking.", color: Colors.black, img: "assets/images/img3.jpg"),
      ],
    );
  }
}

class _KitCard extends StatelessWidget {
  final String title, subtitle, desc, img;
  final Color color;
  const _KitCard({required this.title, required this.subtitle, required this.desc, required this.color, required this.img});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.asset(img, height: 200, width: double.infinity, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(subtitle, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 5),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 20),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 45)), onPressed: () {}, child: const Text("Explore Kit")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}