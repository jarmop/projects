import {Component, Input} from "angular2/core";

@Component({
    selector: 'autocomplete',
    templateUrl: 'component/autocomplete.component.html'
})

export class AutocompleteComponent {
    @Input()
    mealFood: Object;
}