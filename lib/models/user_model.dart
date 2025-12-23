class UserResponse {
  final String? token;
  final String? userName;
  final String? fullName;
  final String? avatarUrl;
  final String? role;

  UserResponse({
    this.token,
    this.userName,
    this.fullName,
    this.avatarUrl,
    this.role,
  });

  factory UserResponse.fromJson(
    Map<String, dynamic> json, {
    String? tokenFromStorage,
  }) {
    // parse basic fields
    final String? userName = json['userName']?.toString();
    final String? fullName = json['fullName']?.toString();
    final String? avatarUrl = json['avatarUrl']?.toString();

    // normalize role from different possible shapes
    String? role;
    if (json['role'] != null) {
      role = json['role'].toString();
    } else if (json['roles'] != null) {
      final r = json['roles'];
      if (r is String) {
        role = r;
      } else if (r is Iterable && r.isNotEmpty) {
        final first = r.first;
        if (first is String) {
          role = first;
        } else if (first is Map) {
          role = (first['normalizedName'] ?? first['name'] ?? first['role'])
              ?.toString();
        }
      }
    } else if (json['normalizedRole'] != null) {
      role = json['normalizedRole'].toString();
    }

    return UserResponse(
      token: tokenFromStorage ?? json['token']?.toString(),
      userName: userName,
      fullName: fullName,
      avatarUrl: avatarUrl,
      role: role,
    );
  }
}
