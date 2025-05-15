class StoredAccount {
  final String email;
  final String password;
  final String username;

  StoredAccount(
      {required this.email, required this.password, required this.username});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'username': username,
      };

  factory StoredAccount.fromJson(Map<String, dynamic> json) => StoredAccount(
        email: json['email'],
        password: json['password'],
        username: json['username'],
      );
}
