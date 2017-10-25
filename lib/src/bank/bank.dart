class Bank {
  String name;
  String fullName;

  String bic;
  String swift;
  String okpo;
  String correspondentAccount;
  String registrationNumber;
  String addressOneString;
  String stateStatus;

  Bank(this.name);
  Bank.fromMap(Map bankMap) {
    name = bankMap['value'];
    fullName = bankMap['data']['name']['full'];
    bic = bankMap['data']['bic'];
    swift = bankMap['data']['swift'];
    okpo = bankMap['data']['okpo'];
    correspondentAccount = bankMap['data']['correspondent_account'];
    registrationNumber = bankMap['data']['registration_number'];
    addressOneString = bankMap['data']['address']['value'];
    stateStatus = bankMap['data']['state']['status'];
  }
}