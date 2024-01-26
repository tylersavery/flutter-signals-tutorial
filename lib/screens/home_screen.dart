import 'package:flsigs/screens/counter_screen.dart';
import 'package:flsigs/screens/http_screen.dart';
import 'package:flsigs/screens/todo_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: ListView(children: [
        _NavItem(
          label: "Counter",
          screen: CounterScreen(),
        ),
        _NavItem(
          label: "Todos",
          screen: TodoScreen(),
        ),
        _NavItem(
          label: "Http",
          screen: HttpScreen(),
        )
      ]),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final Widget screen;
  const _NavItem({
    required this.label,
    required this.screen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Icon(Icons.chevron_right),
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          ),
        },
      ),
    );
  }
}
