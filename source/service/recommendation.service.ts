import {Injectable} from 'angular2/core';
import {RECOMMENDATIONS} from './mock-recommendations';
import {NutrientService} from "./nutrient.service";

@Injectable()
export class RecommendationService {
    getRecommendations() {
        return Promise.resolve(RECOMMENDATIONS);
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