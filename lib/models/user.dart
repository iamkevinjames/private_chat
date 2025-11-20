class Users {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String userId;

  Users({
    required this.userId,
    required this.id,
    required this.name,
    required this.email,
    this.username,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      username: json['username'] ?? '',
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
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: Address.fromJson(json['address'] ?? {}),
      phone: json['phone']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
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
      street: json['street']?.toString() ?? '',
      suite: json['suite']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      zipcode: json['zipcode']?.toString() ?? '',
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
