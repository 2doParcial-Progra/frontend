class Token {
  final String? token;

  Token({this.token});

  // Constructor desde JSON
  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      token: json['token'] as String?,
    );
  }

  // Convertir a JSON (aunque rara vez necesario)
  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}