import 'package:angular/angular.dart';
//import 'dart:convert';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_input/material_auto_suggest_input.dart';
//import 'package:angular_components/model/selection/select.dart';
import 'package:angular_components/model/selection/selection_model.dart';
import 'package:angular_components/model/selection/selection_options.dart';
import 'package:angular_components/model/ui/has_renderer.dart';
//import 'package:angular_components/model/selection/string_selection_options.dart';
import 'package:dadata_directive2/src/dadata_directive.dart';
import 'package:test_directive/src/bank/bank.dart';
import 'package:test_directive/src/jur/jur.dart';

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [
    materialDirectives,
    MaterialAutoSuggestInputComponent,
    DadataDirective,
    NgIf
  ],
  providers: const [materialProviders],
)
class AppComponent {
  /// Реализует определение тех данных Item из SelectionOptions, кот. необходимо показывать в material suggest
  ItemRenderer get itemUniversalRenderer => _myRendener;

  /// По умолчанию пол неизвестен. DADATA воспринимает параметр в таком виде, и выдает
  /// подсказки независимо от пола.
  String gender = 'UNKNOWN';

  /// Проверка наличия данных о поле в результатах выбранной подсказки и установка значения gender.
  void setGender(SelectionModel model) {
    if (!model.isEmpty && model.selectedValues.first['data'] != null) {
      gender = model.selectedValues.first['data']['gender'] ?? null;
    }
  }

  /// Для региона:
  /// Пустой список. Необходим для инициализации.
  SelectionOptions regionOptions =
      new SelectionOptions([new OptionGroup<List<int>>(const <List<int>>[])]);
  SelectionModel regionSelectionModel =
      new SelectionModel.withList(allowMulti: false);
  ItemRenderer get itemRegionRenderer => (Map<String, dynamic> itemMap) {
        return itemMap['data']['region_with_type'] ?? itemMap['data']['region'];
      };
  String regionInputText;

  /// Для города:
  /// Пустой список. Необходим для инициализации.
  SelectionOptions cityOptions =
      new SelectionOptions([new OptionGroup<List<int>>(const <List<int>>[])]);
  String cityInputText;

  /// Геттер класса реализации отрисовки элементов списка.
  SelectionModel citySelectionModel =
      new SelectionModel.withList(allowMulti: false);

  /// Обработка события выбора элемента списка подсказок.

  ItemRenderer get itemCityRenderer => _itemCityRenderer;

  /// Для адреса:
  String cityKladrId;
  String cityFiasId;
  String street;
  String streetTypeFull;

  /// Пустой список. Необходим для инициализации.
  SelectionOptions options =
      new SelectionOptions([new OptionGroup<List<int>>(const <List<int>>[])]);
  String inputText;

  /// Геттер класса реализации отрисовки элементов списка.
  ComponentRenderer get myComponentRenderer => (_) => OneRowRendererComponent;
  SelectionModel addressSelectionModel =
      new SelectionModel.withList(allowMulti: false);

  /// Обработка события выбора элемента списка подсказок.
  address_blur() {
    cityFiasId =
        addressSelectionModel.selectedValues.first['data']['city_fias_id'];
    cityKladrId =
        addressSelectionModel.selectedValues.first['data']['city_kladr_id'];
    street = addressSelectionModel.selectedValues.first['data']['street'];
    streetTypeFull =
        addressSelectionModel.selectedValues.first['data']['street_type_full'];
  }

  /// Пустой список. Необходим для инициализации.
  SelectionOptions fioOptions =
      new SelectionOptions([new OptionGroup<List<int>>(const <List<int>>[])]);
  String fioInputText;
  final SelectionModel surnameSelectionModel =
      new SelectionModel.withList(allowMulti: false);

  /// Контроллер выбора подсказки в поле Фамилия.
  surname_blur() {
    setGender(surnameSelectionModel);
  }

  /// Имя
  String nameInputText;
  SelectionOptions nameOptions =
      new SelectionOptions([new OptionGroup<List<int>>(const <List<int>>[])]);
  final SelectionModel nameSelectionModel =
      new SelectionModel.withList(allowMulti: false);

  name_blur() {
    setGender(nameSelectionModel);
  }

  /// БАНК.
  /// Пустой список. Необходим для инициализации.
  SelectionOptions bankOptions =
      new SelectionOptions([new OptionGroup<List<int>>(const <List<int>>[])]);
  String bankInputText;

  /// Геттер класса реализации отрисовки элементов списка.
  ComponentRenderer get bankComponentRenderer =>
      (_) => OneRowBankRendererComponent;
  final SelectionModel bankSelectionModel =
      new SelectionModel.withList(allowMulti: false);
  Bank bank = null;

  bank_blur() {
    Map selectedBank = bankSelectionModel.selectedValues.first;
    bank = new Bank.fromMap(selectedBank);
  }

  /// ОРГАНИЗАЦИЯ
  ///
  SelectionOptions jurOptions =
      new SelectionOptions([new OptionGroup<List<int>>(const <List<int>>[])]);
  String jurInputText;

  /// Геттер класса реализации отрисовки элементов списка.
  ComponentRenderer get jurComponentRenderer =>
      (_) => OneRowJurRendererComponent;
  final SelectionModel jurSelectionModel =
      new SelectionModel.withList(allowMulti: false);
  Jur organization = null;
  jur_blur() {
    Map selectedOrganization = jurSelectionModel.selectedValues.first;
    organization = new Jur.fromMap(selectedOrganization);
  }

  ///  EMAIL
  SelectionOptions emailOptions =
      new SelectionOptions([new OptionGroup<List<int>>(const <List<int>>[])]);
  String emailInputText;
  final SelectionModel emailSelectionModel =
      new SelectionModel.withList(allowMulti: false);
}

ItemRenderer _itemCityRenderer = (Map<String, dynamic> itemMap) {
  return itemMap['data']['city_with_type'] ?? "";
};

// Вынесено вне классов, т.к используется и в AppComponent, и в OneRowRendererComponent.
/// Извлекает данные из хэша данные автоподсказки.
/// Структуру объекта JSON ответа сервера можно посмотреть здесь
/// https://dadata.ru/api/suggest/#response-address
ItemRenderer _myRendener = (Map<String, dynamic> itemMap) {
  return itemMap['value'] ?? "";
};

/// Компонент отображения одной строки списка.
///
/// Реализует отрисовку одной строки выпадающего списка, извлекая нужные данные
/// из объекта Map с порцией адресных данных.
@Component(selector: 'adres-renderer', template: '''{{displayValue}}''')
class OneRowRendererComponent implements RendersValue {
  String displayValue = '';

  @override
  @Input()
  set value(addressMap) {
    displayValue = _myRendener(addressMap);
  }
}

/// Компонент отображения одной строки списка подсказки банков.
///
/// Реализует отрисовку одной строки выпадающего списка, извлекая нужные данные
/// из объекта Map с порцией адресных данных.
@Component(
    selector: 'bank-renderer',
    template: '''
    <div class="bank">
    {{bankFullName}}<br/> <span class="second_row">{{bankBic}} {{bankCity}}</span>
    </div>''',
    styles: const [
      '.bank { border-bottom: 1px solid gray;} .second_row { font-size: 12px; color: gray;}'
    ])
class OneRowBankRendererComponent implements RendersValue {
  /// БИК.
  String bankBic = '';

  /// Наименование банка одной строкой (как показывается в списке подсказок).
  String bankFullName = '';

  /// SWIFT
  String bankSwift = '';

  /// Город
  String bankCity = '';

  @override
  @Input()
  set value(addressMap) {
    bankFullName = addressMap['value'] ?? addressMap['unrestricted_value'];
    bankBic = addressMap['data']['bic'] ?? '';
    bankSwift = addressMap['data']['swift'] ?? '';
    bankCity = (addressMap['data']['address']['data'] != null)
        ? addressMap['data']['address']['data']['city']
        : '';
  }
}

/// Компонент отображения одной строки списка подсказки банков.
///
/// Реализует отрисовку одной строки выпадающего списка, извлекая нужные данные
/// из объекта Map с порцией адресных данных.
@Component(
    selector: 'jur-renderer',
    template: '''
    <div class="jur">
    {{fullName}}<br/> <span class="second_row">{{inn}} {{jurCity}}</span>
    </div>''',
    styles: const [
      '.jur { border-bottom: 1px solid gray;} .second_row { font-size: 12px; color: gray;}'
    ])
class OneRowJurRendererComponent implements RendersValue {
  /// ИНН.
  String inn = '';

  /// Наименование организации одной строкой (как показывается в списке подсказок).
  String fullName = '';

  /// Город
  String jurCity = '';

  @override
  @Input()
  set value(jurMap) {
    fullName = jurMap['value'] ?? jurMap['unrestricted_value'];
    inn = jurMap['data']['inn'] ?? '';
    jurCity = (jurMap['data']['address']['data'] != null)
        ? jurMap['data']['address']['data']['city']
        : '';
  }
}
