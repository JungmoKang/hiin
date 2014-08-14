angular.module('hiin').controller 'NoticeCtrl', ($rootScope,$filter,$scope,SocketClass, Util,$window,socket,$state,$modal,$ionicNavBarDelegate,$stateParams,$ionicScrollDelegate) ->  
  console.log 'grpChat'
  #init
  $scope.data = {}
  $scope.owner = {}
  $rootScope.noticeFlg = false
  if $window.localStorage?
    eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
    thisEvent = eventInfo.code
    $scope.myInfo = JSON.parse($window.localStorage.getItem 'myInfo')
    console.log $scope.myInfo
    if eventInfo.author == $scope.myInfo._id
      $scope.amIOwner = true
      $scope.owner = $scope.myInfo
    else
      $scope.amIOwner = false
      listKey = thisEvent + '_currentEventUserList'
      tempList = $window.localStorage.getItem listKey
      $scope.owner = $filter('getUserById')(JSON.parse(tempList), eventInfo.author)
  #
  $scope.ShowProfile = (sender) ->
    user = $scope.owner
    if user is null
      return
    console.log user
    $scope.user = user
    modalInstance = $modal.open(
      templateUrl: "views/dialog/user_card.html"
      scope: $scope
    )
    modalInstance.result.then ((selectedItem) ->
      $scope.modalInstance = null
      return
    ), ->
      $scope.modalInstance = null
      return
    $scope.modalInstance = modalInstance
  $scope.DialogClose = ->
    $scope.modalInstance.close()
  MakeNoticeListOptionObj = ->
    socketNotice = new SocketClass.socketClass('allNotice',null,0,true)
    socketNotice.onCallback = (data) ->
      $scope.messages = data
      $ionicScrollDelegate.scrollBottom true
      console.log data
    return socketNotice
  SendEmitCurrentEventUserList = ->
    SocketClass.resSocket(MakeNoticeListOptionObj())
      .then (data) ->
        console.log ' got notice list'
      , (status) ->
        console.log "error"
    return
  $scope.ScrollToBottom = ->
    $ionicScrollDelegate.scrollBottom()
  SendEmitCurrentEventUserList()
  notice = (data) ->
    console.log data
    data.created_at = data.regTime
    $scope.messages.push data
    if $scope.bottom is false
      $scope.newMsg = data
      $scope.newMsg.msg = Util.trimStr(data.content, 30)
    else
      $ionicScrollDelegate.scrollBottom()
  socket.on "notice", notice
  $scope.sendMessage = ->
    time = new Date()
    if $scope.data.message == ""
      return
    socket.emit "notice",{
      created_at: time
      message: $scope.data.message
    }
    $scope.data.message = ""
  window.addEventListener "native.keyboardshow", (e) ->
    console.log "Keyboard height is: " + e.keyboardHeight
    if document.activeElement.tagName is "BODY"
      cordova.plugins.Keyboard.close()
      return
    window.scroll(0,0)
    $scope.data.keyboardHeight = e.keyboardHeight
    $timeout (->
      $ionicScrollDelegate.scrollBottom true
      return
    ), 200
    return
  window.addEventListener "native.keyboardhide", (e) ->
    console.log "Keyboard close"
    $scope.data.keyboardHeight = 0
    $ionicScrollDelegate.resize()
    return
  ionic.DomUtil.ready ->
    console.log 'ready'
    if window.cordova
      cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
    #스크롤 이벤트 등록
    $scope.bottom = true
    $scope.scrollDelegate = $ionicScrollDelegate.$getByHandle('myScroll')
    $scope.scrollDelegate.getScrollView().onScroll = ->
      if ($scope.scrollDelegate.getScrollView().__maxScrollTop - $scope.scrollDelegate.getScrollPosition().top) < 30
        $scope.bottom = true
        if $scope.newMsg isnt null 
          $scope.newMsg = null
          $ionicScrollDelegate.scrollBottom()
      else
        $scope.bottom = false
  $scope.$on "$destroy", (event) ->
    if window.cordova
      cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(false) && cordova.plugins.Keyboard.close()