class CalculateController
  constructor: (@$scope, @$log, @CalculateService) ->
    @$log.debug "constructing CalculateController"
    @$log.debug @$scope.countryCode
    @$log.debug @$scope.earnedIncome
    @getData()
    @activeTaxNames = []

  getData: ->
    @CalculateService.getData(@$scope.countryCode, @$scope.earnedIncome).then((response) =>
      @$scope.data = response
    )

  isActive: (taxName) ->
    @activeTaxNames.indexOf(taxName) > -1

  toggleDescription: (taxName) ->
     if (@isActive(taxName))
       @activeTaxNames.splice(@activeTaxNames.indexOf(taxName), 1)
     else
       @activeTaxNames.push(taxName)

  getColor: (taxName) ->
    taxColors = ["red", "green", "blue"]
    return taxColors[0]

  formatCurrency: (currency) =>
        return parseFloat(currency).toFixed()

  formatPercent: (percent) =>
    return (percent * 100).toFixed(2).toString().replace(/0$|\.00$/, '').replace('.', ',')

controllersModule.controller('CalculateController', CalculateController)