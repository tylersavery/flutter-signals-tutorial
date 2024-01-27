import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:state_beacon/state_beacon.dart';

const apiUrl =
    "https://v2.jokeapi.dev/joke/Programming?type=twopart&blacklistFlags=nsfw,religious,political,racist,sexist,explicit";

typedef Joke = ({String setup, String delivery});

final beacon = Beacon.future(() => getJoke(), manualStart: true);

Future<Joke> getJoke() async {
  final response = await http.get(Uri.parse(apiUrl));
  final data = jsonDecode(response.body);

  if (data['error'] == true) {
    throw Exception("Error");
  }

  final Joke joke = (setup: data['setup'], delivery: data['delivery']);

  return joke;
}

class HttpScreenBeacon extends StatelessWidget {
  const HttpScreenBeacon({super.key});

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
                if (beacon.isIdle) {
                  beacon.start();
                } else {
                  beacon.reset();
                }
              },
              icon: Icon(Icons.refresh),
            ),
            Builder(builder: (context) {
              return switch (beacon.watch(context)) {
                AsyncIdle _ => Text("Tap the button to load a joke!"),
                AsyncLoading _ => Center(child: CircularProgressIndicator()),
                AsyncError data => Center(child: Text(data.error.toString())),
                AsyncData<Joke> data => Text(
                    "${data.value.setup}\n\n${data.value.delivery}",
                    textAlign: TextAlign.center,
                  ),
              };
            }),
          ],
        ),
      ),
    );
  }
}
