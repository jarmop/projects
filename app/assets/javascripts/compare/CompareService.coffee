class CompareService

  @headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
  @defaultConfig = { headers: @headers }

  constructor: (@$log, @$http, @$q) ->
    @$log.debug "constructing CompareService"

  getData: (type, country="") ->
    @$log.debug "CompareService.get" + type + country
    deferred = @$q.defer()

    url = "/compare/data"
    if (type == "netIncome")
      type = "net-income"
    url += "/" + type
    if (country.length > 0)
      url += "/" + country

    @$http.get(url).success((data, status, headers) =>
      @$log.info("Successfully got data - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get data - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

  getPercent: () ->
    @getData("percent")

  getNetIncome: () ->
    @getData("net-income")

  getFIPercent: () ->
    @getData("percent", "fi")

  getFISum: () ->
    @getData("sum", "fi")

  getFINetIncome: () ->
    @getData("net-income", "fi")

  getSvPercent: () ->
    @getData("percent", "sv")

  getSVSum: () ->
    @getData("sum", "sv")

  getSVNetIncome: () ->
    @getData("net-income", "sv")
    
  getDEPercent: () ->
    @getData("percent", "de")
        
  getDESum: () ->
    @getData("sum", "de")
            
  getDENetIncome: () ->
    @getData("net-income", "de")

servicesModule.service('CompareService', CompareService)