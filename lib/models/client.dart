class Client {
  final String id;
  final String name;
  final double rating;

  const Client({
    required this.id,
    required this.name,
    required this.rating,
  });
}

// Mock data for clients
final List<Client> mockClients = [
  const Client(id: '1', name: 'Rosa Elena Pérez', rating: 4.1),
  const Client(id: '2', name: 'Julio César Suarez', rating: 4.1),
  const Client(id: '3', name: 'Pedro Castillo', rating: 4.1),
];