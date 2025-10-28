// Define los roles disponibles según la API
enum Role {
  client(1),
  company(0);

  final int value;
  const Role(this.value);
}