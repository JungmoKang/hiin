'use strict'

angular.module("hiin").controller "grpChatCtrl", ($scope, $window, socket, Util,$location,$ionicScrollDelegate) ->
  console.log('grpChat')
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeAllListeners()
    return  
  $scope.imagePath = Util.serverUrl() + "/"
  myId = window.localStorage['myId']
  thisEvent = window.localStorage['thisEvent']
  messageKey = thisEvent + '_groupMessage'
  $scope.roomName = "GROUP CHAT"
  messages = window.localStorage[messageKey] || []
  if messages.length > 0
    $scope.messages = JSON.parse(messages)
  else
    $scope.messages = messages
  socket.on "groupMessage", (data) ->
    console.log "grp chat,groupMessage"
    whosMessage = ""
    if myId == data._id
      whosMessage = 'me'
    else
      whosMessage = data.fromName
    $scope.messages.push
      user: whosMessage
      text: data.message
      thumbnailUrl: data.thumbnailUrl
      regTime: data.regTime
      _id: data._id
    socket.emit "read",{
      msgId: data.msgId
      }
    window.localStorage[messageKey] = JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
    return
  $scope.sendMessage =->
    socket.emit "groupMessage",{
    	message: $scope.msg
      }
    $scope.msg = ""
angular.module("hiin").directive "ngChatBalloon", ($window)->
  link: (scope, element, attrs) ->
    console.log attrs.user
    if attrs.user == 'me'
      element.addClass 'chat-balloon-me'
    else
      element.addClass 'chat-balloon-you'
