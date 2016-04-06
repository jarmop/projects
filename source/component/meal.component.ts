import {Component, OnInit} from 'angular2/core';
import {RouteParams} from 'angular2/router';
// import {BarChartDemo} from './bar-chart.component';
// import {MealService} from '../service/meal.service';
// import {Meal} from "../model/meal";

declare var Chart: any;

@Component({
    selector: 'meal',
    templateUrl: 'component/meal.component.html',
})

export class MealComponent implements OnInit {
    // meal: Meal;

    constructor(
        // private _mealService: MealService,
        private _routeParams: RouteParams) {
    }

    ngOnInit() {
        // let id = +this._routeParams.get('id');
        // this._mealService.getMeal(id).then(meal => this.meal = meal);

        var randomScalingFactor = function(){ return Math.round(Math.random()*100)};
        var barChartData = {
            labels : ["January","February","March","April","May","June","July"],
            datasets : [
                {
                    fillColor : "rgba(220,220,220,0.5)",
                    strokeColor : "rgba(220,220,220,0.8)",
                    highlightFill: "rgba(220,220,220,0.75)",
                    highlightStroke: "rgba(220,220,220,1)",
                    data : [randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor()]
                },
                {
                    fillColor : "rgba(151,187,205,0.5)",
                    strokeColor : "rgba(151,187,205,0.8)",
                    highlightFill : "rgba(151,187,205,0.75)",
                    highlightStroke : "rgba(151,187,205,1)",
                    data : [randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor(),randomScalingFactor()]
                }
            ]
        }
        // window.onload = function(){
            // var ctx = document.getElementById("canvas").getContext("2d");

            var canvas : any = document.getElementById("canvas");
            var ctx = canvas.getContext("2d");

            var myBar = new Chart(ctx).Bar(barChartData, {
                responsive : true
            });
        // }
    }

    goBack() {
        window.history.back();
    }
}