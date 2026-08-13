/// Maps exercise equipment tags to workout environments.
class EquipmentMapping {
  EquipmentMapping._();

  static const List<String> homeEquipment = [
    'bodyweight',
    'resistance_band',
    'dumbbell',
    'kettlebell',
    'pull_up_bar',
    'foam_roller',
    'yoga_mat',
    'stability_ball',
    'trx',
  ];

  static const List<String> gymEquipment = [
    'barbell',
    'machine',
    'cable',
    'smith_machine',
    'leg_press_machine',
    'lat_pulldown_machine',
    'chest_press_machine',
    'hack_squat_machine',
    'cable_crossover',
    'pec_deck',
    'preacher_curl_machine',
    'seated_row_machine',
  ];

  /// Both-compatible: dumbbell & kettlebell appear in both lists
  static const List<String> bothEquipment = [
    'dumbbell',
    'kettlebell',
    'resistance_band',
    'pull_up_bar',
    'foam_roller',
  ];

  static bool isHomeCompatible(String equipment) =>
      homeEquipment.contains(equipment);

  static bool isGymCompatible(String equipment) =>
      gymEquipment.contains(equipment);

  static bool isBothCompatible(String equipment) =>
      bothEquipment.contains(equipment);
}
