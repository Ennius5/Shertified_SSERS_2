import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../storage/contact_storage.dart';
import '../widgets/sos_button.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final ContactStorage storage = ContactStorage();
  final String serverUrl = "https://yourserver.com"; // <- set your server here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  List<EmergencyContact> contacts = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final loaded = await storage.loadContacts();
    setState(() => contacts = loaded);
  }

  Future<void> addContact() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) return;

    setState(() {
      contacts.add(EmergencyContact(
        name: nameController.text,
        phone: phoneController.text,
      ));
    });

    await storage.saveContacts(contacts);

    nameController.clear();
    phoneController.clear();
  }

  Future<void> removeContact(int index) async {
    setState(() {
      contacts.removeAt(index);
    });

    await storage.saveContacts(contacts);
  }

  void showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              addContact();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(title: const Text("SOS Contacts", style: TextStyle(color: Colors.white),), backgroundColor: Colors.grey[800],),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (_, index) {
                final c = contacts[index];
                return ListTile(
                  title: Text(c.name, style: const TextStyle(color: Colors.white),),
                  subtitle: Text(c.phone, style: const TextStyle(color: Colors.white),),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent,),
                    onPressed: () => removeContact(index),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          SosButton(contacts: contacts),
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}