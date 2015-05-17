class PieService
  createBasicPie: (tax, salary, openClickCallback) ->
    if @basicPie then @basicPie.destroy()
    content = [
      { label: "Vero", value: tax },
      { label: "Netto", value: salary - tax},
    ]

    @basicPie = @createPie('pie-basic', content, openClickCallback)

  createTaxPie: (data) ->
    if @taxPie then @taxPie.destroy()

    content = [
      { label: "Valtion vero", value: data.governmentTax.tax },
      { label: "Kunnallisvero", value: data.municipalityTax.tax }
      { label: "YLE-vero", value: data.yleTax },
      { label: "Sairaanhoitomaksu", value: data.medicalCareInsurancePayment },
      { label: "Päivärahamaksu", value: data.perDiemPayments }
    ]

    @taxPie = @createPie('pie-tax', content, null)

  createPie: (id, content, onClickCallback) ->
    pie = new d3pie(id, {
      data: {
        content: content
      },
      misc: {
        pieCenterOffset: {
          y: -40
        }
      }
      size: {
        canvasHeight: 400,
        canvasWidth: 300,
        pieOuterRadius: "80%"
      }
      callbacks: {
        onClickSegment: onClickCallback
      }
    });

    return pie

#modelsModule.model('PieModel', PieModel)
servicesModule.service('PieService', PieService)