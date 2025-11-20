// // lib/models/user.dart

class Users {
  final int id;
  final String name; // full name (fallback)
  final String email;
  final String? username; // optional username you want to display
  final String? userId; // auth uid stored in the DB (userId or user_id)
  final String? phone;
  final String? website;

  Users({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.userId,
    this.phone,
    this.website,
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

    final String? parsedPhone =
        (json['phone'] ?? json['mobile'] ?? json['phone_number'])?.toString();
    final String? parsedWebsite = (json['website'] ?? json['url'])?.toString();

    return Users(
      id: parsedId,
      name: parsedName.isNotEmpty
          ? parsedName
          : (parsedEmail.isNotEmpty ? parsedEmail.split('@').first : ''),
      email: parsedEmail,
      username: (parsedUsername != null && parsedUsername.isNotEmpty)
          ? parsedUsername
          : null,
      userId: parsedUserId,
      phone: (parsedPhone != null && parsedPhone.isNotEmpty)
          ? parsedPhone
          : null,
      website: (parsedWebsite != null && parsedWebsite.isNotEmpty)
          ? parsedWebsite
          : null,
    );
  }
}

class UserDetails {
  final int id;
  final String name;
  final String username;
  final String email;
  final Address address;
  final String? phone;
  final String? website;
  final String userId;

  UserDetails({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.address,
    this.phone,
    this.website,
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
      phone: json['phone']?.toString(),
      website: json['website']?.toString(),
      userId: (json['userId'] ?? json['user_id']).toString(),
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
    final createdStr = (json['created_at'] ?? json['timestamp'] ?? '')
        .toString();
    DateTime created;
    try {
      created = DateTime.parse(createdStr);
    } catch (_) {
      created = DateTime.now();
    }

    return Messages(
      senderId: (json['senderId'] ?? json['sender_id'] ?? '').toString(),
      receiverId: (json['receiverId'] ?? json['receiver_id'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      created_at: created,
    );
  }
}
