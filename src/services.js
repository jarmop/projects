var taxServices = angular.module('taxServices', ['ngResource']);

taxServices.factory('Tax', ['$resource',
    function($resource){
        return $resource('//localhost:9000/calculate/data/:countryCode', {}, {
            query: {method:'GET', params:{countryCode:'de', earnedIncome:30000}}
        });
    }
]);