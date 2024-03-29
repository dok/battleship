###
Author: Sean Dokko
App model controls game logic
App view event handlers triggers when game status changes

Board model controls the matrix
###

class App extends Backbone.Model
  initialize: ->
    @set('playerGuess', new Board('Enemy', {})) #First board
    @set('enemyGuess', new Board('Enemy Guess', {}))
    @set('enemyPosition', new Board('Enemy Position'))
    @set('playerPosition', new Board('You', {})) #Second board
    @set('gameOver', false);
    return

class AppView extends Backbone.View
  className: 'gameContainer'

  initialize: ->
    @playerGuessView = new BoardView(model: @model.get('playerGuess'))
    @enemyGuessView = new BoardView(model: @model.get('playerPosition'))

    @model.get('playerGuess').on 'addPosition', =>
      playerPositions = @model.get('playerGuess').get('matrix')
      @model.get('enemyPosition').checkForMatch(playerPositions)

    @model.get('playerGuess').on 'attackPlayer', =>
      row = Math.floor(Math.random() * 10) + 1
      column = Math.floor(Math.random() * 10) + 1
      player = @model.get('playerPosition')
      playerMatrix = player.get('matrix')
      key = @model.get('playerPosition').getKey(row, column)
      if playerMatrix[key]
        player.set('points', player.get('points') + 1)
        if player.get('points') is 17
          @gameOver()
        $item = @getSquare @enemyGuessView, row, column
        $item.addClass('red')

    @model.get('enemyPosition').on 'hit', => # When player scores a point
      enemy = @model.get('enemyPosition')
      enemy.set('points', enemy.get('points') + 1)
      if enemy.get('points') is 17 # If we score all possible points
        @gameOver()

      row = @model.get('playerGuess').get('latest')[0]
      column = @model.get('playerGuess').get('latest')[1]
      $item = @getSquare @playerGuessView, row, column
      $item.addClass('green')

    @model.get('playerPosition').on 'addShip', => # When player adds a ship
      count = Object.keys(@model.get('playerPosition').get('matrix')).length
      if count is 17
        @model.get('playerPosition').set('setAllPieces', true) # Player and enemy is ready
        @model.get('playerGuess').set('setAllPieces', true)

    do @render

  gameOver: ->
    alert('gameOver')

  getSquare: (view, row, column) ->
    view.$el.find('table').find("tr:nth-child(#{row})").find("td:nth-child(#{column})")

  render: ->
    @$el
      .append @['playerGuessView'].render()
      .append @['enemyGuessView'].render()
      .html()

class Board extends Backbone.Model
  initialize: (name, matrix) ->
    @set('setAllPieces', false)
    @set('boardName', name)
    @set('matches', 0)
    @set('latest', null)
    @set('points', 0)
    if !matrix
      @set('matrix', do @fillEnemyPosition)
    else
      @set('matrix', matrix)

  attack: (row, column) ->
    key = @getKey(row, column)
    if not @get('matrix')[key]
      @get('matrix')[key] = true
      @set('latest', [row, column])
    @trigger 'addPosition', @
    @trigger 'attackPlayer', @

  addShip: (row, column) ->
    key = @getKey(row, column)
    if not @get('matrix')[key]
      @get('matrix')[key] = true
      @trigger 'addShip', @

  checkForMatch: (matrix) ->
    matches = _.intersection( Object.keys(@get('matrix')), Object.keys(matrix) )
    if matches.length > @get('matches')
      @set('matches', matches.length)
      @trigger 'hit', @

  getKey: (row, column) ->
    '{"column":' + column + ',"row":' + row + '}'

  # Returns random 'ship' positions
  fillEnemyPosition: ->
    count = 0
    ships = [2,3,3,4,5]
    positions = {}

    hasSpace = (shipLength, direction, row, column) ->
      switch(direction)
        when 0 #up
          for i in [0..shipLength-1]
            position = 
              column: column
              row: row - i
            if positions[JSON.stringify position]
              return false
        when 1 #right
          for i in [0..shipLength-1]
              position = 
                column: column + i
                row: row
              if positions[JSON.stringify position]
                return false
        when 2 #down
          for i in [0..shipLength-1]
                position = 
                  column: column
                  row: row + i 
                if positions[JSON.stringify position]
                  return false
        when 3 #left
          for i in [0..shipLength-1]
                position = 
                  column: column - i
                  row: row
                if positions[JSON.stringify position]
                  return false
      return true

    #10 x 10 starting with 1
    #when there is enough space and when the ship doesnt overlap a previous one
    canAdd = (shipLength, direction, row, column) ->
      switch(direction)
        when 0 #up
          if row - shipLength >= 0 and hasSpace(shipLength, direction, row, column)
            return true
        when 1 #right
          if column + shipLength <= 10 and hasSpace(shipLength, direction, row, column)
            return true
        when 2 #down
          if row + shipLength <= 10 and hasSpace(shipLength, direction, row, column)
            return true
        when 3 #left
          if column - shipLength >= 0 and hasSpace(shipLength, direction, row, column)
            return true
      false

    while count < 5
      shipLength = ships[count]
      direction = Math.floor(Math.random() * 4)
      row = Math.floor(Math.random() * 10) + 1
      column = Math.floor(Math.random() * 10) + 1
      if canAdd(shipLength, direction, row, column)
        switch(direction)
          when 0
            for i in [0..shipLength - 1]
              position = 
                column: column
                row: row - i
              positions[JSON.stringify position] = true
          when 1
            for i in [0..shipLength - 1]
              position = 
                column: column + i
                row: row 
              positions[JSON.stringify position] = true
          when 2
            for i in [0..shipLength - 1]
              position = 
                column: column
                row: row + i
              positions[JSON.stringify position] = true
          when 3
            for i in [0..shipLength - 1]
              position = 
                column: column - i
                row: row
              positions[JSON.stringify position] = true
        count++
    positions

class BoardView extends Backbone.View
  className: 'boardContainer'

  template: _.template($('#boardTemplate').html())

  initialize: ->

  render: ->
    @$el.html(@template(@model.toJSON()))

  events:
    'click td': (e) ->
      rowIndex = $(e.currentTarget).parent().index() + 1
      columnIndex = $(e.currentTarget).index() + 1
      if(@model.get('boardName') is 'Enemy')
        if @model.get('setAllPieces')
          @model.attack(rowIndex, columnIndex)
          $(e.currentTarget).addClass('black')
        else
          alert('you need to set all your pieces!')
      else
        if not @model.get('setAllPieces')
          @model.addShip(rowIndex, columnIndex)
          $(e.currentTarget).addClass('white')
        else
          alert("you've set all your pieces!")


new AppView(model: new App()).$el.appendTo 'body'
