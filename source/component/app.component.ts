import {Component, provide} from 'angular2/core';
import {RouteConfig, ROUTER_DIRECTIVES, ROUTER_PROVIDERS} from 'angular2/router';

import {FoodComponent} from './food.component';
import {FoodService} from "../service/food.service";
import {MealService} from "../service/meal.service";
import {RecommendationComponent} from "./recommendation.component";
import {RecommendationService} from "../service/recommendation.service";
import {MealComponent} from "./meal.component";
import {NutrientService} from "../service/nutrient.service";
import {FoodsComponent} from "./foods.component";
import {Mock} from "../adapter/mock";
import {Firebase} from "../adapter/firebase";
import {Adapter} from "../adapter/adapter";
import {Http, HTTP_PROVIDERS} from "angular2/http";

@Component({
    selector: 'app',
    templateUrl: 'component/app.component.html',
    directives: [ROUTER_DIRECTIVES],
    providers: [
        ROUTER_PROVIDERS,
        FoodService,
        RecommendationService,
        NutrientService,
        MealService,
        provide('Adapter', {useClass: Firebase}),
        Http,
        HTTP_PROVIDERS
    ]
})

@RouteConfig([
    {
        path: '/meal',
        name: 'Meal',
        component: MealComponent,
        // useAsDefault: true
    },
    {
        path: '/foods',
        name: 'Foods',
        component: FoodsComponent,
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
