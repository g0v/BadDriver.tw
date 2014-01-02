const cheatcodeDirective = ->
  restrict: 'A'
  link: !(scope,elem,attr) ->
    elem.bind('keydown',(e)->
      switch(e.which)
      case 38 then
        scope.$apply(->
          scope.cCode.push(38)
        )
      case 40
        scope.$apply(->
          scope.cCode.push(40)
        )
      case 37
        scope.$apply(->
          scope.cCode.push(37)
        )
      case 39
        scope.$apply(->
          scope.cCode.push(39)
        )
      case 66 then
        scope.$apply(->
          scope.cCode.push(66)
        )
      case 65 then
        scope.$apply(->
          scope.cCode.push(65)
        )
        if scope.cCode[0] == 38 && scope.cCode[1] == 38 && scope.cCode[2] == 40 && scope.cCode[3] == 40 && scope.cCode[4] == 37 && scope.cCode[5] == 39 && scope.cCode[6] == 37 && scope.cCode[7] == 39 && scope.cCode[8] == 66 && scope.cCode[9] == 65
          scope.passCheatCode()
        else
          scope.cCode.length = 0
      default
        scope.$apply(->
          scope.cCode.length = 0
        )
    )
app.service 'regtool', <[]> ++  !->
  @detect = (v)->
    console.log(v)
  @trunumber = (v) ->
    v.replace(/\-|\s|\?/g,'').toUpperCase()
app.service 'fb', <[$rootScope $localStorage $location $http]> ++  ($rootScope, $localStorage,$location,$http)!->
  @login = (path)->
    if ($rootScope.fbid)
      $location.path('/'+path)
    else
      FB.login((res) ->
        if(res.authResponse)
          FB.api('/me'
            (response) !->
              console.log(response)
              fb_uid = response.id
              fb_name = response.name
              fb_email = response.email

              $rootScope.$apply( !->
                $localStorage.name = response.name
                $rootScope.name = response.name
                $rootScope.login = true
                $rootScope.first_name = response.first_name
                $rootScope.last_name = response.last_name
              )
              const data = {
                fb_name:response.name
                thirdId:fb_uid
                email:fb_email
                thirdparty_type:'fb'
              }
              $http.post('http://api.dont-throw.com/member/add',data).success(->
                if(path)
                  $location.path('/'+path)
              )
              true
            scope : 'email,publish_actions'
          )
        false
      )

app.controller 'indexCtrl', <[$scope $location $rootScope $localStorage $http idata $sce fb regtool]> ++ ($scope, $location, $rootScope, $localStorage, $http, idata, $sce, fb, regtool) !->
  page.init()
  $http.defaults.useXDomain = true

  $scope.idata = idata.data.data
  $scope.urldata = []
  $rootScope.snumber = []
  $rootScope.number = []
  angular.forEach(idata.data.data,(v,i,o)->
    $rootScope.number.push v.number
    _tmp = v.number.split ''
    _tmp[2] = '_'
    _tmp[3] = '_'
    _s = _tmp.join().replace /\,/g,''
    $rootScope.snumber.push _s
    $scope.urldata.push '//www.youtube.com/embed/'+v.urlid
    v.imgpool = JSON.parse(v.imgpool)
  )

  $scope.urldata[0] = $sce.trustAsResourceUrl $scope.urldata[0]
  $scope.urldata[1] = $sce.trustAsResourceUrl $scope.urldata[1]
  $scope.urldata[2] = $sce.trustAsResourceUrl $scope.urldata[2]
  # console.log(idata.data.data)
  $scope.urldata.push idata.data.data.urlid 

  $scope.cCode = []
  $scope.search = ->
    $scope.resultdata = []
    $scope.clicksearch = true
    carnum = regtool.trunumber($scope.carnumber) 
    $http(
      method: 'GET'
      url: 'http://api.dont-throw.com/data/search?number='+carnum
    ).success((d)!->
      $scope.resaultnum = d.data.length 
      $scope.result = d.data
      console.log d.data

      if( d.data.length !=0 && d.data[0].from != 'image')
        $scope.noresult = false
        _url = '//www.youtube.com/embed/'+d.data[0].urlid
        $scope.resultdata[0] = $sce.trustAsResourceUrl _url
      else
        $scope.noresult =true
        if(d.data[0].imgpool)
          $scope.resultdata[0] = JSON.parse(d.data[0].imgpool)[0].u
    )
  $scope.goinfo = ->
    # console.log($scope.result[])
    $location.path('/detail/'+$scope.result[0].id)
  $scope.update = ->
    fb.login('update')
    
app.controller 'detailCtrl', <[$scope $location $http infodata $sce $localStorage $rootScope $stateParams fb]> ++ ($scope, $location, $http, infodata, $sce, $localStorage, $rootScope, $stateParams, fb) !->
    page.init()
    infodata.data = infodata.data.data
    $scope.dlist = []
    $scope.dlist[0] = infodata.data.number
    $scope.dcity = infodata.data.city
    $scope.dlocation = infodata.data.location
    $scope.dlike = infodata.data.like
    $scope.ddislike = infodata.data.dislike
    $scope.ddesp = infodata.data.description
    $scope.dfrom = infodata.data.from
    $scope.dimgpool = JSON.parse infodata.data.imgpool
    _url = '//www.youtube.com/embed/'+infodata.data.urlid
    $scope.durldata = $sce.trustAsResourceUrl _url
    $scope.boat= []
    $scope.delyear = []
    $scope.small3 = []
    $scope.update = ->
      fb.login('update')
    $scope.dislikeit = ->
      if ($rootScope.fbid)
        const votedata ={
        tk:$rootScope.tk
        id:$stateParams.id
        userid:$rootScope.fbid
        }
        $http.post('http://api.dont-throw.com/data/dislike',votedata).success(
          (v)->
            if v.res == \success
              $scope.ddislike = Number($scope.ddislike) + 1
            else if v.res == \voted
              alert('您已評比過！')
        )
      else
        FB.login((res) ->
          console.log(res)
          if(res.authResponse)
            FB.api('/me'
              (response) !->
                console.log(response)
                fb_uid = response.id
                fb_name = response.name
                fb_email = response.email

                $localStorage.name = response.name
                $rootScope.name = response.name
                $rootScope.login = true
                $rootScope.first_name = response.first_name
                $rootScope.last_name = response.last_name
              
                const data = {
                  fb_name:response.name
                  thirdId:fb_uid
                  email:fb_email
                  thirdparty_type:'fb'
                }
                $http.post('http://api.dont-throw.com/member/add',data).success(
                  (v)->
                    FB.getLoginStatus((response) !->
                      if (response.status == 'connected')
                        uid = response.authResponse.userID
                        accessToken = response.authResponse.accessToken
                        const dataId ={
                          id:uid
                          tk:accessToken
                        }
                        $http.post 'http://api.dont-throw.com/member/update', dataId
                
                        $rootScope.tk = accessToken
                        $rootScope.fbid = response.authResponse.userID
                        $rootScope.name = $localStorage.name
                      
                        const votedata ={
                          tk:$rootScope.tk
                          id:$stateParams.id
                          userid:$rootScope.fbid
                        }
                        $http.post('http://api.dont-throw.com/data/dislike',votedata).success(
                          (v)->
                            if v.res == \success
                              $scope.ddislike = Number($scope.ddislike) + 1
                            else if v.res == \voted
                              alert('您已評比過！')
                        )
                      else
                        $rootScope.fbid = undefined
                        $rootScope.name = '請登入'
                        
                    )
                )
              scope : 'email,publish_actions'
            )
          false
        )
    $scope.highlight = ->
      if(fb.login())
        if infodata.data.from == 'image'
          console.log(infodata.data.imgpool[0])
          FB.ui(
            method:'feed'
            name: infodata.data.city+' '+infodata.data.location+' 發現違規駕駛'
            link: 'http://baddriver.mobileweb.com.tw/#/detail/'+$stateParams.id
            caption: ''
            picture: 'https://s3-us-west-2.amazonaws.com/baddriver/'+JSON.parse(infodata.data.imgpool)[0].u
            description: infodata.data.description
          )
        else
          FB.ui(
            method:'feed'
            name: infodata.data.city+' '+infodata.data.location+' 發現違規駕駛'
            link: 'http://baddriver.mobileweb.com.tw/#/detail/'+$stateParams.id
            caption: ''
            description: infodata.data.description
          )
      else
        alert('請先登入!')
    $scope.addfunny = (c)->
      _i = new Date()
      maxN = 280
      minN = 0
      n = Math.floor(Math.random() * (maxN - minN + 1)) + minN
      info = {}
      switch(c)
      case \boat
        info.time = _i
        info.top = n
        $scope.boat.push(info)
        break
      case \delyear
        info.time = _i
        info.top = n
        $scope.delyear.push(info)
        break
      case \small3
        info.time = _i
        info.top = n
        $scope.small3.push(info)
        break

app.controller 'updateCtrl', <[$scope $location $http $rootScope $sce $fileUploader]> ++ ($scope, $location, $http, $rootScope, $sce, $fileUploader) !->
    page.init()
    $http.defaults.useXDomain = true
    $scope.nlist = []
    $scope.addnum = !->
      if($scope.nlist.length == 0)
        $scope.nlist.push($scope.inputnum)
        $scope.wantaddnumber = false
        $scope.fullnum = true 
    $scope.send= ->
      if($scope.nlist.length!= 0 && $scope.location && $scope.description && $scope.city )
        _num = $scope.nlist[0].toString().replace(/\s/g,'').replace(/\-/g,'').toUpperCase()
        if($scope.img && $scope.picPool.length == 0)
          alert('請先按上傳圖片！')
        else     
          if($scope.img)  
            $scope.url = 'none'
            _picpool = JSON.stringify($scope.picPool)
          else
            if($scope.url)
              alert('網址不可為空')
          const data = {
            id: $rootScope.fbid
            tk: $rootScope.tk
            urlid: $scope.url
            number: _num
            city: $scope.city
            location: $scope.location
            description: $scope.description
            imgpool:_picpool
            fbid:$rootScope.fbid
          }
          $http.post('http://api.dont-throw.com/data/add',data).success((v)->
            if(v.res == 'success')
              alert('感謝您，已貼文成功！')
              $location.path('/')
            else
              alert('Oops! 再試一次')
          )
      else
        if($scope.nlist.length == 0)
          alert('車牌號碼不可為空')
        if(!$scope.location)
          alert('地區不可為空')
        if(!$scope.city)
          alert('城市不可為空')
        if(!$scope.description)
          alert('描述不可為空')
        
    $scope.addnewbtn = ->
      $scope.wantaddnumber = !$scope.wantaddnumber
    $scope.checkurl = ->
      url = $scope.url
      url = url.replace('https://www.youtube.com/watch?v=','')
      url = url.replace('http://www.youtube.com/watch?v=','')
      _tmp = url.split('&')
      console.log _tmp
      $scope.url = _tmp[0]
      $scope.change = true
      _url = '//www.youtube.com/embed/'+_tmp[0]
      $scope.urldata = $sce.trustAsResourceUrl _url
    $scope.gosearchid = ->
      $http(
        method: 'GET'
        url: 'http://api.dont-throw.com/data/youtube?id='+$scope.url
      ).success((d)!->
        if(d.res == 'success')
          $scope.description = d.data.description
      )
    $scope.img = false
    $scope.u = false
    uploader = $fileUploader.create(
      scope: $scope                      
      url: 'http://api.dont-throw.com/data/upload/img'
      filters: [ 
        (item) ->  
          console.log( 'filter1' )
          true
      ]
    )
    uploader.filters.push((item) ->  
      console.log( 'filter2' )
      true
    )
    $scope.picPool = []
    $scope.changepic = ($index)->
      console.log($index)
      $scope.mainpic = $scope.picPool[$index].u
    uploader.bind( 'complete', ( event, xhr, item)-> 
      # console.log( 'Complete: ' + xhr.response )
      _x = angular.fromJson(xhr.response)
      $scope.change = true
      $scope.picPool.push({u:_x.n,m:0})
      $scope.oi = false
      $scope.mainpic = $scope.picPool[0].u
      console.log($scope.picPool[0])
      _ym = 0
      angular.forEach($scope.picPool,(v,i)->
        if v.m == 1 
          _ym = 1
      )
      if _ym == 0
        $scope.picPool[0].m = 1
    )
    uploader.bind('completeall',( event, items) !->
      $scope.oi = false; 
    )
    $scope.uploader = uploader;
app.directive 'cheatCode' cheatcodeDirective
