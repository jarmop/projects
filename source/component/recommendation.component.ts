import {Component, OnInit} from 'angular2/core';
import {Router} from "angular2/router";
import {RecommendationService} from "../service/recommendation.service";
import {NutrientService} from "../service/nutrient.service";

@Component({
    selector: 'food',
    templateUrl: 'component/recommendation.component.html',
})

export class RecommendationComponent implements OnInit {
    recommendationGroups;

    constructor(
        private _recommendationService: RecommendationService,
        private _nutrientService: NutrientService,
        private _router: Router
    ) { }

    getRecommendations() {
        this._recommendationService.getRecommendations().then(recommendations => {
            this.recommendationGroups = [
                {
                    'name': 'Vitamiinit',
                    'recommendations': recommendations.filter(recommendation => this._nutrientService.vitaminIds.indexOf(recommendation.nutrientId) != -1)
                },
                {
                    'name': 'Kivennäis- ja hivenaineet',
                    'recommendations': recommendations.filter(recommendation => this._nutrientService.dietaryElementIds.indexOf(recommendation.nutrientId) != -1)
                },
            ];
        });
    }

    ngOnInit() {
        this.getRecommendations();
    }
}