import 'dart:convert';

class TransformerFormModel {
  final String? manufacturer;
  final String? name;
  final int? phases;
  final int? windings;
  final double? xhl;
  final String? bus1;
  final String? conn1;
  final double? kv1;
  final double? kva1;
  final double? r1;
  final String? bus2;
  final String? conn2;
  final double? kva2;
  TransformerFormModel(
      {this.manufacturer,
      this.name,
      this.phases,
      this.windings,
      this.xhl,
      this.bus1,
      this.conn1,
      this.kv1,
      this.kva1,
      this.r1,
      this.bus2,
      this.conn2,
      this.kva2});

  Map<String, dynamic> toMap() {
    return {
      'manufacturer': manufacturer,
      'name': name,
      'phases': phases,
      'windings': windings,
      'xhl': xhl,
      'bus1': bus1,
      'conn1': conn1,
      'kv1': kv1,
      'kva1': kva1,
      'r1': r1,
      'bus2': bus2,
      'conn2': conn2,
    };
  }

  factory TransformerFormModel.fromMap(Map<String, dynamic> map) {
    return TransformerFormModel(
      manufacturer: map['Manufacturer'],
      name: map['Name'],
      phases: map['Phases'],
      windings: map['Windings'],
      xhl: map['Xhl'],
      bus1: map['Bus1'],
      conn1: map['Conn1'],
      kv1: map['Kv1'] != null ? double.parse(map['Kv1']) : null,
      kva1: map['Kva1'] != null ? double.parse(map['Kva1']) : null,
      r1: map['R1'] != null ? double.parse(map['R1']) : null,
      bus2: map['Bus2'],
      conn2: map['Conn2'],
      kva2: map['Kva2'] != null ? double.parse(map['Kva2']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransformerFormModel.fromJson(String source) => TransformerFormModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TransformerFormModel(manufacturer: $manufacturer, name: $name, phases: $phases, windings: $windings, xhl: $xhl, bus1: $bus1, conn1: $conn1, kv1: $kv1, kva1: $kva1, r1: $r1, bus2: $bus2, conn2: $conn2)';
  }
}
