(function() {
  angular.module('services').factory('socket', function(socketFactory, Host) {
    var myIoSocket, mySocket;
    myIoSocket = io.connect("" + (Host.getAPIHost()) + ":" + (Host.getAPIPort()) + "/hiin");
    mySocket = socketFactory({
      ioSocket: myIoSocket
    });
    return mySocket;
  });

}).call(this);
