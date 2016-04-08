import {Component, OnInit} from 'angular2/core';
import {RouteParams} from 'angular2/router';
// import {BarChartDemo} from './bar-chart.component';
import {RecommendationService} from '../service/recommendation.service';
import {FoodService} from '../service/food.service';

declare var Chart: any;

@Component({
    selector: 'meal',
    templateUrl: 'component/meal.component.html',
})

export class MealComponent implements OnInit {
    meal: any;
    nutritionShares = [];

    constructor(
        private _recommendationService: RecommendationService,
        private _foodService: FoodService,
        private _routeParams: RouteParams) {
    }

    ngOnInit() {
        // this._mealService.getMeal(id).then(meal => this.meal = meal);
        this._recommendationService.getRecommendations().then(recommendations => {
            this._foodService.getFood(1).then(food => {
                let nutritionShare = {
                    'name': '',
                    'nutrients': []
                };
                for (let recommendation of recommendations.vitamins) {
                    nutritionShare.name = 'Vitamiinit';
                    nutritionShare.nutrients.push(this.getNutritionShare(food.vitamins, recommendation));
                }
                console.log(nutritionShare.nutrients);
                this.nutritionShares.push(nutritionShare);
                nutritionShare = {
                    'name': '',
                    'nutrients': []
                };
                for (let recommendation of recommendations.dietaryElements) {
                    nutritionShare.name = 'Kivennäis- ja hivenaineet';
                    nutritionShare.nutrients.push(this.getNutritionShare(food.dietaryElements, recommendation));
                }
                this.nutritionShares.push(nutritionShare);
            });
        });
        this.meal = {
          'foods': [
              {
                  'name': 'Soijapapu',
                  'amount': 100
              }
          ]
        };
    }

    goBack() {
        window.history.back();
    }

    private getNutritionShare(nutrients, recommendation) {
        let nutrient = nutrients.find(nutrient => nutrient.nutrientId === recommendation.nutrientId);
        let nutritionShare = {
            'name': recommendation.name,
            'male': recommendation.male,
            'max': recommendation.max,
            'amount': 0,
            'unit': recommendation.unit,
            'percent': {
                'ok': 0,
                'over': 0,
                'tooMuch': 0,
            },
        };

        if (nutrient) {
            nutritionShare.amount = nutrient.value;
            nutritionShare.unit = nutrient.unit;
            this.calculatePercent(nutritionShare, nutrient, recommendation);
        }

        return nutritionShare;
    }

    private calculatePercent(nutritionShare, nutrient, recommendation) {
        nutritionShare.percent.ok = nutrient.value / recommendation.male * 100;
        if (nutrient.value > recommendation.male) {
            nutritionShare.percent.ok = recommendation.male / nutrient.value * 100;
            let over = nutrient.value - recommendation.male;
            if (nutrient.value > recommendation.max) {
                let tooMuch = nutrient.value - recommendation.max;
                over -= nutritionShare.percent.tooMuch;
                nutritionShare.percent.tooMuch = tooMuch / nutrient.value * 100;
            }
            nutritionShare.percent.over = over / nutrient.value * 100;
        }
    }
}