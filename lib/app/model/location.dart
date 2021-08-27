class Location {
  int? id;
  String? data;
  String? hora;
  String? latitude;
  String? longitude;

  Location({
    this.id,
    this.data,
    this.hora,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        data: json["data"] == null ? null : json["data"],
        hora: json["hora"] == null ? null : json["hora"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "data": data == null ? null : data,
        "hora": hora == null ? null : hora,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
      };
}
