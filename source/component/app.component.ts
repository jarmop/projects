import {Component}       from 'angular2/core';
import {RouteConfig, ROUTER_DIRECTIVES, ROUTER_PROVIDERS} from 'angular2/router';

import {FoodComponent} from './food.component';
import {FoodService} from "../service/food.service";
import {RecommendationsComponent} from "./recommendations.component";

@Component({
    selector: 'app',
    templateUrl: 'component/app.component.html',
    directives: [ROUTER_DIRECTIVES],
    providers: [
        ROUTER_PROVIDERS,
        FoodService
    ]
})

@RouteConfig([
    {
        path: '/recommendations',
        name: 'Recommendations',
        component: RecommendationsComponent,
        useAsDefault: true
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
