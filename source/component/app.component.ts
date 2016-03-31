import {Component}       from 'angular2/core';
import {RouteConfig, ROUTER_DIRECTIVES, ROUTER_PROVIDERS} from 'angular2/router';

// import {MealComponent} from './meal.component';
import {FoodComponent} from './food.component';
import {FoodService} from "../service/food.service";

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
        path: '/food/:id',
        name: 'Food',
        component: FoodComponent,
        // useAsDefault: true
    },
])

export class AppComponent {
    title = 'Nutrientti';
}
