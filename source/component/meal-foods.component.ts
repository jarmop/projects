import {Component, OnInit, EventEmitter, Input, Output, NgZone} from 'angular2/core';
import {MealFoodsComponent} from 'component/meal-foods.component';

declare var $: any;
declare var Bloodhound:any;

@Component({
    selector: 'meal-foods',
    templateUrl: 'component/meal-foods.component.html'
})
export class MealFoodsComponent implements OnInit {
    @Input() mealFoods: Array;
    @Output() onFoodRemoved = new EventEmitter<boolean>();

    selectedFood;
    isAddOpen = false;
    addForm = {
        'name': null,
        'amount': null
    };
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
        this.mealFoods.splice(this.mealFoods.indexOf(mealFood), 1);
        this.onFoodRemoved.emit(mealFood);
    }

    editMode(food = null) {
        if (food) {
            return this.selectedFood === food;
        }
        return this.selectedFood;
    }

    openEdit(food) {
        this.selectedFood = food;
        this.closeAdd();
    }

    save(food) {
        this.selectedFood = null;
    }

    openAdd(el, a) {
        this.isAddOpen = true;
        this.selectedFood = null;
        this.initTypeahead();
    }

    closeAdd() {
        this.isAddOpen = false;
    }

    saveAdd() {
        this.closeAdd();
    }
}