class CompareController
  constructor: (@$scope, @$log, @CompareService) ->
    @$log.debug "constructing CompareControlleri"

    @getPercent()
    @getSum()
    @getCountry()
    @getSvPercent()

    @$scope.xAxisTickFormatPercent = () =>
      return (salary) =>
        return @formatCurrencyCents(salary)

    @$scope.yAxisTickFormatPercent = () =>
      return (percent) =>
        return @formatPercent(percent)

    @$scope.xAxisTickFormatSum = () =>
      return (salary) =>
        return @formatCurrencyCents(salary)

    @$scope.yAxisTickFormatSum = () =>
      return (sum) =>
        return @formatCurrencyCents(sum)

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

  getCountry: (form) ->
    @$log.debug "getCountry"
    @CompareService.getCountry()
    .then((response) =>
      @$log.debug response
      @$scope.countryData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )

  getSvPercent: (form) ->
    @$log.debug "getSvPercent"
    @CompareService.getSvPercent()
    .then((response) =>
      @$log.debug response
      @$scope.svPercentData = response
    ,(error) =>
      @$log.error "Unable to get data: #{error}"
    )

  formatCurrency: (currency) =>
    return parseFloat(currency).toFixed()

  formatCurrencyCents: (currency) =>
    return @formatCurrency(currency / 100)

  formatPercent: (percent) =>
    return (percent * 100).toFixed(2).toString().replace(/0$|\.00$/, '').replace('.', ',')

controllersModule.controller('CompareController', CompareController)