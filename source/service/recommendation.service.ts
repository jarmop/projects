import {Injectable} from 'angular2/core';
import {RECOMMENDATIONS} from '../mock/mock-recommendations';
import {NutrientService} from "../service/nutrient.service";

@Injectable()
export class RecommendationService {
    getRecommendationsGroup(id: number) {
        return Promise.resolve(RECOMMENDATIONS).then(
            recommendationsGroup => recommendationsGroup.find(recommendationsData => recommendationsData.id === id)
        );
    }

    getRecommendations(id: number) {
        return Promise.resolve(RECOMMENDATIONS).then(
            recommendationsGroup => recommendationsGroup.find(recommendationsData => recommendationsData.id === id).recommendations
        );
    }

    getRecommendationVitamins(recommendations) {
        let nutrientService = new NutrientService();
        return recommendations.filter(nutrient => nutrientService.vitaminIds.indexOf(nutrient.nutrientId) != -1);
    }

    getRecommendationDietaryElements(recommendations) {
        let nutrientService = new NutrientService();
        return recommendations.filter(nutrient => nutrientService.dietaryElementIds.indexOf(nutrient.nutrientId) != -1);
    }
}