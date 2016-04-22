import {Component, OnInit, EventEmitter, Input, Output, NgZone} from 'angular2/core';
import {MealFoodFormService} from 'service/meal-food-form.service';

declare var $: any;

@Component({
    selector: 'meal-food-form',
    templateUrl: 'component/meal-food-form.component.html',
    providers: [MealFoodFormService]
})
export class MealFoodFormComponent implements OnInit {
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

    constructor(
        private _ngZone: NgZone,
        private _mealFoodFormService: MealFoodFormService
    ) {}

    ngOnInit() {
        this.initTypeahead();
    }

    private initTypeahead() {
        this._ngZone.runOutsideAngular(() => {
            setTimeout(() => {
                $('meal-food-form .form-control.name').typeahead(
                    {
                        hint: true,
                        highlight: true,
                        minLength: 1
                    },
                    {
                        name: 'foods',
                        source: this._mealFoodFormService.getTypeaheadSource()
                    }
                ).select();
            }, 0);
        });
    }

    save(mealFood) {
        mealFood.id = this._mealFoodFormService.getFoodIdByName(mealFood.name);
        this.onSave.emit(mealFood);
    }

    cancel() {
        this.onCancel.emit(true);
    }

    remove(mealFood) {
        this.onRemove.emit(mealFood);
    }
}