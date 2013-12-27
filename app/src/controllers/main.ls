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

app.controller 'indexCtrl', <[$scope $location $rootScope $localStorage $http idata $sce]> ++ ($scope, $location, $rootScope, $localStorage, $http, idata, $sce) !->
		$http.defaults.useXDomain = true

		$scope.scale = ['section--video-list__item--left','section--video-list__item--middle','section--video-list__item--right']
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
		)

		$scope.urldata[0] = $sce.trustAsResourceUrl $scope.urldata[0]
		$scope.urldata[1] = $sce.trustAsResourceUrl $scope.urldata[1]
		$scope.urldata[2] = $sce.trustAsResourceUrl $scope.urldata[2]

		$scope.urldata.push idata.data.data.urlid 
		page.init()
		$http.defaults.useXDomain = true

		$scope.cCode = []
		$scope.search = ->
			$scope.resultdata = []
			$scope.clicksearch = true
			$http(
				method: 'GET'
				url: 'http://api.dont-throw.com/data/search?number='+$scope.carnumber
			).success((d)!->
				$scope.resaultnum = d.data.length 
				$scope.result = d.data
				if( d.data.length !=0)
					$scope.noresult = false
					$scope.resultdata[0] = $sce.trustAsResourceUrl '//www.youtube.com/embed/'+d.data.urlid
				else
					$scope.noresult =true
			)

		$scope.update = ->
			if ($rootScope.fbid)
				$location.path('/update')
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

								$rootScope.$apply( !->
									$localStorage.name = response.name
									$rootScope.name = response.name
									$rootScope.login = true
									$rootScope.first_name = response.first_name
									$rootScope.last_name = response.last_name
								)
								$location.path('/')
								const data = {
									fb_name:response.name
									thirdId:fb_uid
									email:fb_email
									thirdparty_type:'fb'
								}
								$http.post('http://api.dont-throw.com/member/add',data)
							scope : 'email,publish_actions'
						)
					false
				)
app.controller 'detailCtrl',<[$scope $location $http infodata]> ++ ($scope,$location,$http,infodata) !->
		
		$scope.dnum = infodata.data.number
		$scope.dcity = infodata.data.city
		$scope.dlocation = infodata.data.location
		$scope.dlike = infodata.data.like
		$scope.ddislike = infodata.data.dislike
		$scope.ddesp = infodata.data.description
		$scope.durl = infodata.data.url

app.controller 'updateCtrl', <[$scope $location $http $rootScope $sce]> ++ ($scope, $location, $http, $rootScope, $sce) !->
		$http.defaults.useXDomain = true
		$scope.nlist = []
		$scope.addnum = !->
			if($scope.nlist.length == 0)
				$scope.nlist.push($scope.inputnum)
				$scope.wantaddnumber = false
				$scope.fullnum = true	
		$scope.send= ->
			if($scope.nlist.length!= 0 && $scope.location && $scope.description && $scope.city && $scope.url )
				_num = $scope.nlist[0].toString().replace(/\s/g,'').replace(/\-/g,'').toUpperCase()
				
				const data = {
					id: $rootScope.fbid
					tk: $rootScope.tk
					urlid: $scope.url
					number: _num
					city: $scope.city
					location: $scope.location
					description: $scope.description
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
				if(!$scope.url)
					alert('網址不可為空')
				
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
			$scope.urldata = $sce.trustAsResourceUrl '//www.youtube.com/embed/'+_tmp[0]
		$scope.gosearchid = ->
			$http(
				method: 'GET'
				url: 'http://api.dont-throw.com/data/youtube?id='+$scope.url
			).success((d)!->
				if(d.res == 'success')
					$scope.description = d.data.description
			)
			console.log \123
app.directive 'cheatCode' cheatcodeDirective
