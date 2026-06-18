import 'package:flutter/material.dart';

class InfoSection {
  final IconData icon;
  final String heading;
  final String body;

  const InfoSection({
    required this.icon,
    required this.heading,
    required this.body,
  });
}

class InfoDetailScreen extends StatelessWidget {
  final String title;
  final List<InfoSection> sections;

  const InfoDetailScreen({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkTheme
          ? const Color(0xFF111424)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20.0),
          itemCount: sections.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final section = sections[index];
            return Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDarkTheme ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDarkTheme ? Colors.white10 : Colors.grey.shade100,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          section.icon,
                          color: const Color(0xFF2962FF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          section.heading,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme
                                ? Colors.white
                                : const Color(0xFF1A237E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.black12, height: 1),
                  ),
                  Text(
                    section.body,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
