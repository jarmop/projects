import {Component, EventEmitter, Input, Output} from 'angular2/core';
import {AutocompleteComponent} from 'component/autocomplete.component';

@Component({
    selector: 'meal-food-form',
    templateUrl: 'component/meal-food-form.component.html',
    directives: [AutocompleteComponent]
})
export class MealFoodFormComponent {
    private _mealFood = {
        'name': null,
        'amount': null
    };
    editingOld = false;

    @Input()
    set mealFood(mealFood) {
        if (mealFood) {
            this._mealFood = mealFood;
            this.editingOld = true;
        }
    }
    get mealFood() { return this._mealFood; }

    @Output() onSave = new EventEmitter<boolean>();
    @Output() onCancel = new EventEmitter<boolean>();
    @Output() onRemove = new EventEmitter<boolean>();

    save(mealFood) {
        this.onSave.emit(mealFood);
    }

    cancel() {
        this.onCancel.emit(true);
    }

    remove(mealFood) {
        this.onRemove.emit(mealFood);
    }
}