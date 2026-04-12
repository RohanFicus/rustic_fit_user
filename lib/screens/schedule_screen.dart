import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Workout Schedule',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                    fontFamily: 'Georgia',
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5E6D3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Week View
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDayCard('Mon', '12', false),
                  _buildDayCard('Tue', '13', false),
                  _buildDayCard('Wed', '14', true),
                  _buildDayCard('Thu', '15', false),
                  _buildDayCard('Fri', '16', false),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Workout List
            Expanded(
              child: ListView(
                children: [
                  _workoutCard(
                    'Full Body Workout',
                    'Today, 8:00 AM',
                    '45 min',
                    Icons.accessibility,
                    const Color(0xFFD4AF37),
                  ),
                  const SizedBox(height: 15),
                  _workoutCard(
                    'Cardio',
                    'Tomorrow, 7:00 AM',
                    '30 min',
                    Icons.directions_run,
                    Colors.grey[300]!,
                  ),
                  const SizedBox(height: 15),
                  _workoutCard(
                    'Yoga',
                    'Friday, 6:00 PM',
                    '60 min',
                    Icons.self_improvement,
                    const Color(0xFFD4AF37),
                  ),
                  const SizedBox(height: 15),
                  _workoutCard(
                    'Strength Training',
                    'Saturday, 9:00 AM',
                    '50 min',
                    Icons.fitness_center,
                    const Color(0xFFD4AF37),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(String day, String date, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD4AF37) : const Color(0xFFF5E6D3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.white : const Color(0xFFD4AF37),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              color: isActive ? Colors.white : const Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _workoutCard(String title, String time, String duration, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6D3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              duration,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
