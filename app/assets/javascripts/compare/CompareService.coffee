class CompareService

  @headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
  @defaultConfig = { headers: @headers }

  constructor: (@$log, @$http, @$q) ->
    @$log.debug "constructing CompareService"

  getPercent: () ->
    @$log.debug "CompareService.getPercent"
    deferred = @$q.defer()

    @$http.get("/compare/percent").success((data, status, headers) =>
      @$log.info("Successfully got data - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get data - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

  getNetIncome: () ->
    @$log.debug "CompareService.getNetIncome"
    deferred = @$q.defer()

    @$http.get("/compare/net-income").success((data, status, headers) =>
      @$log.info("Successfully got data - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get data - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

  getFIPercent: () ->
    @$log.debug "CompareService.getFIPercent"
    deferred = @$q.defer()

    @$http.get("/compare/fi/percent").success((data, status, headers) =>
      @$log.info("Successfully got percent - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get percent - status #{status}")
      deferred.reject(data)
    )

    deferred.promise

  getFISum: () ->
    @$log.debug "CompareService.getFISum"
    deferred = @$q.defer()

    @$http.get("/compare/fi/sum").success((data, status, headers) =>
      @$log.info("Successfully got sum - status #{status}")
      deferred.resolve(data)
    )
    .error((data, status, headers) =>
      @$log.error("Failed to get sum - status #{status}")
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

  getSVSum: () ->
    deferred = @$q.defer()
    @$http.get("/compare/sv/sum").success((data, status, headers) =>
      deferred.resolve(data)
    ).error((data, status, headers) =>
      deferred.reject(data)
    )
    deferred.promise

  getSVNetIncome: () ->
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
    
  getDEPercent: () ->
    deferred = @$q.defer()
    @$http.get("/compare/de/percent").success((data, status, headers) =>
      deferred.resolve(data)
    ).error((data, status, headers) =>
      deferred.reject(data)
    )
    deferred.promise
        
  getDESum: () ->
    deferred = @$q.defer()
    @$http.get("/compare/de/sum").success((data, status, headers) =>
      deferred.resolve(data)
    ).error((data, status, headers) =>
      deferred.reject(data)
    )
    deferred.promise
            
  getDENetIncome: () ->
    deferred = @$q.defer()
    @$http.get("/compare/de/net-income").success((data, status, headers) =>
      deferred.resolve(data)
    ).error((data, status, headers) =>
      deferred.reject(data)
    )
    deferred.promise          

servicesModule.service('CompareService', CompareService)