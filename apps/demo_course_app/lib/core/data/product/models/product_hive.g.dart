// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductHiveModelAdapter extends TypeAdapter<ProductHiveModel> {
  @override
  final int typeId = 0;

  @override
  ProductHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductHiveModel(
      productId: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      price: fields[3] as double,
      image: fields[4] as String,
      rating: fields[5] as double,
      isSynced: fields[6] as bool,
      action: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProductHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.isSynced)
      ..writeByte(7)
      ..write(obj.action);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
