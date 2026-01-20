import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class AISuggestions extends StatefulWidget {
  final Function(int focus, int breakTime) onSuggestionsReceived;
  final SettingsService? settingsService;

  const AISuggestions({
    super.key,
    required this.onSuggestionsReceived,
    this.settingsService,
  });

  @override
  State<AISuggestions> createState() => _AISuggestionsState();
}

class _AISuggestionsState extends State<AISuggestions>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _focusController = TextEditingController();
  final TextEditingController _breakController = TextEditingController();
  
  Map<String, dynamic>? _aiProgram;
  String _aiExplanation = '';
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _moodController.dispose();
    _focusController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  void _showAIForm() {
    setState(() {
      _showForm = true;
    });
    _fadeController.forward();
  }

  void _generateAIProgram() {
    final mood = _moodController.text.toLowerCase();
    final focusTime = int.tryParse(_focusController.text) ?? 25;
    final breakActivity = _breakController.text.toLowerCase();

    // Haftalık performans analizi
    final weeklyStats = widget.settingsService?.getWeeklyStats() ?? {};
    final weeklyFocusMinutes = weeklyStats['weeklyFocusMinutes'] ?? 0;
    final weeklySuccess = weeklyStats['weeklySuccessRate'] ?? 0.0;
    final avgDailyFocus = weeklyFocusMinutes > 0 ? weeklyFocusMinutes / 7 : 0;

    // Basit AI mantığı
    String energyLevel = "normal";
    
    if (mood.contains('yorgun') || mood.contains('bitkin') || mood.contains('kötü')) {
      energyLevel = "low";
    } else if (mood.contains('enerjik') || mood.contains('iyi') || mood.contains('harika')) {
      energyLevel = "high";
    }

    int suggestedFocus;
    int suggestedBreak;
    int cycles;
    String explanation;

    // Haftalık performansa göre ayarlama
    double performanceMultiplier = 1.0;
    if (weeklyFocusMinutes > 0) {
      if (weeklySuccess > 0.8) {
        performanceMultiplier = 1.1; // Başarılıysa biraz artır
      } else if (weeklySuccess < 0.5) {
        performanceMultiplier = 0.8; // Başarısızsa azalt
      }
    }

    switch (energyLevel) {
      case "low":
        suggestedFocus = ((focusTime - 5) * performanceMultiplier).round().clamp(10, 25);
        suggestedBreak = (focusTime / 3).round().clamp(7, 12);
        cycles = 3;
        explanation = "Yorgun olduğun için daha kısa odak süreleri ($suggestedFocus dk) öneriyorum. ";
        break;
      case "high":
        suggestedFocus = ((focusTime + 5) * performanceMultiplier).round().clamp(25, 50);
        suggestedBreak = (focusTime / 6).round().clamp(5, 8);
        cycles = 6;
        explanation = "Enerjin yüksek! Daha uzun odak süreleri ($suggestedFocus dk) deneyebilirsin. ";
        break;
      default:
        suggestedFocus = (focusTime * performanceMultiplier).round().clamp(15, 45);
        suggestedBreak = (focusTime / 5).round().clamp(5, 10);
        cycles = 5;
        explanation = "Dengeli bir gün için $suggestedFocus dakika odak öneriyorum. ";
    }

    // Haftalık performans analizi ekleme
    if (weeklyFocusMinutes > 0) {
      explanation += "Bu hafta toplam ${weeklyFocusMinutes} dakika odaklandın (günlük ort: ${avgDailyFocus.toInt()} dk). ";
      if (weeklySuccess > 0.8) {
        explanation += "Harika performans! %${(weeklySuccess * 100).toInt()} başarı oranın var. ";
      } else if (weeklySuccess < 0.5) {
        explanation += "Bu hafta zorlandın (%${(weeklySuccess * 100).toInt()} başarı). Daha kısa sürelerle başlayalım. ";
      }
    }

    // Mola aktivitesi analizi
    if (breakActivity.contains('yürü') || breakActivity.contains('hareket')) {
      suggestedBreak = (suggestedBreak * 1.2).round().clamp(5, 15);
      explanation += "Aktif molalar harika! Biraz daha uzun süre ayırdım. ";
    } else if (breakActivity.contains('telefon') || breakActivity.contains('sosyal')) {
      explanation += "Telefon yerine göz dinlendirici aktiviteler daha iyi olur. ";
    }

    final totalFocusTime = suggestedFocus * cycles;
    explanation += "Günlük $cycles pomodoro ile toplam $totalFocusTime dakika odaklanmış olacaksın.";

    setState(() {
      _aiProgram = {
        'focus': suggestedFocus,
        'break': suggestedBreak,
        'cycles': cycles,
        'totalTime': totalFocusTime,
      };
      _aiExplanation = explanation;
      _showForm = false;
    });

    widget.onSuggestionsReceived(suggestedFocus, suggestedBreak);
    
    _fadeController.reverse().then((_) {
      _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'AI Program Önerisi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            if (!_showForm)
              GestureDetector(
                onTap: _showAIForm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4).withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'Öneri Al',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        if (_showForm)
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildAIForm(),
          )
        else if (_aiProgram != null)
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildAIResult(),
          )
        else
          Text(
            'Kişiselleştirilmiş program önerisi almak için "Öneri Al" butonuna tıklayın.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildAIForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _moodController,
          label: 'Bugün nasılsın?',
          hint: 'Enerjik, yorgun, normal...',
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _focusController,
          label: 'İdeal odak süren kaç dakika?',
          hint: '25',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _breakController,
          label: 'Molada ne yaparsın?',
          hint: 'Yürürüm, su içerim, telefona bakarım...',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showForm = false;
                  });
                  _fadeController.reverse();
                },
                child: const Text(
                  'İptal',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _generateAIProgram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Öneri Al'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4ECDC4),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF4ECDC4).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📚 Günlük Çalışma Programı',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4ECDC4),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '🎯 Önerilen Odak: ${_aiProgram!['focus']} dakika',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              Text(
                '☕ Önerilen Mola: ${_aiProgram!['break']} dakika',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4ECDC4),
                ),
              ),
              Text(
                '🔄 Günlük Döngü: ${_aiProgram!['cycles']} pomodoro',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          '💡 Açıklama:',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFFFEB3B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _aiExplanation,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.8),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}