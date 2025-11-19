class Users {
  final int id;
  final String name;
  final String email;
  final String userId;

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.userId,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      userId: json['userId'],
    );
  }
}

class UserDetails {
  final int id;
  final String name;
  final String username;
  final String email;
  final Address address;
  final String phone;
  final String website;
  final String userId;

  UserDetails({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.address,
    required this.phone,
    required this.website,
    required this.userId,
  });

  factory UserDetails.fromJson(dynamic json) {
    return UserDetails(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      address: Address.fromJson(json['address']), // ✅ fix
      phone: json['phone'],
      website: json['website'],
      userId: json['userId'],
    );
  }
}

class Address {
  final String street;
  final String suite;
  final String city;
  final String zipcode;

  Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
  });

  factory Address.fromJson(dynamic json) {
    return Address(
      street: json['street'],
      suite: json['suite'],
      city: json['city'],
      zipcode: json['zipcode'],
    );
  }
}

class Geo {
  final String lat;
  final String lng;

  Geo({required this.lat, required this.lng});

  factory Geo.fromJson(dynamic json) {
    return Geo(lat: json['lat'], lng: json['lng']);
  }
}

class Company {
  final String name;
  final String catchPhrase;
  final String bs;

  Company({required this.name, required this.catchPhrase, required this.bs});

  factory Company.fromJson(dynamic json) {
    return Company(
      name: json['name'],
      catchPhrase: json['catchPhrase'],
      bs: json['bs'],
    );
  }
}

class Messages {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime created_at;

  Messages({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.created_at,
  });

  factory Messages.fromJson(dynamic json) {
    return Messages(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      created_at: DateTime.parse(json['created_at']),
    );
  }
}
