class App extends Backbone.Model
  initialize: ->
    # create player guess
    @set('playerGuess', {})
    # create enemy guess
    @set('enemyGuess', {})
    # create enemy active
    #   fill 17 positions in the 'matrix'

    @set('enemyPosition', @fillEnemyPosition())
    console.log(@get('enemyPosition'))

    # create player active
    # alert('fill up 17 spots in your board')
    @set('playerPosition', {})

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

class BoardView extends Backbone.View
  template: _.template($('#boardTemplate').html())

  initialize: ->
    # do @render

  render: ->
    @$el.html(@template())

  events:
    'click td': (e) ->
      rowIndex = $(e.currentTarget).parent().index()
      columnIndex = $(e.currentTarget).index()
      $(e.currentTarget).toggleClass('red')
      # positionOnBoard = $('pla')

class AppView extends Backbone.View
  className: 'gameContainer'

  initialize: ->
    # console.log(@model.get('playerGuess'))
    @playerGuessView = new BoardView(model: @model.get('playerGuess'))
    @enemyGuessView = new BoardView(model: @model.get('enemyGuess'))
    do @render

  render: ->
    @$el
      .append @['playerGuessView'].render()
      .append @['enemyGuessView'].render()
      .html()


new AppView(model: new App()).$el.appendTo 'body'
