/// Организация.
///
class Jur {
  String name;
  String fullName;
  String inn;

  String managementName;
  String address;
  String stateStatus;

  Jur.fromMap(Map jurMap) {
    name = jurMap['value'];
    fullName = jurMap['data']['name']['full'];
    inn = jurMap['data']['inn'];

    managementName = jurMap['data']['management']['name'];

    address = jurMap['data']['address']['value'];
    stateStatus = jurMap['data']['state']['status'];
  }
}