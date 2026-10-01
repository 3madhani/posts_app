import 'json_parsing.dart';

class Geo {
  final String lat;
  final String lng;

  const Geo({
    required this.lat,
    required this.lng,
  });

  factory Geo.fromJson(Map<String, dynamic> json) {
    return Geo(
      lat: JsonParsing.asString(json['lat']),
      lng: JsonParsing.asString(json['lng']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  Geo copyWith({
    String? lat,
    String? lng,
  }) {
    return Geo(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  String toString() => 'Geo(lat: $lat, lng: $lng)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Geo &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;
}

class Address {
  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: JsonParsing.asString(json['street']),
      suite: JsonParsing.asString(json['suite']),
      city: JsonParsing.asString(json['city']),
      zipcode: JsonParsing.asString(json['zipcode']),
      geo: Geo.fromJson(JsonParsing.asMap(json['geo'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'suite': suite,
      'city': city,
      'zipcode': zipcode,
      'geo': geo.toJson(),
    };
  }

  Address copyWith({
    String? street,
    String? suite,
    String? city,
    String? zipcode,
    Geo? geo,
  }) {
    return Address(
      street: street ?? this.street,
      suite: suite ?? this.suite,
      city: city ?? this.city,
      zipcode: zipcode ?? this.zipcode,
      geo: geo ?? this.geo,
    );
  }

  String get fullAddress => '$suite $street, $city ($zipcode)';

  @override
  String toString() => 'Address(street: $street, city: $city, zipcode: $zipcode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          street == other.street &&
          suite == other.suite &&
          city == other.city &&
          zipcode == other.zipcode &&
          geo == other.geo;

  @override
  int get hashCode =>
      street.hashCode ^
      suite.hashCode ^
      city.hashCode ^
      zipcode.hashCode ^
      geo.hashCode;
}

class Company {
  final String name;
  final String catchPhrase;
  final String bs;

  const Company({
    required this.name,
    required this.catchPhrase,
    required this.bs,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: JsonParsing.asString(json['name']),
      catchPhrase: JsonParsing.asString(json['catchPhrase']),
      bs: JsonParsing.asString(json['bs']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'catchPhrase': catchPhrase,
      'bs': bs,
    };
  }

  Company copyWith({
    String? name,
    String? catchPhrase,
    String? bs,
  }) {
    return Company(
      name: name ?? this.name,
      catchPhrase: catchPhrase ?? this.catchPhrase,
      bs: bs ?? this.bs,
    );
  }

  @override
  String toString() => 'Company(name: $name, catchPhrase: $catchPhrase)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Company &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          catchPhrase == other.catchPhrase &&
          bs == other.bs;

  @override
  int get hashCode => name.hashCode ^ catchPhrase.hashCode ^ bs.hashCode;
}

class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final Address? address;
  final String phone;
  final String website;
  final Company? company;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.address,
    this.phone = '',
    this.website = '',
    this.company,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: JsonParsing.asInt(json['id']),
      name: JsonParsing.asString(json['name']),
      username: JsonParsing.asString(json['username']),
      email: JsonParsing.asString(json['email']),
      address: json['address'] != null
          ? Address.fromJson(JsonParsing.asMap(json['address']))
          : null,
      phone: JsonParsing.asString(json['phone']),
      website: JsonParsing.asString(json['website']),
      company: json['company'] != null
          ? Company.fromJson(JsonParsing.asMap(json['company']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      if (address != null) 'address': address!.toJson(),
      'phone': phone,
      'website': website,
      if (company != null) 'company': company!.toJson(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    Address? address,
    String? phone,
    String? website,
    Company? company,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      company: company ?? this.company,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) {
      return username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?';
    }
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  String toString() => 'User(id: $id, name: $name, username: $username, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          username == other.username &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ username.hashCode ^ email.hashCode;
}
