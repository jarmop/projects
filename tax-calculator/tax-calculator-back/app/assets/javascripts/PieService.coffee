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
      { label: "Valtion vero", value: data.governmentTax.sum },
      { label: "Kunnallisvero", value: data.municipalityTax.sum }
      { label: "YLE-vero", value: data.YLETax.sum },
      { label: "Sairaanhoitomaksu", value: data.medicalCareInsurancePayment.sum },
      { label: "Päivärahamaksu", value: data.perDiemPayment.sum },
      { label: "Kirkollisvero", value: data.churchTax.sum },
      { label: "Työttömyysvakuutusmaksu", value: data.unemploymentInsurance.sum },
      { label: "Työeläkemaksu", value: data.pensionContribution.sum }
    ]

    @taxPie = @createPie('pie-tax', content, null)

  createPie: (id, content, onClickCallback) ->
    pie = new d3pie(id, {
      data: {
        content: content
      },
      size: {
        #canvasHeight: 300,
        #canvasWidth: 250,
        pieOuterRadius: "50%"
      }
      callbacks: {
        onClickSegment: onClickCallback
      }
    });

    return pie

#modelsModule.model('PieModel', PieModel)
servicesModule.service('PieService', PieService)