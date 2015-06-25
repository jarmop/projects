class CalculateService

  @headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
  @defaultConfig = { headers: @headers }

  constructor: (@$log, @$http, @$q) ->
    @$log.debug "constructing CalculateService"

  getData: (type, country="") ->
    @$log.debug "CalculateService.get" + type + country
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

servicesModule.service('CalculateService', CalculateService)