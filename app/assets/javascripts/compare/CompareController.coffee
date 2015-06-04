class CompareController
  constructor: (@$scope, @$log, @CompareService) ->
    @$log.debug "constructing CompareControlleri"

    @getPercent()
    @getNetIncome()
    @getFIPercent()
    @getFISum()
    @getFINetIncome()
    @getSVPercent()
    @getSVSum()
    @getSVNetIncome()

    @$scope.xAxisTickFormatPercent = () =>
      return (salary) =>
        return @formatCurrency(salary)

    @$scope.yAxisTickFormatPercent = () =>
      return (percent) =>
        return @formatPercent(percent)

    @$scope.xAxisTickFormatSum = () =>
      return (salary) =>
        return @formatCurrency(salary)

    @$scope.yAxisTickFormatSum = () =>
      return (sum) =>
        return @formatCurrency(sum)

  getSVSum: ->
    @CompareService.getSVSum()
    .then((response) =>
      @$scope.svSumData = response
    )

  getPercent: ->
    @CompareService.getPercent()
    .then((response) =>
      @$scope.percentData = response
    )

  getNetIncome: ->
    @CompareService.getNetIncome()
    .then((response) =>
      @$scope.netIncomeData = response
    )

  getFIPercent: ->
    @CompareService.getFIPercent()
    .then((response) =>
      @$scope.fiPercentData = response
    )

  getFISum: ->
    @CompareService.getFISum()
    .then((response) =>
      @$scope.fiSumData = response
    )

  getFINetIncome: ->
    @CompareService.getFINetIncome()
    .then((response) =>
      @$scope.fiNetIncomeData = response
    )

  getSVPercent: ->
    @CompareService.getSvPercent()
    .then((response) =>
      @$scope.svPercentData = response
    )

  getSVNetIncome: ->
    @CompareService.getSvNetIncome()
    .then((response) =>
      @$scope.svNetIncomeData = response
    )

  formatCurrency: (currency) =>
    return parseFloat(currency).toFixed()

  formatPercent: (percent) =>
    return (percent * 100).toFixed(2).toString().replace(/0$|\.00$/, '').replace('.', ',')

controllersModule.controller('CompareController', CompareController)