import 'package:flutter/material.dart';

import 'package:socialseed/data/models/map_model.dart';
import 'package:socialseed/features/services/map_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<Feature> items = [];

  void placeAutoComplete(String val) async {
    await MapService().getData(val).then((value) {
      setState(() {
        items = value;
      });
    });
  }

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              maxLines: null,
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'London',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => placeAutoComplete(val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, idx) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('No Items'),
                  );
                }

                return ListTile(
                  onTap: () {
                    Navigator.pop(context, items[idx].properties.name);
                  },
                  leading: const Icon(Icons.place),
                  title: Text(
                    items[idx].properties.name,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
