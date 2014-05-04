class App extends Backbone.Model
  initialize: ->
    # create player guess
    @set('playerGuess', new Board('Enemy')) #1
    # create enemy guess
    @set('enemyGuess', new Board('Enemy Guess'))
    # create enemy active
    #   fill 17 positions in the 'matrix'

    randomPositions = do @fillEnemyPosition
    @set('enemyPosition', new Board('Enemy Position', randomPositions))

    # create player active
    # alert('fill up 17 spots in your board')
    @set('playerPosition', new Board('You')) #2

    return

  fillEnemyPosition: ->
    count = 0
    positions = {}
    while count < 17
      x = Math.floor(Math.random() * 10)
      y = Math.floor(Math.random() * 10)
      position =
        x: x
        y: y
      if not positions[JSON.stringify position]
        positions[JSON.stringify position] = true
        count++
    positions

class AppView extends Backbone.View
  className: 'gameContainer'

  initialize: ->
    # console.log(@model.get('playerGuess'))
    @playerGuessView = new BoardView(model: @model.get('playerGuess'))
    @enemyGuessView = new BoardView(model: @model.get('playerPosition'))

    @model.get('playerGuess').on 'addPosition', =>
      playerPositions = @model.get('playerGuess').get('matrix')
      @model.get('enemyPosition').checkForMatch(playerPositions)

    @model.get('enemyPosition').on 'hit', =>
      row = @model.get('playerGuess').get('latest')[0] + 1
      column = @model.get('playerGuess').get('latest')[1] + 1
      $item = @playerGuessView.$el.find('table').find("tr:nth-child(#{row})").find("td:nth-child(#{column})")
      $item.addClass('green')

    @model.get('playerPosition').on 'addShip', =>
      count = @model.get('playerPosition').get('matrix').length
      debugger;
      # if count > 17
    do @render

  render: ->
    @$el
      .append @['playerGuessView'].render()
      .append @['enemyGuessView'].render()
      .html()

class Board extends Backbone.Model
  initialize: (name, matrix) ->
    @set('boardName', name)
    @set('matches', 0)
    @set('latest', null)
    if matrix
      @set('matrix', matrix)
    else
      @set('matrix', {})

  attack: (row, column) ->
    key = '{"x":' + column + ',"y":' + row + '}'
    if not @get('matrix')[key]
      @get('matrix')[key] = true
      @set('latest', [row, column])
    @trigger 'addPosition', @

  addShip: (row, column) ->
    key = '{"x":' + column + ',"y":' + row + '}'
    if not @get('matrix')[key]
      @get('matrix')[key] = true
      # @set('shipCount', @get('shipCount') + 1)
      @trigger 'addShip', @

  checkForMatch: (matrix) ->
    matches = _.intersection( Object.keys(@get('matrix')), Object.keys(matrix) )
    if matches.length > @get('matches')
      @set('matches', matches.length)
      @trigger 'hit', @

class BoardView extends Backbone.View
  className: 'boardContainer'

  template: _.template($('#boardTemplate').html())

  initialize: ->
    # do @render

  render: ->
    # debugger;
    @$el.html(@template(@model.toJSON()))

  events:
    'click td': (e) ->
      rowIndex = $(e.currentTarget).parent().index()
      columnIndex = $(e.currentTarget).index()
      if(@model.get('boardName') is 'Enemy')
        @model.attack(rowIndex, columnIndex)
        $(e.currentTarget).toggleClass('black')
      else
        @model.addShip(rowIndex, columnIndex)
        $(e.currentTarget).toggleClass('white')
        # debugger;


new AppView(model: new App()).$el.appendTo 'body'
