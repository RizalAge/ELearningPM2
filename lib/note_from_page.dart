import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latihanshared/notes_page.dart';

import 'note.dart';
import 'note_db.dart';

class NoteFormPage extends StatefulWidget {
  final Note? note;
  const NoteFormPage({super.key, this.note});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _contentC = TextEditingController();

  DateTime? deadline;

  bool get _isEdit => widget.note != null;

  String get deadlineText =>
      deadline == null ? '-' : DateFormat('dd MMM yyyy').format(deadline!);

  Color get previewColor => noteColorByDeadline(deadline);

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    if (n != null) {
      _titleC.text = n.title;
      _contentC.text = n.content;
      deadline = n.deadline;
    }
  }

  @override
  void dispose() {
    _titleC.dispose();
    _contentC.dispose();
    super.dispose();
  }

  Future<void> pickDeadline() async {
    final now = DateTime.now();
    final init = deadline ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(init.year, init.month, init.day),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() => deadline = picked);
    }
  }

  void _clearDeadline() {
    setState(() => deadline = null);
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id,
      title: _titleC.text.trim(),
      content: _contentC.text.trim(),
      createdAt: widget.note?.createdAt ?? now,
      deadline: deadline,
    );

    if (_isEdit) {
      await NoteDb.instance.update(note.id!, note.toMap());
    } else {
      await NoteDb.instance.insert(note.toMap());
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Note' : 'Tambah Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: previewColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Preview warna (berdasarkan deadline)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleC,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Judul wajib' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _contentC,
                decoration: const InputDecoration(
                  labelText: 'Isi',
                  border: OutlineInputBorder(),
                ),
                minLines: 4,
                maxLines: 8,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Isi wajib' : null,
              ),
              const SizedBox(height: 16),

              Text('Deadline: $deadlineText'),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: pickDeadline,
                      child: const Text('Pilih Deadline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearDeadline,
                      child: const Text('Hapus Deadline'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

Column(
  children: [
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: save,
        child: const Text('Simpan'),
      ),
    ),
    const SizedBox(height: 12),

    SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // aksi baca
        },
        child: const Text('Baca'),
      ),
    ),
    const SizedBox(height: 12),

    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        onPressed: () {
          // aksi hapus
        },
        child: const Text('Hapus'),
      ),
    ),
  ],
),

            ],
          ),
        ),
      ),
    );
  }
}
