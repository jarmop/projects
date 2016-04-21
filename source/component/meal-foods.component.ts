import {Component, OnInit, EventEmitter, Input, Output, NgZone} from 'angular2/core';
import {MealFoodFormComponent} from 'component/meal-food-form.component';

declare var $: any;
declare var Bloodhound:any;

@Component({
    selector: 'meal-foods',
    templateUrl: 'component/meal-foods.component.html',
    directives: [MealFoodFormComponent]
})
export class MealFoodsComponent implements OnInit {
    @Input() mealFoods: Array;
    @Output() onMealFoodRemoved = new EventEmitter<boolean>();
    @Output() onMealFoodSaved = new EventEmitter<boolean>();

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
    
    removeMealFood(mealFood) {
        this.mealFoods.splice(this.mealFoods.indexOf(mealFood), 1);
        this.onMealFoodRemoved.emit(mealFood);
    }

    saveMealFood(mealFood) {
        this.selectedFood = null;
        this.onMealFoodSaved.emit(mealFood);
    }

    editMode(mealFood = null) {
        if (mealFood) {
            return this.selectedFood === mealFood;
        }
        return this.selectedFood;
    }

    openEdit(mealFood) {
        this.selectedFood = mealFood;
        this.closeAdd();
    }

    openAdd(el, a) {
        this.isAddOpen = true;
        this.selectedFood = null;
        this.initTypeahead();
    }

    closeAdd() {
        this.isAddOpen = false;
    }

    addMealFood() {
        this.closeAdd();
    }
}