// // lib/models/user.dart

class Users {
  final int id;
  final String name; // full name (fallback)
  final String email;
  final String? username; // optional username you want to display
  final String userId; // auth uid stored in the DB (userId or user_id)

  Users({
    required this.userId,
    required this.id,
    required this.name,
    required this.email,
    this.username,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    // Safely read id as int
    final dynamic rawId = json['id'] ?? json['Id'];
    final int parsedId = rawId is int ? rawId : int.parse(rawId.toString());

    // Name can be stored as 'name' or 'full_name'
    final String parsedName = (json['full_name'] ?? json['name'] ?? '')
        .toString();

    // Email may be missing in some rows; keep empty string fallback
    final String parsedEmail = (json['email'] ?? '').toString();

    // Username column might be named 'username' or 'user_name' in your table
    final String? parsedUsername = (json['username'] ?? json['user_name'])
        ?.toString();

    // Auth uid stored in your DB might be camelCase "userId" or snake_case "user_id"
    final String? parsedUserId = (json['userId'] ?? json['user_id'])
        ?.toString();

    return Users(
      id: parsedId,
      name: parsedName.isNotEmpty ? parsedName : parsedEmail.split('@').first,
      email: parsedEmail,
      username: (parsedUsername != null && parsedUsername.isNotEmpty)
          ? parsedUsername
          : null,
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
