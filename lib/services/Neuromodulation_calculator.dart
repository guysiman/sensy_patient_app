import 'dart:math';

class NeuromodulationCalculator {
  // Constants for amplitude ranges
  static const double aMin = 0.1;
  static const double aMax = 1.0;
  static const double fMin = 5.0;
  static const double fMax = 200.0;
  static const double pContact = 0.2;

  // Biomimetic frequency modulation for forefoot (SAI and FAI)
  static Map<String, double> frequencyModulationForefoot(double pressure) {
    return {
      'sai': 30 * pressure + 5,       // SAI (sustained pressure)
      'fai': 100 * pow(pressure, 2),   // FAI (dynamic pressure)
    };
  }

  // Biomimetic frequency modulation for midfoot (SAII)
  static double frequencyModulationMidfoot(double pressure) {
    return 15 * sqrt(pressure) + 2;    // SAII (midfoot)
  }

  // Biomimetic frequency modulation for heel (FAII)
  static double frequencyModulationHeel(double pressure) {
    return 200 * exp(2 * pressure) - 200; // FAII (heel)
  }

  // Hybrid amplitude modulation
  static double hybridAmplitude(double pressure, double frequency) {
    if (pressure < pContact) return 0.0;
    return aMin + (0.6 * aMax - aMin) * (frequency - fMin) / (fMax - fMin);
  }

  // Linear amplitude modulation
  static double linearAmplitude(double pressure) {
    if (pressure < pContact) return 0.0;
    return aMin + (aMax - aMin) * ((pressure - pContact) / (1 - pContact));
  }

  // Simulate pressure profile (linear growth, plateau, linear decrease)
  static double simulatePressureProfile(
    double time, 
    double incStart, 
    double incEnd, 
    double plateauEnd, 
    double decEnd
  ) {
    if (time >= incStart && time <= incEnd) {
      // Linear increase
      return (time - incStart) / (incEnd - incStart);
    } else if (time > incEnd && time <= plateauEnd) {
      // Plateau
      return 1.0;
    } else if (time > plateauEnd && time <= decEnd) {
      // Linear decrease
      return 1.0 - (time - plateauEnd) / (decEnd - plateauEnd);
    } else {
      // No pressure
      return 0.0;
    }
  }

  

}