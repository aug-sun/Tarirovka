class AppSettings {
  String userName;
  String companyName;
  bool darkMode;
  bool separateExport;

  AppSettings({
    this.userName = 'Иван Иванов',
    this.companyName = 'ООО «Сантел Сервис»',
    this.darkMode = false,
    this.separateExport = false,
  });

  Map<String, dynamic> toJson() => {
    'user_name': userName,
    'company_name': companyName,
    'dark_mode': darkMode,
    'separate_export': separateExport,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      userName: json['user_name']?.toString() ?? 'Иван Иванов',
      companyName: json['company_name']?.toString() ?? 'ООО «Сантел Сервис»',
      darkMode: json['dark_mode'] == true,
      separateExport: json['separate_export'] == true,
    );
  }
}
