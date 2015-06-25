class CalculateController
  constructor: (@$scope, @$log, @CalculateService) ->
    @$log.debug "constructing CalculateController"
    @$log.debug @$scope.countryCode
    @$log.debug @$scope.earnedIncome
    @getData()

  getData: ->
    @CalculateService.getData(@$scope.countryCode, @$scope.earnedIncome).then((response) =>
      @$scope.data = response
    )

  formatCurrency: (currency) =>
        return parseFloat(currency).toFixed()

  formatPercent: (percent) =>
    return (percent * 100).toFixed(2).toString().replace(/0$|\.00$/, '').replace('.', ',')

controllersModule.controller('CalculateController', CalculateController)