import {Component, OnInit} from 'angular2/core';
import {Router} from "angular2/router";
import {RecommendationService} from "../service/recommendation.service";

@Component({
    selector: 'food',
    templateUrl: 'component/recommendation.component.html',
})

export class RecommendationComponent implements OnInit {
    recommendations;

    constructor(
        private _recommendationService: RecommendationService,
        private _router: Router
    ) { }

    getRecommendations() {
        this._recommendationService.getRecommendations().then(recommendatios => this.recommendations = recommendatios);
    }

    ngOnInit() {
        this.getRecommendations();
    }
}