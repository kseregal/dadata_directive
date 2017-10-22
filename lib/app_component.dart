import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_input/material_auto_suggest_input.dart';
import 'package:test_directive/src/dadata_directive/dadata_directive.dart';

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [materialDirectives, MaterialAutoSuggestInputComponent, DadataDirective],
  providers: const [materialProviders],
)
class AppComponent {
  /// Пустой список. Необходим для инициализации.
  SelectionOptions options = new SelectionOptions([new OptionGroup<List<int>>(const <List<int>>[]) ]);
  String inputText;
  /// Реализует определение тех данных Item из SelectionOptions, кот. необходимо показывать в material suggest
  ItemRenderer get itemAddressRenderer => _myAddressRendener;
  /// Геттер класса реализации отрисовки элементов списка.
  ComponentRenderer get componentRenderer =>  (_) => OneRowRendererComponent;

}
// Вынесено вне классов, т.к используется и в AppComponent, и в OneRowRendererComponent.
ItemRenderer _myAddressRendener = ( Map<String, String> addressMap) {
  return addressMap['value'] ?? "";
};

/// Компонент отображения одной строки списка.
///
/// Реализует отрисовку одной строки выпадающего списка, извлекая нужные данные
/// из объекта Map с порцией адресных данных.
@Component(
    selector: 'adres-renderer',
    template: '''{{displayValue}}'''
)
class OneRowRendererComponent implements RendersValue {
  String displayValue = '';

  @override
  @Input()
  set value(addressMap) {
    displayValue = _myAddressRendener(addressMap);
  }
}
