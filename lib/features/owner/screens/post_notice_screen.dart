import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/database_service.dart';
import '../../../core/providers/gym_provider.dart';

class PostNoticeScreen extends StatefulWidget {
  final String? noticeId;
  final String? title;
  final String? content;

  const PostNoticeScreen({
    super.key,
    this.noticeId,
    this.title,
    this.content,
  });

  @override
  State<PostNoticeScreen> createState() => _PostNoticeScreenState();
}

class _PostNoticeScreenState extends State<PostNoticeScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.title != null) _titleController.text = widget.title!;
    if (widget.content != null) _contentController.text = widget.content!;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNotice() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final gymProvider = Provider.of<GymProvider>(context, listen: false);
      final gymDocId = FirebaseAuth.instance.currentUser?.uid;

      if (gymDocId == null) {
        throw Exception("Gym ID not found.");
      }

      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      if (widget.noticeId == null) {
        // Create new notice
        await DatabaseService().addNotice(gymDocId, title, content);
      } else {
        // Update existing notice
        await DatabaseService().updateNotice(gymDocId, widget.noticeId!, title, content);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.noticeId == null ? 'Notice posted to all members!' : 'Notice updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.noticeId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Notice' : 'Post New Notice')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Notice Title', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(controller: _contentController, maxLines: 5, decoration: const InputDecoration(labelText: 'Notice Content', border: OutlineInputBorder())),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveNotice,
                    child: Text(isEditing ? 'Save Changes' : 'Post to Gym'),
                  ),
          ],
        ),
      ),
    );
  }
}
