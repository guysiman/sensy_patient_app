import 'dart:math';

/// Enum representing stimulation phases.
enum PressurePhase { none, growth, plateau, release }

/// Represents a foot area with a designated zone type.
class FootArea {
  final String id;
  final double left, top, width, height;
  final String zoneType; 

  const FootArea({
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.zoneType,
  });
}

/// The main logic class that encapsulates neuromodulation calculations.
class NeuromodulationLogic {
  // Constants for amplitude and frequency parameters.
  static const double aMin = 0.1;
  static const double aMax = 1.0;
  static const double fMin = 5.0;
  static const double fMax = 200.0;
  static const double pContact = 0.2;

  /// Determines the pressure phase for the given foot zone and time.
  static PressurePhase determinePhase(String zoneType, double t) {
    if (zoneType == 'heel') {
      if (t >= 0.0 && t <= 0.2) return PressurePhase.growth;
      if (t > 0.2 && t <= 0.4) return PressurePhase.plateau;
      if (t > 0.4 && t <= 0.5) return PressurePhase.release;
    } else if (zoneType == 'midfoot') {
      if (t >= 0.2 && t <= 0.4) return PressurePhase.growth;
      if (t > 0.4 && t <= 0.7) return PressurePhase.plateau;
      if (t > 0.7 && t <= 0.9) return PressurePhase.release;
    } else if (zoneType == 'forefoot') {
      if (t >= 0.5 && t <= 0.8) return PressurePhase.growth;
      if (t > 0.8 && t <= 1.0) return PressurePhase.plateau;
      if (t > 1.0 && t <= 1.2) return PressurePhase.release;
    }
    return PressurePhase.none;
  }

  /// Calculates pressure based on the current time, zone type, and phase.
  static double calculatePressure(String zoneType, double t, PressurePhase phase) {
    switch (zoneType) {
      case 'heel':
        switch (phase) {
          case PressurePhase.growth:
            // Linear increase: t in [0,0.2] => pressure = t/0.2.
            return t / 0.2;
          case PressurePhase.plateau:
            return 1.0;
          case PressurePhase.release:
            // Linear decrease: t in (0.4, 0.5] => pressure = 1 - ((t - 0.4) / 0.1).
            return 1.0 - ((t - 0.4) / 0.1);
          default:
            return 0.0;
        }
      case 'midfoot':
        switch (phase) {
          case PressurePhase.growth:
            // t in [0.2, 0.4]
            return (t - 0.2) / 0.2;
          case PressurePhase.plateau:
            return 1.0;
          case PressurePhase.release:
            // t in (0.7, 0.9]
            return 1.0 - ((t - 0.7) / 0.2);
          default:
            return 0.0;
        }
      case 'forefoot':
        switch (phase) {
          case PressurePhase.growth:
            // t in [0.5, 0.8]
            return (t - 0.5) / 0.3;
          case PressurePhase.plateau:
            return 1.0;
          case PressurePhase.release:
            // t in (1.0, 1.2]
            return 1.0 - ((t - 1.0) / 0.2);
          default:
            return 0.0;
        }
      default:
        return 0.0;
    }
  }

  /// Frequency modulation based on zone type and calculated pressure.
  static Map<String, double> frequencyModulation(String zoneType, double pressure) {
    switch (zoneType) {
      case 'forefoot':
        return {
          'sai': 30 * pressure + 5,                     // SAI response (sustained pressure)
          'fai': 100 * pow(pressure, 2).toDouble(),       // FAI response (dynamic pressure)
        };
      case 'midfoot':
        return {
          'saii': 15 * sqrt(pressure) + 2,                // SAII response (skin stretch)
        };
      case 'heel':
        return {
          'faii': 200 * exp(2 * pressure) - 200,          // FAII response (impact/high-freq vibration)
        };
      default:
        return {};
    }
  }


  static double hybridAmplitude(double pressure, double frequency) {
    if (pressure < pContact) return 0.0;
    return aMin + ((0.6 * aMax - aMin) * (frequency - fMin) / (fMax - fMin));
  }

  /// Computes the full neuromodulation result for a given foot area at a specific time.
  static Map<String, dynamic> computeModulation(FootArea area, double time) {
    // Step 1: Determine current phase based on zone type and time.
    PressurePhase phase = determinePhase(area.zoneType, time);
    // Step 2: Calculate pressure based on phase.
    double pressure = calculatePressure(area.zoneType, time, phase);
    // Step 3: Compute frequency modulation using the obtained pressure.
    Map<String, double> freq = frequencyModulation(area.zoneType, pressure);
    // Step 4: Calculate amplitude modulation based on frequency.
    Map<String, double> amp = {};
    freq.forEach((key, value) {
      amp[key] = hybridAmplitude(pressure, value);
    });
    return {
      'areaId': area.id,
      'zoneType': area.zoneType,
      'time': time,
      'phase': phase.toString().split('.').last,
      'pressure': pressure,
      'frequency': freq,
      'amplitude': amp,
    };
  }
}


const List<FootArea> rightFootAreas = [
  FootArea(
    id: 'F0',
    left: 127,
    top: 60,
    width: 24,
    height: 13,
    zoneType: 'forefoot',
  ),
  FootArea(
    id: 'F1',
    left: 127,
    top: 75,
    width: 24,
    height: 13,
    zoneType: 'forefoot',
  ),
  FootArea(
    id: 'F6',
    left: 128,
    top: 104,
    width: 24,
    height: 33,
    zoneType: 'midfoot',
  ),
  FootArea(
    id: 'F9',
    left: 156,
    top: 143,
    width: 26,
    height: 82,
    zoneType: 'heel',
  ),
];


void main() {

  FootArea selectedArea = rightFootAreas.firstWhere((area) => area.id == 'F0');
  double currentTime = 0.6;

  Map<String, dynamic> result = NeuromodulationLogic.computeModulation(selectedArea, currentTime);
  print('Neuromodulation Result:');
  print('Area ID: ${result['areaId']}');
  print('Zone Type: ${result['zoneType']}');
  print('Time: ${result['time']}s');
  print('Phase: ${result['phase']}');
  print('Pressure: ${result['pressure']}');
  print('Frequency: ${result['frequency']}');
  print('Amplitude: ${result['amplitude']}');
}
