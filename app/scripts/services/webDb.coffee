angular.module('services').factory 'Migration', () ->
  truncate: (db) ->
    console.log("migration truncate!")
    db.transaction (tx) ->
      table_name = "message"
      tx.executeSql "DELETE FROM #{table_name}"

      #table_name = "chat_rooms"
      #tx.executeSql "DELETE FROM #{table_name}"

    , (error) ->
      console.error "Transaction error : #{error.message}"
  apply: (db) ->
    console.log "webDb.apply"

    db.transaction (tx) ->
      # create messages table
      table_name = "chatMessages"
      tx.executeSql "CREATE TABLE IF NOT EXISTS #{table_name} 
        (id unique, message, from_id, from_name, thumnailUrl,regTime,eventCoide,msgId)"

      # create chat_rooms table
      #table_name = "chat_rooms"
      #tx.executeSql "CREATE TABLE IF NOT EXISTS #{table_name}
        #(id unique, closed, ts, unread, json)"

      console.log "transaction function finished"
    , (error) ->
      console.error "Transaction error = #{error.message}"

