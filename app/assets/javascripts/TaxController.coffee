class TaxController
  constructor: (@$scope, @$log, @TaxService, PieService) ->
    @$log.debug "constructing TaxController"
    @form = {
      salary: 30000,
      municipality: 'Helsinki',
      age: 30
    }

    @$scope.form = @form
    @$scope.municipalityOptions = ['Helsinki', 'Nivala']

    @pie = PieService

    @getTax(@$scope.form)

  getTax: (form) ->
    @$log.debug "getTax()"
    @TaxService.getTax(form)
    .then((response) =>
      @$log.debug response
      @pie.createBasicPie(response.totalTax, @form.salary * 100, @openTaxPie)
      @pie.createTaxPie(response)
      @updateReport(response)
    ,(error) =>
      @$log.error "Unable to get Tax: #{error}"
    )

  updateReport: (data) ->
    @$log.debug data.commonDeduction.incomeDeduction
    @$scope.commonDeduction = {}
    $.each(data.commonDeduction, (key, value) =>
      @$scope.commonDeduction[key] = @formatCurrency(value)
    )
    perDiemPayment = { sum: @formatCurrency(data.perDiemPayments) }
    @$scope.perDiemPayment = perDiemPayment

  formatCurrency: (currency) ->
    return (currency / 100).toFixed(2).toString().replace('.', ',')

controllersModule.controller('TaxController', TaxController)

