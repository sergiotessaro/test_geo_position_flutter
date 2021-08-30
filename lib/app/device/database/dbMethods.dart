import 'package:projeto_geoposic/app/device/database/dbHandler.dart';
import 'package:projeto_geoposic/app/model/location.dart';


class LocationTableHandler {
  final database = DatabaseHandler();

  create(Location location) async {
    try {
      var db = await (database.db);
      await db!.transaction((txn) async {
        return await txn.insert('location', location.toJson());
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Location>> search() async {
    try {
      var db = await (database.db);
      List<Map> list = await db!.transaction((txn) async {
        return await txn.query('location');
      });

      if (list.length > 0) {
        List<Location> locations = list.map<Location>((local) {
          return Location.fromJson(local as Map<String, dynamic>);
        }).toList();

        return locations;
      }

      return [];
    } catch (e) {
      throw e;
    }
  }
}
