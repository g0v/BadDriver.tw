(function(){
  var cheatcodeDirective;
  cheatcodeDirective = function(){
    return {
      restrict: 'A',
      link: function(scope, elem, attr){
        elem.bind('keydown', function(e){
          switch (e.which) {
          case 38:
            return scope.$apply(function(){
              return scope.cCode.push(38);
            });
          case 40:
            return scope.$apply(function(){
              return scope.cCode.push(40);
            });
          case 37:
            return scope.$apply(function(){
              return scope.cCode.push(37);
            });
          case 39:
            return scope.$apply(function(){
              return scope.cCode.push(39);
            });
          case 66:
            return scope.$apply(function(){
              return scope.cCode.push(66);
            });
          case 65:
            scope.$apply(function(){
              return scope.cCode.push(65);
            });
            if (scope.cCode[0] === 38 && scope.cCode[1] === 38 && scope.cCode[2] === 40 && scope.cCode[3] === 40 && scope.cCode[4] === 37 && scope.cCode[5] === 39 && scope.cCode[6] === 37 && scope.cCode[7] === 39 && scope.cCode[8] === 66 && scope.cCode[9] === 65) {
              return scope.passCheatCode();
            } else {
              return scope.cCode.length = 0;
            }
            break;
          default:
            return scope.$apply(function(){
              return scope.cCode.length = 0;
            });
          }
        });
      }
    };
  };
  app.service('regtool', [].concat(function(){
    this.detect = function(v){
      return console.log(v);
    };
    this.trunumber = function(v){
      return v.replace(/\-|\s|\?/g, '').toUpperCase();
    };
  }));
  app.service('fb', ['$rootScope', '$localStorage', '$location', '$http'].concat(function($rootScope, $localStorage, $location, $http){
    this.login = function(path){
      if ($rootScope.fbid) {
        return $location.path('/' + path);
      } else {
        return FB.login(function(res){
          if (res.authResponse) {
            FB.api('/me', function(response){
              var fb_uid, fb_name, fb_email, data;
              console.log(response);
              fb_uid = response.id;
              fb_name = response.name;
              fb_email = response.email;
              $rootScope.$apply(function(){
                $localStorage.name = response.name;
                $rootScope.name = response.name;
                $rootScope.login = true;
                $rootScope.first_name = response.first_name;
                $rootScope.last_name = response.last_name;
              });
              data = {
                fb_name: response.name,
                thirdId: fb_uid,
                email: fb_email,
                thirdparty_type: 'fb'
              };
              $http.post('http://api.dont-throw.com/member/add', data).success(function(){
                if (path) {
                  return $location.path('/' + path);
                }
              });
              true;
            }, {
              scope: 'email,publish_actions'
            });
          }
          return false;
        });
      }
    };
  }));
  app.controller('indexCtrl', ['$scope', '$location', '$rootScope', '$localStorage', '$http', 'idata', '$sce', 'fb', 'regtool'].concat(function($scope, $location, $rootScope, $localStorage, $http, idata, $sce, fb, regtool){
    page.init();
    $http.defaults.useXDomain = true;
    $scope.idata = idata.data.data;
    $scope.urldata = [];
    $rootScope.snumber = [];
    $rootScope.number = [];
    angular.forEach(idata.data.data, function(v, i, o){
      var _tmp, _s;
      $rootScope.number.push(v.number);
      _tmp = v.number.split('');
      _tmp[2] = '_';
      _tmp[3] = '_';
      _s = _tmp.join().replace(/\,/g, '');
      $rootScope.snumber.push(_s);
      $scope.urldata.push('//www.youtube.com/embed/' + v.urlid);
      if (v.imgpool !== '') {
        return v.imgpool = JSON.parse(v.imgpool);
      }
    });
    $scope.urldata[0] = $sce.trustAsResourceUrl($scope.urldata[0]);
    $scope.urldata[1] = $sce.trustAsResourceUrl($scope.urldata[1]);
    $scope.urldata[2] = $sce.trustAsResourceUrl($scope.urldata[2]);
    $scope.urldata.push(idata.data.data.urlid);
    $scope.cCode = [];
    $scope.search = function(){
      var carnum;
      $scope.resultdata = [];
      $scope.clicksearch = true;
      carnum = regtool.trunumber($scope.carnumber);
      return $http({
        method: 'GET',
        url: 'http://api.dont-throw.com/data/search?number=' + carnum
      }).success(function(d){
        var _url;
        $scope.resaultnum = d.data.length;
        $scope.result = d.data;
        console.log(d.data);
        if (d.data.length !== 0 && d.data[0].from !== 'image') {
          $scope.noresult = false;
          _url = '//www.youtube.com/embed/' + d.data[0].urlid;
          $scope.resultdata[0] = $sce.trustAsResourceUrl(_url);
        } else {
          $scope.noresult = true;
          if (d.data[0].imgpool) {
            $scope.resultdata[0] = JSON.parse(d.data[0].imgpool)[0].u;
          }
        }
      });
    };
    $scope.goinfo = function(){
      return $location.path('/detail/' + $scope.result[0].id);
    };
    $scope.update = function(){
      return fb.login('update');
    };
  }));
  app.controller('detailCtrl', ['$scope', '$location', '$http', 'infodata', '$sce', '$localStorage', '$rootScope', '$stateParams', 'fb'].concat(function($scope, $location, $http, infodata, $sce, $localStorage, $rootScope, $stateParams, fb){
    var _url;
    page.init();
    infodata.data = infodata.data.data;
    $scope.dlist = [];
    $scope.dlist[0] = infodata.data.number;
    $scope.dcity = infodata.data.city;
    $scope.dlocation = infodata.data.location;
    $scope.dlike = infodata.data.like;
    $scope.ddislike = infodata.data.dislike;
    $scope.ddesp = infodata.data.description;
    $scope.dfrom = infodata.data.from;
    if (infodata.data.imgpool !== '') {
      $scope.dimgpool = JSON.parse(infodata.data.imgpool);
    }
    _url = '//www.youtube.com/embed/' + infodata.data.urlid;
    $scope.durldata = $sce.trustAsResourceUrl(_url);
    $scope.boat = [];
    $scope.delyear = [];
    $scope.small3 = [];
    $scope.update = function(){
      return fb.login('update');
    };
    $scope.dislikeit = function(){
      var votedata;
      if ($rootScope.fbid) {
        votedata = {
          tk: $rootScope.tk,
          id: $stateParams.id,
          userid: $rootScope.fbid
        };
        return $http.post('http://api.dont-throw.com/data/dislike', votedata).success(function(v){
          if (v.res === 'success') {
            return $scope.ddislike = Number($scope.ddislike) + 1;
          } else if (v.res === 'voted') {
            return alert('您已評比過！');
          }
        });
      } else {
        return FB.login(function(res){
          console.log(res);
          if (res.authResponse) {
            FB.api('/me', function(response){
              var fb_uid, fb_name, fb_email, data;
              console.log(response);
              fb_uid = response.id;
              fb_name = response.name;
              fb_email = response.email;
              $localStorage.name = response.name;
              $rootScope.name = response.name;
              $rootScope.login = true;
              $rootScope.first_name = response.first_name;
              $rootScope.last_name = response.last_name;
              data = {
                fb_name: response.name,
                thirdId: fb_uid,
                email: fb_email,
                thirdparty_type: 'fb'
              };
              $http.post('http://api.dont-throw.com/member/add', data).success(function(v){
                return FB.getLoginStatus(function(response){
                  var uid, accessToken, dataId, votedata;
                  if (response.status === 'connected') {
                    uid = response.authResponse.userID;
                    accessToken = response.authResponse.accessToken;
                    dataId = {
                      id: uid,
                      tk: accessToken
                    };
                    $http.post('http://api.dont-throw.com/member/update', dataId);
                    $rootScope.tk = accessToken;
                    $rootScope.fbid = response.authResponse.userID;
                    $rootScope.name = $localStorage.name;
                    votedata = {
                      tk: $rootScope.tk,
                      id: $stateParams.id,
                      userid: $rootScope.fbid
                    };
                    $http.post('http://api.dont-throw.com/data/dislike', votedata).success(function(v){
                      if (v.res === 'success') {
                        return $scope.ddislike = Number($scope.ddislike) + 1;
                      } else if (v.res === 'voted') {
                        return alert('您已評比過！');
                      }
                    });
                  } else {
                    $rootScope.fbid = undefined;
                    $rootScope.name = '請登入';
                  }
                });
              });
            }, {
              scope: 'email,publish_actions'
            });
          }
          return false;
        });
      }
    };
    $scope.highlight = function(){
      if (fb.login()) {
        if (infodata.data.from === 'image') {
          console.log(infodata.data.imgpool[0]);
          return FB.ui({
            method: 'feed',
            name: infodata.data.city + ' ' + infodata.data.location + ' 發現違規駕駛',
            link: 'http://baddriver.mobileweb.com.tw/#/detail/' + $stateParams.id,
            caption: '',
            picture: 'https://s3-us-west-2.amazonaws.com/baddriver/' + JSON.parse(infodata.data.imgpool)[0].u,
            description: infodata.data.description
          });
        } else {
          return FB.ui({
            method: 'feed',
            name: infodata.data.city + ' ' + infodata.data.location + ' 發現違規駕駛',
            link: 'http://baddriver.mobileweb.com.tw/#/detail/' + $stateParams.id,
            caption: '',
            description: infodata.data.description
          });
        }
      } else {
        return alert('請先登入!');
      }
    };
    $scope.addfunny = function(c){
      var _i, maxN, minN, n, info;
      _i = new Date();
      maxN = 280;
      minN = 0;
      n = Math.floor(Math.random() * (maxN - minN + 1)) + minN;
      info = {};
      switch (c) {
      case 'boat':
        info.time = _i;
        info.top = n;
        $scope.boat.push(info);
        break;
      case 'delyear':
        info.time = _i;
        info.top = n;
        $scope.delyear.push(info);
        break;
      case 'small3':
        info.time = _i;
        info.top = n;
        $scope.small3.push(info);
        break;
      }
    };
  }));
  app.controller('updateCtrl', ['$scope', '$location', '$http', '$rootScope', '$sce', '$fileUploader'].concat(function($scope, $location, $http, $rootScope, $sce, $fileUploader){
    var uploader;
    page.init();
    $http.defaults.useXDomain = true;
    $scope.nlist = [];
    $scope.addnum = function(){
      if ($scope.nlist.length === 0) {
        $scope.nlist.push($scope.inputnum);
        $scope.wantaddnumber = false;
        $scope.fullnum = true;
      }
    };
    $scope.send = function(){
      var _num, _picpool, data;
      if ($scope.nlist.length !== 0 && $scope.location && $scope.description && $scope.city) {
        _num = $scope.nlist[0].toString().replace(/\s/g, '').replace(/\-/g, '').toUpperCase();
        if ($scope.img && $scope.picPool.length === 0) {
          return alert('請先按上傳圖片！');
        } else {
          if ($scope.img) {
            $scope.url = 'none';
            _picpool = JSON.stringify($scope.picPool);
          } else {
            if ($scope.url) {
              alert('網址不可為空');
            }
          }
          data = {
            id: $rootScope.fbid,
            tk: $rootScope.tk,
            urlid: $scope.url,
            number: _num,
            city: $scope.city,
            location: $scope.location,
            description: $scope.description,
            imgpool: _picpool,
            fbid: $rootScope.fbid
          };
          return $http.post('http://api.dont-throw.com/data/add', data).success(function(v){
            if (v.res === 'success') {
              alert('感謝您，已貼文成功！');
              return $location.path('/');
            } else {
              return alert('Oops! 再試一次');
            }
          });
        }
      } else {
        if ($scope.nlist.length === 0) {
          alert('車牌號碼不可為空');
        }
        if (!$scope.location) {
          alert('地區不可為空');
        }
        if (!$scope.city) {
          alert('城市不可為空');
        }
        if (!$scope.description) {
          return alert('描述不可為空');
        }
      }
    };
    $scope.addnewbtn = function(){
      return $scope.wantaddnumber = !$scope.wantaddnumber;
    };
    $scope.checkurl = function(){
      var url, _tmp, _url;
      url = $scope.url;
      url = url.replace('https://www.youtube.com/watch?v=', '');
      url = url.replace('http://www.youtube.com/watch?v=', '');
      _tmp = url.split('&');
      console.log(_tmp);
      $scope.url = _tmp[0];
      $scope.change = true;
      _url = '//www.youtube.com/embed/' + _tmp[0];
      return $scope.urldata = $sce.trustAsResourceUrl(_url);
    };
    $scope.gosearchid = function(){
      return $http({
        method: 'GET',
        url: 'http://api.dont-throw.com/data/youtube?id=' + $scope.url
      }).success(function(d){
        if (d.res === 'success') {
          $scope.description = d.data.description;
        }
      });
    };
    $scope.img = false;
    $scope.u = false;
    uploader = $fileUploader.create({
      scope: $scope,
      url: 'http://api.dont-throw.com/data/upload/img',
      filters: [function(item){
        console.log('filter1');
        return true;
      }]
    });
    uploader.filters.push(function(item){
      console.log('filter2');
      return true;
    });
    $scope.picPool = [];
    $scope.changepic = function($index){
      console.log($index);
      return $scope.mainpic = $scope.picPool[$index].u;
    };
    uploader.bind('complete', function(event, xhr, item){
      var _x, _ym;
      _x = angular.fromJson(xhr.response);
      $scope.change = true;
      $scope.picPool.push({
        u: _x.n,
        m: 0
      });
      $scope.oi = false;
      $scope.mainpic = $scope.picPool[0].u;
      console.log($scope.picPool[0]);
      _ym = 0;
      angular.forEach($scope.picPool, function(v, i){
        var _ym;
        if (v.m === 1) {
          return _ym = 1;
        }
      });
      if (_ym === 0) {
        return $scope.picPool[0].m = 1;
      }
    });
    uploader.bind('completeall', function(event, items){
      $scope.oi = false;
    });
    $scope.uploader = uploader;
  }));
  app.directive('cheatCode', cheatcodeDirective);
}).call(this);
