class TaxController
  constructor: (@$scope, @$log, @TaxService, PieService) ->
    @$log.debug "constructing TaxController"
    @form = {
      salary: 17000,
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
      @pie.createBasicPie(response.totalTax, @form.salary, @openTaxPie)
      @pie.createTaxPie(response)
      @updateReport(response)
    ,(error) =>
      @$log.error "Unable to get Tax: #{error}"
    )

  updateReport: (data) ->
    @$scope.salary = @formatCurrency(@form.salary)
    @$scope.commonDeduction = {}
    $.each(data.commonDeduction, (key, value) =>
      @$scope.commonDeduction[key] = @formatCurrency(value)
    )
    governmentTaxHits = []
    $.each(data.governmentTax.hits, (key, value) =>
      governmentTaxHits.push({
        maxSalary: value.maxSalary,
        taxPercent: @formatPercent(value.taxPercent)
        tax: @formatCurrency(value.tax),
        taxedSalary: @formatCurrency(value.taxedSalary),
        minSalary: value.minSalary,
      })
    )
    @$scope.governmentTax = {
      deduction: @formatCurrency(data.governmentTax.deduction),
      deductedSalary: @formatCurrency(data.governmentTax.deductedSalary),
      sum: @formatCurrency(data.governmentTax.sum),
      hits: governmentTaxHits
    }
    @$scope.municipalityTax = {
      earnedIncomeAllowance: @formatCurrency(data.municipalityTax.earnedIncomeAllowance),
      basicDeduction: @formatCurrency(data.municipalityTax.basicDeduction),
      totalDeduction: @formatCurrency(data.municipalityTax.totalDeduction),
      deductedSalary: @formatCurrency(data.municipalityTax.deductedSalary),
      sum: @formatCurrency(data.municipalityTax.sum)
    }
    @$scope.medicalCareInsurancePayment = {
      percent: @formatPercent(data.medicalCareInsurancePayment.percent),
      sum: @formatCurrency(data.medicalCareInsurancePayment.sum)
    }
    @$scope.perDiemPayment = {
      percent: @formatPercent(data.perDiemPayment.percent),
      sum: @formatCurrency(data.perDiemPayment.sum)
    }
    @$scope.pensionContribution = {
      tyel53Percent: @formatPercent(data.pensionContribution.tyel53Percent),
      tyelSub53Percent: @formatPercent(data.pensionContribution.tyelSub53Percent),
      percent: @formatPercent(data.pensionContribution.percent),
      sum: @formatCurrency(data.perDiemPayment.sum)
    }
    @$scope.unemploymentInsurance = {
      percent: @formatPercent(data.unemploymentInsurance.percent),
      sum: @formatCurrency(data.unemploymentInsurance.sum)
    }
    @$scope.churchTax = {
      percent: @formatPercent(data.churchTax.percent),
      sum: @formatCurrency(data.churchTax.sum)
    }
    @$scope.YLETax = {
      percent: @formatPercent(data.YLETax.percent),
      sum: @formatCurrency(data.YLETax.sum)
    }
    @$scope.totalTax = @formatCurrency(data.totalTax)
    @$scope.taxPercentage = @formatPercent(data.totalTax / @form.salary)
    @$scope.workIncomeDeduction = @formatCurrency(data.workIncomeDeduction)

  formatCurrency: (currency) ->
    return parseFloat(currency).toFixed(2).toString().replace('.', ',')

  formatPercent: (percent) ->
    return (percent * 100).toFixed(2).toString().replace(/0$|\.00$/, '').replace('.', ',')

controllersModule.controller('TaxController', TaxController)

