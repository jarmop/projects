class CompareController
  constructor: (@$scope, @$log, @CompareService) ->
    @$log.debug "constructing CompareControlleri"

    @getPercent()
    @getSum()

  getPercent: (form) ->
    @$log.debug "getPercent"
    @CompareService.getPercent()
    .then((response) =>
      @$log.debug response
      @$scope.percentData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )

  getSum: (form) ->
    @$log.debug "getSum"
    @CompareService.getSum()
    .then((response) =>
      @$log.debug response
      @$scope.sumData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )

controllersModule.controller('CompareController', CompareController)

