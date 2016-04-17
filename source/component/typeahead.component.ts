import {Component, OnInit, NgZone} from 'angular2/core';
import {Router} from "angular2/router";
// import {RecommendationService} from "../service/recommendation.service";
// import {NutrientService} from "../service/nutrient.service";

declare var jQuery: any;
declare var typeahead: any;
// declare var Bloodhound: any;

@Component({
    selector: 'food',
    templateUrl: 'component/typeahead.component.html',
})

export class TypeaheadComponent implements OnInit {
    test = 'trhwrhjt';
    visible = true;
    states = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
        'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii',
        'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
        'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
        'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire',
        'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota',
        'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island',
        'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
        'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
    ];

    constructor(
        private _router: Router,
        private _ngZone: NgZone
    ) { }

    ngOnInit() {
        // console.log('oninit');
        // var engine = new Bloodhound({
        //     local: ['dog', 'pig', 'moose'],
        //     queryTokenizer: Bloodhound.tokenizers.whitespace,
        //     datumTokenizer: Bloodhound.tokenizers.whitespace
        // });

        // var jq = new jQuery;
        //
        // console.log(jq);
        // console.log(jq.select('#test').html());

        // console.log(jQuery('#test'));
        // console.log(jQuery('#test').html());
        // console.log(jq('#test'));

        this._ngZone.runOutsideAngular(() => {
            setTimeout(() => {
                // console.log(jQuery('#test'));
                console.log('woot');
                console.log(jQuery('#test').html());

                // var substringMatcher = function(strs) {
                //     return function findMatches(q, cb) {
                //         var matches, substringRegex;
                //
                //         // an array that will be populated with substring matches
                //         matches = [];
                //
                //         // regex used to determine if a string contains the substring `q`
                //         let substrRegex = new RegExp(q, 'i');
                //
                //         // iterate through the pool of strings and for any string that
                //         // contains the substring `q`, add it to the `matches` array
                //         jQuery.each(strs, function(i, str) {
                //             if (substrRegex.test(str)) {
                //                 matches.push(str);
                //             }
                //         });
                //
                //         cb(matches);
                //     };
                // };

                // var states = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
                //     'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii',
                //     'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
                //     'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
                //     'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire',
                //     'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota',
                //     'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island',
                //     'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
                //     'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
                // ];

                jQuery('#the-basics .typeahead').typeahead(
                    {
                        hint: true,
                        highlight: true,
                        minLength: 1
                    },
                    {
                        name: 'states',
                        source: this.substringMatcher(this.states)
                    }
                );
            }, 0);
        });
    }

    toggle() {
        this.visible = !this.visible;

        this._ngZone.runOutsideAngular(() => {
            setTimeout(() => {
                jQuery('#the-basics .typeahead').typeahead(
                    {
                        hint: true,
                        highlight: true,
                        minLength: 1
                    },
                    {
                        name: 'states',
                        source: this.substringMatcher(this.states)
                    }
                );
            }, 0);
        });

    }

    substringMatcher(strs) {
        return function findMatches(q, cb) {
            var matches, substringRegex;

            // an array that will be populated with substring matches
            matches = [];

            // regex used to determine if a string contains the substring `q`
            let substrRegex = new RegExp(q, 'i');

            // iterate through the pool of strings and for any string that
            // contains the substring `q`, add it to the `matches` array
            jQuery.each(strs, function(i, str) {
                if (substrRegex.test(str)) {
                    matches.push(str);
                }
            });

            cb(matches);
        }
    }
}