class UploadedImage {
  String url;
  String oldname;

  UploadedImage(this.url, this.oldname);

  @override
  String toString() {
    return "url: $url";
  }
}

class UploadableImage {
  String? devicePath;
  String? fileName;
  String? serverPath;

  UploadableImage(this.devicePath, this.fileName, this.serverPath);

  @override
  String toString() {
    return fileName.toString() + " " + serverPath.toString();
  }
}