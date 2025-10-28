// Define los roles disponibles según la API
enum Role {
  client(0),
  company(1);

  final int value;
  const Role(this.value);
}