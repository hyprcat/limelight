class ContestBanner {
  String? label;
  String? type;
  String? title;
  String? description;
  String? ctaLabel;
  String? bannerLink;
  String? url;
  String? color = "ffffff00";
  bool? shouldUseDarkText = false;
  bool? containsUrl = false;

  ContestBanner(
      {this.label,
      this.type,
      this.title,
      this.description,
      this.ctaLabel,
      this.bannerLink,
      this.url,
      this.color,
      this.containsUrl,
      this.shouldUseDarkText});

  ContestBanner.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    type = json['type'];
    title = json['title'];
    description = json['description'];
    ctaLabel = json['CTA_label'];
    bannerLink = json['background_link'];
    color = json['color'];
    shouldUseDarkText = json['use_dark_text'];
    containsUrl = json['contains_url'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'type': type,
      'title': title,
      'description': description,
      'CTA_label': ctaLabel,
      'background_link': bannerLink,
      'color': color
    };
  }
}
