class CompareController
  constructor: (@$scope, @$log, @CompareService) ->
    @$log.debug "constructing CompareControlleri"

    @$scope.exampleData = [
      {
        key: "Series 1",
        values: [ [ 1000, 10],[ 2000, 20],[ 3000, 30],[ 4000, 20],[ 5000, 50],[ 6000, 10] ]
      },
      {
        key: "Series 2",
        values: [ [ 1000, 10],[ 2000, 20],[ 3000, 30],[ 4000, 20],[ 5000, 50],[ 6000, 10] ]
      },
    ]


controllersModule.controller('CompareController', CompareController)

