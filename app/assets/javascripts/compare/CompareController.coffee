class CompareController
  constructor: (@$scope, @$log, @CompareService) ->
    @$log.debug "constructing CompareControlleri"

    @getPercent()
    @getNetIncome()
    @getFIPercent()
    @getFISum()
    @getFINetIncome()
    @getSVPercent()
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

  getPercent: ->
    @$log.debug "getPercent"
    @CompareService.getPercent()
    .then((response) =>
      @$log.debug response
      @$scope.percentData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )

  getNetIncome: ->
    @$log.debug "getNetIncome"
    @CompareService.getNetIncome()
    .then((response) =>
      @$log.debug response
      @$scope.netIncomeData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )

  getFIPercent: ->
    @$log.debug "getFIPercent"
    @CompareService.getFIPercent()
    .then((response) =>
      @$log.debug response
      @$scope.fiPercentData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )

  getFISum: ->
    @$log.debug "getFISum"
    @CompareService.getFISum()
    .then((response) =>
      @$log.debug response
      @$scope.fiSumData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )

  getFINetIncome: ->
    @$log.debug "getFINetIncome"
    @CompareService.getFINetIncome()
    .then((response) =>
      @$log.debug response
      @$scope.fiNetIncomeData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )

  getSVPercent: ->
    @$log.debug "getSVPercent"
    @CompareService.getSvPercent()
    .then((response) =>
      @$log.debug response
      @$scope.svPercentData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )

  getSVNetIncome: ->
    @$log.debug "getSVNetIncome"
    @CompareService.getSvNetIncome()
    .then((response) =>
      @$log.debug response
      @$scope.svNetIncomeData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )

  formatCurrency: (currency) =>
    return parseFloat(currency).toFixed()

  formatPercent: (percent) =>
    return (percent * 100).toFixed(2).toString().replace(/0$|\.00$/, '').replace('.', ',')

controllersModule.controller('CompareController', CompareController)