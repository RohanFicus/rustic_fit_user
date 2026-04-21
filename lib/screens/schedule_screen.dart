import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedCategory = "Suits";

  final List<Map<String, dynamic>> _categories = [
    {"name": "Suits", "icon": Icons.straighten_rounded},
    {"name": "Lehenga", "icon": Icons.woman_rounded},
    {"name": "Sarees", "icon": Icons.woman_rounded},
    {"name": "Fabrics", "icon": Icons.texture_rounded},
    {"name": "Simple", "icon": Icons.texture_rounded},
  ];

  final List<Map<String, dynamic>> _featuredStyles = [
    {
      "name": "ROYAL ANARKALI",
      "rating": "5.0",
      "image":
          "https://images.unsplash.com/photo-1581044777550-4cfa60707c03?w=800",
    },
    {
      "name": "BRIDAL GOLD",
      "rating": "5.0",
      "image":
          "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800",
    },
    {
      "name": "VELVET CHIC",
      "rating": "5.0",
      "image":
          "https://images.unsplash.com/photo-1623609163859-ca93c959b98a?w=800",
    },
    {
      "name": "SILK TRADITION",
      "rating": "5.0",
      "image":
          "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(colorScheme),
              const SizedBox(height: 16),
              _buildSectionHeader("Category", null),
              const SizedBox(height: 16),
              _buildCategoryList(colorScheme),
              const SizedBox(height: 16),
              _buildSectionHeader("Best Destination", Icons.menu_rounded),
              const SizedBox(height: 16),
              _buildMasonryGrid(colorScheme),
              const SizedBox(height: 100), // Space for navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    size: 22),
                const SizedBox(width: 12),
                Text(
                  "Looking for",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData? actionIcon) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildCategoryList(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat['name'];
        return Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['name']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  cat['icon'],
                  color: isSelected
                      ? Colors.white
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              cat['name'].toUpperCase(),
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMasonryGrid(ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildStyleCard(_featuredStyles[0], 190, colorScheme),
              const SizedBox(height: 16),
              _buildStyleCard(_featuredStyles[2], 260, colorScheme),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildStyleCard(_featuredStyles[1], 260, colorScheme),
              const SizedBox(height: 16),
              _buildStyleCard(_featuredStyles[3], 150, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStyleCard(
      Map<String, dynamic> data, double height, ColorScheme colorScheme) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(data['image']),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    data['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data['rating'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_border_rounded,
                          color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
