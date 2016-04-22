import {Component, Input, OnInit} from "angular2/core";
import {AutocompleteService} from "service/autocomplete.service";
import {MealFood} from "model/mealFood";

@Component({
    selector: 'autocomplete',
    templateUrl: 'component/autocomplete.component.html',
    providers: [AutocompleteService]
})

export class AutocompleteComponent implements OnInit{
    @Input()
    mealFood: MealFood;
    
    dropdownOpen = false;

    constructor(_autocompleteService: AutocompleteService) {}

    ngOnInit() {

    }

    onKeyUp(e) {
        console.log(e);
        console.log(this.mealFood.name);
        this.dropdownOpen = true;
    }
}