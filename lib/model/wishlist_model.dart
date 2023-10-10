class WishlistItem {
  final String id;
  final String title;
  final String image;
  final String? details;

  WishlistItem(
      {required this.id,
      required this.title,
      required this.image,
      this.details});
}
