import 'package:flutter/material.dart';
import '../home.dart';
import '../models/emergency_contact.dart';
import '../storage/contact_storage.dart';

/// Shown after onboarding ([CompleteScreen] → `/usersos`). Hosts the map/SOS
/// [HomeScreen] plus Contact, Notification, and Profile in one bottom bar.
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          _DashboardContactsBody(),
          _DashboardNotificationsBody(),
          _DashboardProfileBody(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: Colors.red.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Contact',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardContactsBody extends StatefulWidget {
  const _DashboardContactsBody();

  @override
  State<_DashboardContactsBody> createState() => _DashboardContactsBodyState();
}

class _DashboardContactsBodyState extends State<_DashboardContactsBody> {
  final ContactStorage _storage = ContactStorage();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<EmergencyContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await _storage.loadContacts();
    if (mounted) setState(() => _contacts = list);
  }

  Future<void> _add() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;
    setState(() {
      _contacts = [
        ..._contacts,
        EmergencyContact(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      ];
    });
    await _storage.saveContacts(_contacts);
    _nameController.clear();
    _phoneController.clear();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _remove(int index) async {
    setState(() => _contacts = List.of(_contacts)..removeAt(index));
    await _storage.saveContacts(_contacts);
  }

  void _showAddDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add emergency contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            onPressed: _add,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _contacts.isEmpty
          ? Center(
              child: Text(
                'No saved contacts yet.\nAdd people to reach in an emergency.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], height: 1.4),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _contacts.length,
              itemBuilder: (_, i) {
                final c = _contacts[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: Text(
                        c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    title: Text(c.name),
                    subtitle: Text(c.phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _remove(i),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _DashboardNotificationsBody extends StatelessWidget {
  const _DashboardNotificationsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.info_outline, color: Colors.grey[700]),
              title: const Text('No alerts yet'),
              subtitle: Text(
                'Safety notifications and updates will appear here.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardProfileBody extends StatelessWidget {
  const _DashboardProfileBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.red,
              child: Icon(Icons.shield_outlined, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'HAVEN',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A Space for Safety',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.red),
              title: const Text('Account'),
              subtitle: Text(
                'Signed in after setup. Manage phone or name later when those settings are added.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
