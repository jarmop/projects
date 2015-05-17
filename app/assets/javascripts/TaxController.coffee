class TaxController
  constructor: (@$scope, @$log, @TaxService, PieModel) ->
    @$log.debug "constructing TaxController"
    @form = {
      salary: 30000,
      municipality: 'Helsinki',
      age: 30
    }

    @$scope.form = @form
    @$scope.municipalityOptions = ['Helsinki', 'Nivala']

    @pie = PieModel
    @$log.debug @$scope.firstTabActive
    @$scope.showBasic = true
    @$scope.showTax = false

    @getTax(@$scope.form)

  getTax: (form) ->
    @$log.debug "getTax()"
    @TaxService.getTax(form)
    .then((response) =>
      @$log.debug response
      @pie.createBasicPie(response.totalTax, @form.salary * 100, @openTaxPie)
      @pie.createTaxPie(response)
    ,(error) =>
      @$log.error "Unable to get Tax: #{error}"
    )


  updateView: (data) ->
    if @pie then @pie.destroy()
    ###content = [
      { label: "Vero", value: data.totalTax },
      { label: "Netto", value: @form.salary * 100 - data.governmentTax.tax - data.municipalityTax.tax},
    ]###

    content = [
      { label: "Valtion vero", value: data.governmentTax.tax },
      { label: "Kunnallisvero", value: data.municipalityTax.tax }
      { label: "YLE-vero", value: data.yleTax },
      { label: "Sairaanhoitomaksu", value: data.medicalCareInsurance },
      { label: "Päivärahamaksu", value: data.perDiemPayments },
      #{ label: "Netto", value: @form.salary * 100 - data.governmentTax.tax - data.municipalityTax.tax}
    ]

    @createPie(content, null)


  createPie: (content, onClickCallback) ->
    @pie = new d3pie("pie", {
      data: {
        content: content
      },
      misc: {
        pieCenterOffset: {
          y: -50
        }
      }
      size: {
        canvasWidth: 540
      }
      ###callbacks: {
        onClickSegment: onClickCallback
      }###
    });

  ###openTaxPie: (segment) =>
    @$log.debug segment.label
    if (segment.data.label == "Vero")
      @pie.destroy()
      @createPie(@subContent, null)###

  test: ->
    @$log.debug "testing"
    @$scope.showBasic = ! @$scope.showBasic
    @$scope.showTax = ! @$scope.showTax

  openTaxPie: (segment) =>
    @$log.debug this
    @$log.debug @$scope
    @$log.debug @$scope.showBasic
    if (!segment.expanded && segment.data.label == "Vero")
      @$log.debug @$scope.showBasic
      @test()
      @$scope.$apply()
      #@$scope.showBasic = false
      #@$scope.showTax = true

      #@$scope.tabs[1].active = true
      #@createPie(@subContent, null)




controllersModule.controller('TaxController', TaxController)

