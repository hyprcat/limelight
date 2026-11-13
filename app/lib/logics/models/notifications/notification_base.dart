abstract class NotificationBase {
  int? pk;
  String? type;
  String? creationDate;

  NotificationBase({
    this.pk,
    this.type,
    this.creationDate,
  });

  Map<String, dynamic> toJson();
}
