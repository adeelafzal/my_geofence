import 'package:flutter/material.dart';
import 'package:my_geofence/hopitals.dart';
import 'package:my_geofence/main.dart';
import 'package:my_geofence/select_location_screen.dart';

class AddHospitalScreen extends StatelessWidget {
  AddHospitalScreen({Key key}) : super(key: key);

  final hospitalController = TextEditingController();
  final addressController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Hospital"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              buildTextField(
                label: 'Hospital',
                hint: 'Enter hospital name',
                controller: hospitalController,
                keyboardType: TextInputType.text,
                keyboardAction: TextInputAction.next,
                onValidator: (value) {
                  if (value.toString().trim().isEmpty) {
                    return "Please enter hospital name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextField(
                label: 'Address',
                hint: 'Enter hospital address',
                controller: addressController,
                keyboardType: TextInputType.text,
                keyboardAction: TextInputAction.next,
                onValidator: (value) {
                  if (value.toString().trim().isEmpty) {
                    return "Please enter hospital address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextField(
                label: 'Latitude',
                hint: 'Enter hospital latitude',
                controller: latController,
                keyboardType: TextInputType.number,
                keyboardAction: TextInputAction.next,
                onValidator: (value) {
                  if (value.toString().trim().isEmpty) {
                    return "Please enter hospital latitude";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextField(
                label: 'Longitude',
                hint: 'Enter hospital longitude',
                controller: lngController,
                keyboardType: TextInputType.number,
                keyboardAction: TextInputAction.next,
                onValidator: (value) {
                  if (value.toString().trim().isEmpty) {
                    return "Please enter hospital longitude";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Center(child: Text('- - - - - OR - - - - -')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const SearchLocationPage();
                  })).then((value){
                    if(value!=null){
                      addressController.text = value[0]["address"];
                      latController.text = value[0]["lat"].toString();
                      lngController.text = value[0]["lng"].toString();
                    }
                  });
                },
                child: const Text("Open Map"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState.validate()) {
                    return;
                  }
                  hospitals.add(Hospitals(
                    title: hospitalController.text,
                    address: addressController.text,
                    lat: double.parse(latController.text),
                    lng: double.parse(lngController.text),
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Hospital added successfully."),
                  ));
                  Navigator.pop(context);
                },
                child: const Text("Add Hospital"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildTextField({
  TextEditingController controller,
  String Function(String) onValidator,
  @required String label,
  @required String hint,
  @required TextInputType keyboardType,
  @required TextInputAction keyboardAction,
}) {
  return TextFormField(
    controller: controller,
    validator: onValidator,
    keyboardType: keyboardType,
    textInputAction: keyboardAction,
    decoration: InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      hintText: hint,
      labelText: label,
    ),
  );
}
