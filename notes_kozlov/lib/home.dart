import 'package:flutter/material.dart';

class Note {
  const Note(this.id, this.text);

  final int id;
  final String text;
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _form = GlobalKey<FormState>();
  final _draft = TextEditingController();
  final _notes = <Note>[];
  int _nextId = 0;

  void _addNote() {
    if (!_form.currentState!.validate()) return;
    final note = Note(_nextId++, _draft.text.trim());
    setState(() => _notes.insert(0, note));
    _draft.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _editNote(Note note) async {
    final text = await showDialog<String>(
      context: context,
      builder: (context) => EditNoteDialog(initialText: note.text),
    );
    if (!mounted || text == null || text == note.text) return;
    final index = _notes.indexWhere((item) => item.id == note.id);
    if (index == -1) return;
    setState(() => _notes[index] = Note(note.id, text));
  }

  void _deleteNote(Note note) {
    setState(() => _notes.removeWhere((item) => item.id == note.id));
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            key: const Key('new-note'),
                            controller: _draft,
                            validator: validateNote,
                            minLines: 3,
                            maxLines: 6,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Новая заметка',
                              hintText: 'Введите текст',
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _addNote,
                            child: const Text('Сохранить'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Мои заметки',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
                if (_notes.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Список пока пуст.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList.separated(
                    itemCount: _notes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return Card(
                        key: ValueKey(note.id),
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          title: Text(note.text),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Редактировать заметку',
                                onPressed: () => _editNote(note),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Удалить заметку',
                                onPressed: () => _deleteNote(note),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? validateNote(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Введите текст заметки';
  }
  return null;
}

class EditNoteDialog extends StatefulWidget {
  const EditNoteDialog({super.key, required this.initialText});

  final String initialText;

  @override
  State<EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<EditNoteDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_form.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать заметку'),
      scrollable: true,
      content: SizedBox(
        width: 380,
        child: Form(
          key: _form,
          child: TextFormField(
            key: const Key('edit-note'),
            controller: _controller,
            validator: validateNote,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Текст заметки',
              alignLabelWithHint: true,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _save, child: const Text('Сохранить')),
      ],
    );
  }
}
