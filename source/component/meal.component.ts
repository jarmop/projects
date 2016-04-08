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
    nutritionShares: any;

    constructor(
        private _recommendationService: RecommendationService,
        private _foodService: FoodService,
        private _routeParams: RouteParams) {
    }

    ngOnInit() {
        // this._mealService.getMeal(id).then(meal => this.meal = meal);
        this._recommendationService.getRecommendations().then(recommendations => {
            this._foodService.getFood(1).then(food => {
                let nutritionShares = {
                    'vitamins': [],
                    'dietaryElements': []
                };

                let nutrientti = food.vitamins.find(nutrient => nutrient.nutrientId === 1);

                for (let recommendation of recommendations.vitamins) {
                    let nutrient = food.vitamins.find(nutrient => nutrient.nutrientId === recommendation.nutrientId);
                    let nutritionShare = {
                        'name': recommendation.name,
                        'male': recommendation.male,
                        'runit': recommendation.unit,
                        'max': recommendation.max,
                        'amount': 0,
                        'funit': 'N/A',
                        'percent': {
                            'ok': 0,
                            'over': 0,
                            'tooMuch': 0,
                        },
                    };
                    if (nutrient) {
                        nutritionShare.amount = nutrient.value;
                        nutritionShare.funit = nutrient.unit;
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
                    nutritionShares.vitamins.push(nutritionShare);
                }

                for (let recommendation of recommendations.dietaryElements) {
                    let nutrient = food.dietaryElements.find(nutrient => nutrient.nutrientId === recommendation.nutrientId);
                    let nutritionShare = {
                        'name': recommendation.name,
                        'male': recommendation.male,
                        'runit': recommendation.unit,
                        'max': recommendation.max,
                        'amount': 0,
                        'funit': 'N/A',
                    };
                    if (nutrient) {
                        nutritionShare.amount = nutrient.value;
                        nutritionShare.funit = nutrient.unit;
                    }
                    nutritionShares.dietaryElements.push(nutritionShare);
                }
                this.nutritionShares = nutritionShares;
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
}