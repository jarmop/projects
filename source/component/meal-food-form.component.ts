import {Component, OnInit, EventEmitter, Input, Output, NgZone} from 'angular2/core';

declare var $: any;
declare var Bloodhound:any;

@Component({
    selector: 'meal-food-form',
    templateUrl: 'component/meal-food-form.component.html'
})
export class MealFoodFormComponent implements OnInit {
    private _mealFood = {
        'name': null,
        'amount': null
    };
    private foods = ['banaani','porkkana','puuro','peruna','papu'];
    private bloodhound;
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
        private _ngZone: NgZone
    ) {}

    ngOnInit() {
        this.initTypeahead();
    }

    private initTypeahead() {
        this.bloodhound = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.whitespace,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            local: this.foods
        });
        this._ngZone.runOutsideAngular(() => {
            setTimeout(() => {
                $('meal-food-form .form-control.name').typeahead(
                    {
                        hint: true,
                        highlight: true,
                        minLength: 1
                    },
                    {
                        name: 'states',
                        source: this.bloodhound
                    }
                ).select();
            }, 0);
        });
    }

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