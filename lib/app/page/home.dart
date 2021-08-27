import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:projeto_geoposic/app/controller/geo_controller.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = GeoController();

  @override
  void initState() {
    super.initState();

    controller.initGeo();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("${controller.locations.length}"),
        ),
        body: Container(
            child: ListView.builder(
                itemCount: controller.locations.length,
                itemBuilder: (context, index) {
                  return !controller.loading
                      ? Container(
                          child: Column(
                            children: [
                              Text(
                                "latitude: ${controller.locations[index].latitude}",
                              ),
                              Text(
                                'longitude: ${controller.locations[index].longitude}',
                              ),
                              Text(
                                "data: ${controller.locations[index].data}",
                              ),
                              Text(
                                'hora: ${controller.locations[index].hora}',
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: Center(
                          child: CircularProgressIndicator(),
                        ));
                })),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await controller.update();
          },
          tooltip: 'Increment',
          child: Icon(Icons.update),
        ),
      );
    });
  }
}
