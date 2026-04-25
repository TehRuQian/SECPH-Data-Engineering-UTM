import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

class NoteEditorPage extends StatefulWidget {
  final Note? note; // null when creating a new note

  const NoteEditorPage({super.key, this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  final _service = NotesService();

  bool _saving = false;
  String? _errorMessage; // null = no error shown; set by _save() on failure

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  /// Map raw exceptions from addNote/updateNote into short, user-readable text.
  String _friendlyNotesError(Object e) {
    final msg = e.toString().toLowerCase();
    // Service-side guard from NotesService — empty title after trim.
    if (e is ArgumentError || msg.contains('title cannot be empty')) {
      return "Title cannot be empty.";
    }
    if (msg.contains('permission-denied')) {
      return "You don't have permission to save this note. Please sign in again.";
    }
    if (msg.contains('unavailable') || msg.contains('network')) {
      return "Can't reach Firestore. Check your internet connection and try again.";
    }
    if (msg.contains('not-found')) {
      return "This note no longer exists. It may have been deleted on another device.";
    }
    return "Couldn't save your note. Please try again.";
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear any stale error from a previous failed attempt BEFORE we try again.
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      if (_isEditing) {
        await _service.updateNote(
          id: widget.note!.id,
          title: _titleController.text,
          body: _bodyController.text,
        );
      } else {
        await _service.addNote(
          title: _titleController.text,
          body: _bodyController.text,
        );
      }
      // Success → _errorMessage is already null from the line above.
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      // Show the friendly message inline (NOT a SnackBar that disappears).
      setState(() => _errorMessage = _friendlyNotesError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (!_isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.deleteNote(widget.note!.id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _friendlyNotesError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit note' : 'New note'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _bodyController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Inline error banner ──
              // Visible only when _errorMessage != null.
              // Cleared automatically at the start of the next _save() attempt.
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.red.shade700,
                        tooltip: 'Dismiss',
                        onPressed: () =>
                            setState(() => _errorMessage = null),
                      ),
                    ],
                  ),
                ),

              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Save changes' : 'Create note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}