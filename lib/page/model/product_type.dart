class ListProductType {
  int? value;
  String? name;

  ListProductType(this.value, this.name);

  static List<ListProductType> getListProductType() {
    return [
      ListProductType(1, 'ร้อน'),
      ListProductType(2, 'เย็น'),
      ListProductType(3, 'ปั่น'),
    ];
  }
}
