class SKU {
  int? id;
  String name;
  String bName;
  String type;
  String card_num;
  int code;
  String valid_till;
  int waive;
  int count;

  SKU({
    this.id,
    required this.name,
    required this.bName,
    required this.type,
    required this.card_num,
    required this.code,
    required this.valid_till,
    required this.waive,
    required this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'b_name': bName,
      'type': type,
      'card_num': card_num,
      'code': code,
      'valid_till': valid_till,
      'waive': waive,
      'count': count,
    };
  }

  static SKU fromMap(Map<String, dynamic> map) {
    return SKU(
      id: map['_id'],
      name: map['name'],
      bName: map['b_name'],
      type: map['type'],
      card_num: map['card_num'],
      code: map['code'],
      valid_till: map['valid_till'],
      waive: map['waive'],
      count: map['count'],
    );
  }
}
