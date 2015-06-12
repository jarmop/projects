class CompareController
  constructor: (@$scope, @$log, @CompareService) ->
    @$log.debug "constructing CompareController"

    @$scope.formatSum = () =>
      return (sum) =>
        return @formatCurrency(sum)

    @$scope.formatPercent = () =>
      return (percent) =>
        return @formatPercent(percent)

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

    @$scope.loadPercent = () =>
      @$scope.getFIPercent()
      @$scope.getSVPercent()
      @$scope.getDEPercent()

    @$scope.getFIPercent = () =>
      @CompareService.getFIPercent()
      .then((response) =>
        @$scope.fiPercentData = response
      )

    @$scope.getSVPercent = () =>
      @CompareService.getSvPercent()
      .then((response) =>
        @$scope.svPercentData = response
      )

    @$scope.getDEPercent = () =>
      @CompareService.getDEPercent()
      .then((response) =>
        @$scope.dePercentData = response
      )

    @$scope.loadNetIncome = () =>
      @$scope.getFINetIncome()
      @$scope.getSVNetIncome()
      @$scope.getDENetIncome()

    @$scope.getFINetIncome = () =>
      @CompareService.getFINetIncome()
        .then((response) =>
          @$scope.fiNetIncomeData = response
        )

    @$scope.getSVNetIncome = () =>
      @CompareService.getSVNetIncome()
        .then((response) =>
          @$scope.svNetIncomeData = response
        )

    @$scope.getDENetIncome = () =>
      @CompareService.getDENetIncome()
        .then((response) =>
          @$scope.deNetIncomeData = response
        )

    @$scope.loadSum = () =>
      @$scope.getFISum()
      @$scope.getSVSum()
      @$scope.getDESum()

    @$scope.getFISum = () =>
      @CompareService.getFISum()
        .then((response) =>
          @$scope.fiSumData = response
        )

    @$scope.getSVSum = () =>
      @CompareService.getSVSum()
        .then((response) =>
          @$scope.svSumData = response
        )

    @$scope.getDESum = () =>
      @CompareService.getDESum()
        .then((response) =>
          @$scope.deSumData = response
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

  formatCurrency: (currency) =>
        return parseFloat(currency).toFixed()

  formatPercent: (percent) =>
    return (percent * 100).toFixed(2).toString().replace(/0$|\.00$/, '').replace('.', ',')

controllersModule.controller('CompareController', CompareController)