import {Component}       from 'angular2/core';
import {RouteConfig, ROUTER_DIRECTIVES, ROUTER_PROVIDERS} from 'angular2/router';

import {FoodComponent} from './food.component';
import {FoodService} from "../service/food.service";
import {MealService} from "../service/meal.service";
import {RecommendationComponent} from "./recommendation.component";
import {RecommendationService} from "../service/recommendation.service";
import {MealComponent} from "./meal.component";
import {NutrientService} from "../service/nutrient.service";

@Component({
    selector: 'app',
    templateUrl: 'component/app.component.html',
    directives: [ROUTER_DIRECTIVES],
    providers: [
        ROUTER_PROVIDERS,
        FoodService,
        RecommendationService,
        NutrientService,
        MealService
    ]
})

@RouteConfig([
    {
        path: '/meal',
        name: 'Meal',
        component: MealComponent,
        useAsDefault: true
    },
    {
        path: '/recommendation',
        name: 'Recommendation',
        component: RecommendationComponent
    },
    {
        path: '/food/:id',
        name: 'Food',
        component: FoodComponent
    }
])

export class AppComponent {
    title = 'Nutrient';
}
