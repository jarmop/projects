import {Injectable, Inject} from 'angular2/core';
import {RECOMMENDATIONS} from '../mock/mock-recommendations';
import {NutrientService} from "../service/nutrient.service";
import {Adapter} from "../adapter/adapter";

@Injectable()
export class RecommendationService {
    constructor(
      @Inject('Adapter') private _adapter:Adapter
    ) {}
    
    getRecommendationsGroup(id: number) {
        return Promise.resolve(RECOMMENDATIONS).then(
            recommendationsGroup => recommendationsGroup.find(recommendationsData => recommendationsData.id === id)
        );
    }

    getRecommendations(id: string) {
        return this._adapter.getRecommendations(id);
    }
}