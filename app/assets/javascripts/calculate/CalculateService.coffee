class CalculateService

  @headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
  @defaultConfig = { headers: @headers }

  constructor: (@$log, @$http, @$q) ->
    @$log.debug "constructing CalculateService"

  getData: (countryCode, earnedIncome) ->
    @$log.debug "CalculateService.get " + countryCode
    deferred = @$q.defer()

    url = "/calculate/data/" + countryCode
    params = {earnedIncome: earnedIncome}



    @$http.get(url, {params: params}).success((data, status, headers) =>
      @$log.info("Successfully got data - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get data - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

servicesModule.service('CalculateService', CalculateService)