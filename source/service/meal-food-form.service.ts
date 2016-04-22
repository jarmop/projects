import {Injectable} from 'angular2/core';

declare var Bloodhound:any;

@Injectable()
export class MealFoodFormService {
    private bloodhound;
    private foods = ['banaani','porkkana','puuro','peruna','papu'];

    constructor() {
        this.bloodhound = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.whitespace,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            local: this.foods
        });
    }

    getTypeaheadSource() {
        return this.bloodhound;
    }
}