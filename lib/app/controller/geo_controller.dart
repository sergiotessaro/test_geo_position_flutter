import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projeto_geoposic/app/model/location.dart';
import 'package:projeto_geoposic/app/device/database/dbMethods.dart';

part 'geo_controller.g.dart';

class GeoController = _GeoControllerBase with _$GeoController;

abstract class _GeoControllerBase with Store {
  static const String isolateName = 'LocatorIsolate';

  @observable
  ObservableList<Location> locations = ObservableList();

  ReceivePort port = ReceivePort();

  String longitude = "";
  String latitude = "";

  @observable
  bool loading = false;

  initGeo() async {
    if (await _checkLocationPermission()) {
      try {
        loading = true;
        if (!(await BackgroundLocator.isRegisterLocationUpdate())) {
          IsolateNameServer.registerPortWithName(port.sendPort, isolateName);
          port.listen((dynamic data) {
            print(data.toString());
          });
          _initPlatformState();
        }

        locations = ObservableList.of(await LocationTableHandler().search());
      } catch (e) {
        print(e);
      } finally {
        loading = false;
      }
      //
    }
  }

  @action
  update() async {
    try {
      loading = true;
      locations = ObservableList.of(await LocationTableHandler().search());

      print(locations.length);
    } catch (e) {
      print(e);
    } finally {
      loading = false;
    }
  }

  Future<bool> _checkLocationPermission() async {
    return Permission.location.request().isGranted;
  }

  Future<void> _initPlatformState() async {
    await BackgroundLocator.initialize();
    startLocationService();
  }

  // Future<void> callback(LocationDto locationDto) async {
  //   final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
  //   send?.send(locationDto);
  //   DateTime now = DateTime.now();
  //   Location l = new Location(
  //       data: "${now.day}/${now.month}/${now.year}",
  //       hora: "${now.hour}/${now.minute}/${now.second}",
  //       latitude: locationDto.latitude.toString(),
  //       longitude: locationDto.longitude.toString());
  //   new LocationTableHandler().create(l);
  // }

  void startLocationService() async {
    Map<String, dynamic> data = {'countInit': 1};
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.HIGH,
            interval: 40,
            distanceFilter: 2,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Procurando Localização',
                notificationTitle: 'Procurando ...',
                notificationMsg: 'Procurando localização com o app fechado',
                notificationBigMsg:
                    'Estamos procurando sua localização para salvar em nosso servidor',
                notificationIcon: '',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }
}

class LocationCallbackHandler {
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  static Future<void> disposeCallback() async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  static Future<void> callback(LocationDto locationDto) async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.callback(locationDto);
  }

  static Future<void> notificationCallback() async {
    print('***notificationCallback');
  }
}

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  int _count = -1;
  static const String isolateName = 'LocatorIsolate';

  Future<void> init(Map<dynamic, dynamic> params) async {
    //TODO change logs
    print("***********Init callback handler");
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    print("$_count");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    print("***********Dispose callback handler");
    print("$_count");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    GeoController controller = GeoController();
    try {
      final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
      send?.send(locationDto);

      DateTime now = DateTime.now();
      Location l = new Location(
          data: "${now.day}/${now.month}/${now.year}",
          hora: "${now.hour}:${now.minute}:${now.second}",
          latitude: locationDto.latitude.toString(),
          longitude: locationDto.longitude.toString());
      await LocationTableHandler().create(l);
      print("opa");
      await controller.update();
    } catch (e) {
      print(e);
    }
  }
}
