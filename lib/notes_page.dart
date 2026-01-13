import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latihanshared/note_from_page.dart';

import 'note.dart';
import 'note_db.dart';
import 'note_form_page.dart';
import 'note_color.dart'; // asumsi fungsi noteColorByDeadline ada di sini

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await NoteDb.instance.queryAll();
    _notes = rows.map((e) => Note.fromMap(e)).toList();
    setState(() => _loading = false);
  }

  Future<void> openCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoteFormPage()),
    );
    await _load();
  }

  Future<void> openEdit(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteFormPage(note: note)),
    );
    await _load();
  }

  Future<void> delete(int id) async {
    await NoteDb.instance.delete(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openCreate,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: _notes.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, i) {
                  final n = _notes[i];
                  final color = noteColorByDeadline(n.deadline);

                  final deadlineText = n.deadline == null
                      ? 'Non-priority'
                      : DateFormat('dd MMM yyyy')
                          .format(n.deadline!);

                  return Dismissible(
                    key: ValueKey(n.id),
                    direction: DismissDirection.up,
                    onDismissed: (_) {
                      if (n.id != null) delete(n.id!);
                    },
                    child: InkWell(
                      onTap: () => openEdit(n),
                      borderRadius: BorderRadius.circular(16),
                      child: Card(
                        elevation: 2,
                        color: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  n.content,
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      const TextStyle(fontSize: 13),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                deadlineText,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class NoteDb {
  static var instance;
}
