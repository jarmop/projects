class CompareController
  constructor: (@$scope, @$log, @CompareService) ->
    @$log.debug "constructing CompareControlleri"

    @getData()

  getData: (form) ->
    @$log.debug "getData"
    @CompareService.getData()
    .then((response) =>
      @$log.debug response
      @$scope.exampleData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )


controllersModule.controller('CompareController', CompareController)

