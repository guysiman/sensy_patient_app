import 'dart:math';
import '../services/auth.dart';
import '../services/database.dart';

class NeuromodulationCalculator {
  // Constants for amplitude ranges
  static const double aMin = 0.1;
  static const double aMax = 1.0;
  static const double fMin = 5.0;
  static const double fMax = 200.0;
  static const double pContact = 0.2;

  // Retrieve patient electrode mapping
  static Future<String?> getPatientElectrodeMapping(String username) async {
    DatabaseService db = DatabaseService();
    String? electrodeMapping = await db.getElectrodeMappingByUsername(username);
    return electrodeMapping;
  }

  // Biomimetic frequency modulation
  static Map<String, double> frequencyModulation(String footZone, double pressure) {
    switch (footZone) {
      case 'forefoot':
        return {
          'sai': 30 * pressure + 5,  // SAI response
          'fai': 100 * pow(pressure, 2).toDouble()  // FAI response
        };
      case 'midfoot':
        return {
          'saii': 15 * sqrt(pressure) + 2  // SAII response
        };
      case 'heel':
        return {
          'faii': 200 * exp(2 * pressure) - 200  // FAII response
        };
      default:
        return {};
    }
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

  // Pressure profile simulation
  static double simulatePressureProfile(double time, double incStart, double incEnd, double plateauEnd, double decEnd) {
    if (time >= incStart && time <= incEnd) {
      return (time - incStart) / (incEnd - incStart);  // Linear increase
    } else if (time > incEnd && time <= plateauEnd) {
      return 1.0;  // Plateau
    } else if (time > plateauEnd && time <= decEnd) {
      return 1.0 - (time - plateauEnd) / (decEnd - plateauEnd);  // Linear decrease
    } else {
      return 0.0;
    }
  }

  // Calculate neuromodulation response
  static Future<Map<String, dynamic>> calculateModulation(String username, double pressure) async {
    String? electrodeMapping = await getPatientElectrodeMapping(username);
    if (electrodeMapping == null) {
      return {'error': 'Electrode mapping not found for user'};
    }

    Map<String, double> frequency = frequencyModulation(electrodeMapping, pressure);
    Map<String, double> result = {};

    frequency.forEach((key, value) {
      result[key] = hybridAmplitude(pressure, value);
    });

    return {
      'electrode': electrodeMapping,
      'frequency': frequency,
      'amplitude': result
    };
  }
}
