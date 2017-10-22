import 'dart:convert';
import 'package:http/browser_client.dart';
import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/model/selection/selection_options.dart';
import 'package:angular_components/model/selection/string_selection_options.dart';
import 'package:angular_components/material_input/material_auto_suggest_input.dart';
import 'package:test_directive/src/dadata_directive/dadata_config.dart';

@Directive(selector: '[dadataAddress]')
class DadataDirective {
  final MaterialAutoSuggestInputComponent _suggestElem;
  var _client = new BrowserClient();
  /// Заголовки для работы с API dadata
  Map<String,String> _requestHeaders = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Token ${DadataConfig.token}"
  };
  /// КЛАДР. Используется для сортировки результатов
  String kladrId = null;

  DadataDirective(this._suggestElem) {
    _suggestElem.options = new SelectionOptions( [new OptionGroup<String>(['раз','два']) ]);
    /// Получение КЛАДР
    _client.get('https://suggestions.dadata.ru/suggestions/api/4_1/rs/detectAddressByIp?',headers: _requestHeaders)
        .then((response) {
          Map respMap = JSON.decode(response.body);
          kladrId = respMap['location']['data']['kladr_id'] ?? null;
          print(kladrId);
    });
  }

  @Input("inputText")
  String addressText;

  @HostListener('inputTextChange', const [r'$event'])
  void inputTextChange(String autoSugText) {

    Map requestBody = {
      "query": autoSugText
    };
    if ( kladrId != null ) {
      requestBody["locations_boost"] = [{"kladr_id": kladrId}];
    }

    _client.post(
        'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address',
        headers: {
          "Accept": "application/json",
          "Authorization": "Token ${DadataConfig.token}",
          "content-type": "application/json"
        },
        body: JSON.encode(requestBody))
        .then((response) {
          Map respMap = JSON.decode(response.body);
          List<Map<String, String>> suggList =  respMap["suggestions"];
          _suggestElem.options = new SelectionOptions([new OptionGroup(suggList)]);
    });
  }
}