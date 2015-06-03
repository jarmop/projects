class CompareService

  @headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
  @defaultConfig = { headers: @headers }

  constructor: (@$log, @$http, @$q) ->
    @$log.debug "constructing CompareService"

  getPercent: () ->
    @$log.debug "CompareService.getPercent"
    deferred = @$q.defer()

    @$http.get("/compare/percent").success((data, status, headers) =>
      @$log.info("Successfully got percent - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get percent - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

  getSum: () ->
    @$log.debug "CompareService.getSum"
    deferred = @$q.defer()

    @$http.get("/compare/sum").success((data, status, headers) =>
      @$log.info("Successfully got sum - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get sum - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

  getCountry: () ->
    @$log.debug "CompareService.getCountry"
    deferred = @$q.defer()

    @$http.get("/compare/country").success((data, status, headers) =>
      @$log.info("Successfully got country data - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get country data - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

  getSvPercent: () ->
    @$log.debug "CompareService.getSvPercent"
    deferred = @$q.defer()

    @$http.get("/compare/sv/percent").success((data, status, headers) =>
      @$log.info("Successfully got percent - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get percent - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

  getSvNetIncome: () ->
    @$log.debug "CompareService.getSvNetIncome"
    deferred = @$q.defer()

    @$http.get("/compare/sv/net-income").success((data, status, headers) =>
      @$log.info("Successfully got net income - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get net income - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

  getFINetIncome: () ->
    @$log.debug "CompareService.getFINetIncome"
    deferred = @$q.defer()

    @$http.get("/compare/fi/net-income").success((data, status, headers) =>
      @$log.info("Successfully got fi net income - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get fi net income - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

servicesModule.service('CompareService', CompareService)