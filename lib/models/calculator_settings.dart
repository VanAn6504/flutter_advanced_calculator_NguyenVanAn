class CalculatorSettings {
  int decimalPrecision;
  bool hapticFeedback;
  bool soundEffects;
  int historySize;
  String angleMode;

  CalculatorSettings({
    this.decimalPrecision = 6,
    this.hapticFeedback = true,
    this.soundEffects = false,
    this.historySize = 50,
    this.angleMode = 'degrees',
  });

  Map<String, dynamic> toJson() => {
    'decimalPrecision': decimalPrecision,
    'hapticFeedback': hapticFeedback,
    'soundEffects': soundEffects,
    'historySize': historySize,
    'angleMode': angleMode,
  };

  factory CalculatorSettings.fromJson(Map<String, dynamic> json) => CalculatorSettings(
    decimalPrecision: json['decimalPrecision'] ?? 6,
    hapticFeedback: json['hapticFeedback'] ?? true,
    soundEffects: json['soundEffects'] ?? false,
    historySize: json['historySize'] ?? 50,
    angleMode: json['angleMode'] ?? 'degrees',
  );
}