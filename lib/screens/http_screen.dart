import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:signals/signals_flutter.dart';

const apiUrl = "https://v2.jokeapi.dev/joke/Programming?type=twopart&blacklistFlags=nsfw,religious,political,racist,sexist,explicit";

typedef Joke = ({String setup, String delivery});

final s = asyncSignal<Joke?>(AsyncState.data(null));

Future<void> getJoke() async {
  s.value = AsyncState.loading();

  try {
    final response = await http.get(Uri.parse(apiUrl));
    final data = jsonDecode(response.body);

    if (data['error'] == true) {
      s.value = AsyncState.error("Error", null);
      return;
    }
    final Joke joke = (setup: data['setup'], delivery: data['delivery']);
    s.value = AsyncState.data(joke);
  } catch (e, st) {
    s.value = AsyncState.error(e, st);
  }
}

class HttpScreen extends StatelessWidget {
  const HttpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Http"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                getJoke();
              },
              icon: Icon(Icons.refresh),
            ),
            Watch.builder(builder: (context) {
              if (s.value.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (s.value.hasError) {
                return Center(
                  child: Text(s.value.error.toString()),
                );
              }

              final joke = s.value.value;
              if (joke == null) {
                return Text("Tap the button to load a joke!");
              }

              return Text(
                "${joke.setup}\n\n${joke.delivery}",
                textAlign: TextAlign.center,
              );
            })
          ],
        ),
      ),
    );
  }
}
