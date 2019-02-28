class CardEntity {
  String picUrl;
  String text;

  CardEntity(String picUrl, String text) {
    this.picUrl = picUrl;
    this.text = text;
  }
}

class ToolBarEntity {
  String picUrl;
  String title;
  String url;

  ToolBarEntity(String picUrl, String title, String url) {
    this.picUrl = picUrl;
    this.title = title;
    this.url = url;
  }
}
