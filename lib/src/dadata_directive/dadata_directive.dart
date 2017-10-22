import 'dart:convert';
import 'dart:html';
import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/model/selection/selection_options.dart';
import 'package:angular_components/model/selection/string_selection_options.dart';
import 'package:angular_components/material_input/material_auto_suggest_input.dart';
import 'package:test_directive/src/dadata_directive/dadata_config.dart';

@Directive(selector: '[dadataAddress]')
class DadataDirective {
  final MaterialAutoSuggestInputComponent _suggestElem;

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
    doHttpRequest (
        'https://suggestions.dadata.ru/suggestions/api/4_1/rs/detectAddressByIp?',
        'GET'
    ).then((respMap) {
      kladrId = respMap['location']['data']['kladr_id'] ?? null;
    });
  }

  /// Выполнение http запроса. Возврат данных в виде Map.
  Future doHttpRequest (String url, String requestMethod, {Map requestBody}) => HttpRequest.request(url,
      mimeType:  "application/json",
      requestHeaders: _requestHeaders,
      responseType: "application/json",
      method: requestMethod,
      sendData: (requestBody==null)? null : JSON.encode(requestBody))
      .then((HttpRequest resp) {
        return JSON.decode(resp.response);;
      });

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
    doHttpRequest (
        'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address',
        'POST',
      requestBody: requestBody
    ).then((respMap) {
      List<Map<String, String>> suggList =  respMap["suggestions"];
      _suggestElem.options = new SelectionOptions([new OptionGroup(suggList)]);
    });
  }
}