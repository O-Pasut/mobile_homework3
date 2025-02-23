class Product {
  int id = 0;
  String name = '';
  String description = '';
  double price = 0.0;

  Product(this.id, this.name, this.description, this.price);

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        price = json['price'];

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'email': price};
  }
}
