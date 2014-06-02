'use strict'

angular.module("hiin").controller "chatCtrl", ($scope, $window,socket, Util,$stateParams,$ionicScrollDelegate) ->
  console.log('chat')
  console.dir($stateParams)
  #로컬 스토레지에서 $routeParams.id 로 저장된 이력을 찾아서 뿌려줌. 없으면 생성..
  #근데 언제 그걸 갱신하지???
  #일단 메세지가 올때마다 갱신
  #향후 백버튼에서 갱신하도록 수정하자.
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeAllListeners()
    return  
  partnerId = $stateParams.userId
  thisEvent = window.localStorage['thisEvent']
  messageKey = thisEvent + '_' + partnerId
  messages = window.localStorage[messageKey] || []
  if messages.length > 0
    $scope.messages = JSON.parse(messages)
  else
    $scope.messages = messages
  #상대방의 정보 습득
  socket.emit "getUserInfo",{
      targetId: $stateParams.userId
    }
  socket.on "getUserInfo", (data) ->
    console.log "chat,getUserInfo"
    $scope.opponent = data
    $scope.partner = data.firstName
    $scope.roomName = "CHAT WITH " + data.firstName
  socket.on "message", (data) ->
    if data.status < 0
      return
    if data.from isnt $stateParams.userId
      return
    $scope.messages.push
      user: data.fromName
      text: data.message
      thumbnailUrl: data.thumbnailUrl
      regTime: data.regTime
      _id: data._id
    window.localStorage[messageKey] = JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
  $scope.sendMessage =->
  	socket.emit "message",{
  		targetId: $stateParams.userId
  		message: $scope.msg
  	}
    #내 사진은 표시 안
  	$scope.messages.push
        user: 'me'
        text: $scope.msg
    $scope.msg = "";
    window.localStorage[messageKey] = JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
  w = angular.element($window)
  $scope.getHeight = ->
    w.height()
  $scope.$watch $scope.getHeight, (newValue, oldValue) ->
    $scope.windowHeight = newValue
    $scope.style = ->
      height: newValue + "px"
    return
  w.bind "resize", ->
    $scope.$apply()
    return
  return
