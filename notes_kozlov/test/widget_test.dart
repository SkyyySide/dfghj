import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_kozlov/main.dart';

void main() {
  const draft = Key('new-note');
  const edit = Key('edit-note');

  Finder saveInside(Finder parent) =>
      find.descendant(of: parent, matching: find.text('Сохранить'));

  testWidgets('Validates, adds, edits, and deletes notes', (tester) async {
    await tester.pumpWidget(const NotesApp());

    await tester.enterText(find.byKey(draft), '   ');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Введите текст заметки'), findsOneWidget);
    expect(find.text('Список пока пуст.'), findsOneWidget);

    for (final text in ['Первая запись', 'Вторая запись']) {
      await tester.enterText(find.byKey(draft), text);
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
    }

    final first = find.ancestor(
      of: find.text('Первая запись'),
      matching: find.byType(ListTile),
    );
    final openEditor = find.descendant(
      of: first,
      matching: find.byTooltip('Редактировать заметку'),
    );
    await tester.tap(openEditor);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(edit), '   ');
    await tester.tap(saveInside(find.byType(AlertDialog)));
    await tester.pumpAndSettle();
    expect(find.text('Введите текст заметки'), findsOneWidget);

    await tester.enterText(find.byKey(edit), 'Проверка отмены');
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(find.text('Первая запись'), findsOneWidget);
    expect(find.text('Проверка отмены'), findsNothing);

    await tester.tap(openEditor);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(edit), 'Первая запись обновлена');
    await tester.tap(saveInside(find.byType(AlertDialog)));
    await tester.pumpAndSettle();
    expect(find.text('Первая запись'), findsNothing);
    expect(find.text('Первая запись обновлена'), findsOneWidget);

    final updated = find.ancestor(
      of: find.text('Первая запись обновлена'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(of: updated, matching: find.byTooltip('Удалить заметку')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Первая запись обновлена'), findsNothing);
    expect(find.text('Вторая запись'), findsOneWidget);
  });
}
