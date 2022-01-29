import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_geofence/main.dart';

class HospitalScreen extends StatelessWidget {
  const HospitalScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restaurants")),
      body: ListView.separated(
        separatorBuilder: (_, int index) => const Divider(thickness: 1),
        itemCount: hospitals.length,
        itemBuilder: (_, int index) => ListTile(
          title: Text(hospitals[index].title),
          subtitle: Text(hospitals[index].address),
          trailing: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.directions,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
