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
    editingOld = false;

    @Input()
    set mealFood(mealFood) {
        if (mealFood) {
            this._mealFood = mealFood;
            this.editingOld = true;
        }
    }
    get mealFood() { return this._mealFood; }

    @Output() onRemove = new EventEmitter<boolean>();
    @Output() onSave = new EventEmitter<boolean>();

    // selectedMealFood;
    // blankMealFood = {
    //     'name': null,
    //     'amount': null
    // };
    states = ['banaani','porkkana','puuro','peruna','papu'];
    bloodhound;

    constructor(
        private _ngZone: NgZone
    ) {}

    ngOnInit() {
        this.bloodhound = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.whitespace,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            local: this.states
        });
        this.initTypeahead();
    }

    private initTypeahead() {
        this._ngZone.runOutsideAngular(() => {
            setTimeout(() => {
                $('#add-name').typeahead(
                    {
                        hint: true,
                        highlight: true,
                        minLength: 1
                    },
                    {
                        name: 'states',
                        source: this.bloodhound
                    }
                ).focus();
            }, 0);
        });
    }

    remove(mealFood) {
        this.onRemove.emit(mealFood);
    }

    save(mealFood) {
        this.onSave.emit(mealFood);
    }


    // openAdd(el, a) {
    //     this.isAddOpen = true;
    //     this.selectedMealFood = null;
    //     this.initTypeahead();
    // }
    //
    // closeAdd() {
    //     this.isAddOpen = false;
    // }
    //
    // saveAdd() {
    //     this.closeAdd();
    // }

}