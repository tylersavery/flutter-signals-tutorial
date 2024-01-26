import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

typedef Todo = ({
  int id,
  String label,
  bool completed,
});

final List<Todo> initialState = [
  (id: 1, label: "read docs", completed: true),
  (id: 2, label: "write code", completed: false),
  (id: 3, label: "ship it", completed: false),
];

final todos = <Todo>[...initialState].toSignal();

final todoCount = computed(() {
  return todos.length;
});

final activeTodoCount = computed(() {
  return todos.where((todo) => !todo.completed).length;
});

final completedTodoCount = computed(() {
  return todos.where((todo) => todo.completed).length;
});

enum Filter {
  all("All"),
  active("Active"),
  completed("Completed"),
  ;

  final String label;
  const Filter(this.label);
}

final filter = signal<Filter>(Filter.all);

final filteredTodos = computed(() {
  final currentFilter = filter.value;
  final currentTodos = todos;

  switch (currentFilter) {
    case Filter.all:
      return currentTodos.toList();
    case Filter.active:
      return currentTodos.where((todo) => !todo.completed).toList();
    case Filter.completed:
      return currentTodos.where((todo) => todo.completed).toList();
  }
});

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textEditingController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Todos"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton(
              onSelected: (value) {
                filter.value = value;
              },
              itemBuilder: (context) {
                return Filter.values.map((filter) {
                  return PopupMenuItem(
                    value: filter,
                    child: Text(filter.label),
                  );
                }).toList();
              },
              child: Text("Filter: ${filter.watch(context).label}"),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String? label = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("New Task"),
                content: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: "New Task",
                  ),
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(textEditingController.text);
                      textEditingController.clear();
                    },
                    child: Text("Add"),
                  ),
                ],
              );
            },
          );

          if (label != null && label.isNotEmpty) {
            todos.add((id: todoCount.value + 1, label: label, completed: false));
          }
        },
        child: Icon(Icons.add),
      ),
      body: Watch.builder(builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Total: ${todoCount.value}\nActive: ${activeTodoCount.value}\nCompleted: ${completedTodoCount.value}",
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: filteredTodos.value.length,
                  itemBuilder: (context, index) {
                    final todo = filteredTodos.value[index];
                    return Card(
                      child: ListTile(
                        title: Text(todo.label),
                        trailing: Checkbox(
                          value: todo.completed,
                          onChanged: (value) {
                            if (value != null) {
                              final i = todos.indexWhere((t) => t.id == todo.id);
                              if (i >= 0) {
                                todos[i] = (id: todo.id, label: todo.label, completed: value);
                              }
                            }
                          },
                        ),
                      ),
                    );
                  }),
            ),
          ],
        );
      }),
    );
  }
}
