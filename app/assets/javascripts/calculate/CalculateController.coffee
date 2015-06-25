class CalculateController
  constructor: (@$scope, @$log, @CalculateService) ->
    @$log.debug "constructing CalculateController"


  getPercent: ->
    @CalculateService.getPercent().then((response) =>
      @$scope.percentData = response
    )

  getNetIncome: ->
    @CalculateService.getNetIncome().then((response) =>
      @$scope.netIncomeData = response
    )

  formatCurrency: (currency) =>
        return parseFloat(currency).toFixed()

  formatPercent: (percent) =>
    return (percent * 100).toFixed(2).toString().replace(/0$|\.00$/, '').replace('.', ',')

controllersModule.controller('CalculateController', CalculateController)