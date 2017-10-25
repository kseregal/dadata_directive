import 'dart:convert';
import 'package:http/browser_client.dart';
import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/model/selection/selection_options.dart';
import 'package:angular_components/material_input/material_auto_suggest_input.dart';
import 'package:test_directive/src/dadata_directive/dadata_config.dart';

/// Директива автоподсказок сервиса dadata.ru
///
/// Используется для компонента material_auto_suggest_input.
/// Пример:
/// <material-auto-suggest-input
/// dadata="jur"
/// (blur)="jur_blur()"
/// [selection]="jurSelectionModel"
/// [selectionOptions]="jurOptions"
/// [itemRenderer]="itemUniversalRenderer"
/// [componentRenderer]="jurComponentRenderer"
/// [(inputText)]="jurInputText"
/// label="Организация"
///class="inp">
///
///</material-auto-suggest-input>
///
///  dadata="jur" - в кавычках указываем возможные варианты использования подсказок
///  address - автоподсказка адресов.
///  surname - автоподсказка фамилий.
///  name - автоподсказка имен.
///  patronymic - автоподсказка отчеств.
///  fio - автоподсказка фамилий имен и отчеств.
///  bank - по реквизитам банка.
///  jur - по реквизитам организации.
///
/// [selectionOptions]="jurOptions" - список подсказок, который заполняет директива используя
/// значение поля auto-suggest.
///
@Directive(selector: '[dadata]')
class DadataDirective {
  final MaterialAutoSuggestInputComponent _suggestElem;
  BrowserClient _client = new BrowserClient();

  /// Список вариантов использованвия dadata, где
  /// учитывается местонахождение (геолокация до города).
  List<String> geoLocationVariants = const[ 'ADDRESS', 'JUR', 'BANK' ];
  /// Заголовки для работы с API dadata
  Map<String,String> _requestHeaders = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Token ${DadataConfig.token}"
  };
  /// КЛАДР. Используется для сортировки подсказок в соответствии с геолокацией.
  String kladrId = null;

  DadataDirective(this._suggestElem) {
    _suggestElem.options = new SelectionOptions( [new OptionGroup<String>([])]);
    /// Получение КЛАДР. Здесь Dadata делает геолокацию по IP адресу.
    _client.get('https://suggestions.dadata.ru/suggestions/api/4_1/rs/detectAddressByIp?',headers: _requestHeaders)
        .then((response) {
          Map respMap = JSON.decode(response.body);
          kladrId = respMap['location']['data']['kladr_id'] ?? null;
    });
  }

  /// Пол. Определяется как свойство компонента.
  @Input()
  String gender;

  /// Вариант автоподсказки.
  @Input()
  String dadata;

  /// Храним здесь введенный текст.
  String _autoSugText;

  /// Таймер отсчитывает DadataConfig.delay и выполняет collback
  Timer _timer=null;

  startTimeout() {
    return new Timer(new Duration(milliseconds: DadataConfig.delay), find);
  }

  /// Колбэк таймера, который выполняет запрос к dadata.
  find() {
    print(dadata);
    Map requestBody = {
      "query": _autoSugText
    };
    /// Для подсказки ФИО не важен город. Поэтому locations_boost в этом случае
    /// в запросе не указываем.
    if (  geoLocationVariants.contains(dadata.toUpperCase())  &&
        kladrId != null ) {
      requestBody["locations_boost"] = [{"kladr_id": kladrId}];
    }
    if ( gender!=null && (gender.toUpperCase()=='MALE' || gender.toUpperCase()=='FEMALE') ) {
      requestBody["gender"] = gender.toUpperCase();
    }

    String url = 'nooooo';
    print(dadata.toUpperCase());
    switch (dadata.toUpperCase()) {
      case 'ADDRESS':
        url = 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address';
        break;
      case 'SURNAME':
      case 'NAME':
      case 'PATRONYMIC':
        /// Определяем, какую часть подсказки ФИО нам нужна: Фамилия, Имя или Отчество.
        requestBody["parts"] = [dadata.toUpperCase()];
        /// Если пол определен, то получаем подсказки с учетом пола.
        if (gender!=null) {
            requestBody["gender"] = gender;
        }
        url = 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/fio';
        break;
      case 'FIO':
        url = 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/fio';
        break;
      case 'JUR':
        url = 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/party';
        break;
      case 'BANK':
        url = 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/bank';
        break;
      case 'EMAIL':
        url = 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/email';
        break;
    }

    _client.post(
        url,
        headers: _requestHeaders,
        body: JSON.encode(requestBody))
        .then((response) {
      Map respMap = JSON.decode(response.body);
      List<Map<String, String>> suggList =  respMap["suggestions"];
      _suggestElem.options = new SelectionOptions([new OptionGroup(suggList)]);
    });

  }

  @HostListener('inputTextChange', const [r'$event'])
  void inputTextChange(String autoSugText) {

    _autoSugText = autoSugText;

    if (_timer!=null && _timer.isActive) {
      _timer.cancel();
    }

    _timer = startTimeout();
  }
}