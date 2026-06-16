import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Member {
  final String id;
  final String name;
  final String phone;
  final String planEndDate;

  Member({required this.id, required this.name, required this.phone, required this.planEndDate});
}

class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  final List<Member> _allMembers = [
    Member(id: 'M001', name: 'Kasun Perera', phone: '0771234567', planEndDate: '2026-06-15'),
    Member(id: 'M002', name: 'Nimal Silva', phone: '0719876543', planEndDate: '2026-05-20'),
    Member(id: 'M003', name: 'Amara Wickrama', phone: '0755556666', planEndDate: '2026-12-01'),
    Member(id: 'M004', name: 'Dilshan Madushanka', phone: '0701112222', planEndDate: '2026-04-10'),
    Member(id: 'M005', name: 'Samantha Rathnayake', phone: '0783334444', planEndDate: '2026-08-30'),
  ];

  List<Member> _filteredMembers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredMembers = _allMembers;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = _allMembers.where((m) => 
        m.name.toLowerCase().contains(query) || 
        m.phone.contains(query) || 
        m.id.toLowerCase().contains(query)
      ).toList();
    });
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch dialer')));
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '94${cleanPhone.substring(1)}';
    }
    final Uri url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
    }
  }

  void _markAttendance(Member member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance marked for ${member.name}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDelete(Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to remove ${member.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _allMembers.removeWhere((m) => m.id == member.id);
                _onSearchChanged();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, ID or phone...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredMembers.length,
              itemBuilder: (context, index) {
                final member = _filteredMembers[index];
                return _buildMemberCard(member);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Member member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withAlpha((0.1 * 255).toInt())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.02 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt()),
                child: Text(member.name[0], style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('ID: ${member.id}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MemberDetailsScreen(member: member))),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.phone_android_rounded, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(member.phone, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isPlanExpiring(member.planEndDate) ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Plan Ends: ${member.planEndDate}',
                  style: TextStyle(
                    color: _isPlanExpiring(member.planEndDate) ? Colors.red : Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionIcon(Icons.phone_rounded, Colors.blue, () => _makePhoneCall(member.phone)),
              const SizedBox(width: 10),
              _buildActionIcon(Icons.chat_bubble_rounded, Colors.green, () => _openWhatsApp(member.phone)),
              const SizedBox(width: 10),
              _buildActionIcon(Icons.how_to_reg_rounded, Colors.orange, () => _markAttendance(member)),
              const SizedBox(width: 10),
              _buildActionIcon(Icons.delete_outline_rounded, Colors.red, () => _confirmDelete(member)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  bool _isPlanExpiring(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return date.difference(now).inDays < 7;
    } catch (e) {
      return false;
    }
  }
}

class MemberDetailsScreen extends StatelessWidget {
  final Member member;
  const MemberDetailsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt()),
              child: Text(member.name[0], style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Text(member.name, style: Theme.of(context).textTheme.headlineMedium),
            Text('ID: ${member.id}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            const Text('Detailed member information, history, and analytics will be displayed here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
