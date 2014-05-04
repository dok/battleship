// Generated by CoffeeScript 1.7.1

/*
Author: Sean Dokko
App model controls game logic
App view event handlers triggers when game status changes

Board model controls the matrix
 */

(function() {
  var App, AppView, Board, BoardView,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  App = (function(_super) {
    __extends(App, _super);

    function App() {
      return App.__super__.constructor.apply(this, arguments);
    }

    App.prototype.initialize = function() {
      var randomPositions;
      this.set('playerGuess', new Board('Enemy'));
      this.set('enemyGuess', new Board('Enemy Guess'));
      randomPositions = this.fillEnemyPosition();
      this.set('enemyPosition', new Board('Enemy Position', randomPositions));
      this.set('playerPosition', new Board('You'));
    };

    App.prototype.fillEnemyPosition = function() {
      var count, position, positions, x, y;
      count = 0;
      positions = {};
      while (count < 17) {
        x = Math.floor(Math.random() * 10) + 1;
        y = Math.floor(Math.random() * 10) + 1;
        position = {
          x: x,
          y: y
        };
        if (!positions[JSON.stringify(position)]) {
          positions[JSON.stringify(position)] = true;
          count++;
        }
      }
      return positions;
    };

    return App;

  })(Backbone.Model);

  AppView = (function(_super) {
    __extends(AppView, _super);

    function AppView() {
      return AppView.__super__.constructor.apply(this, arguments);
    }

    AppView.prototype.className = 'gameContainer';

    AppView.prototype.initialize = function() {
      this.playerGuessView = new BoardView({
        model: this.model.get('playerGuess')
      });
      this.enemyGuessView = new BoardView({
        model: this.model.get('playerPosition')
      });
      this.model.get('playerGuess').on('addPosition', (function(_this) {
        return function() {
          var playerPositions;
          playerPositions = _this.model.get('playerGuess').get('matrix');
          return _this.model.get('enemyPosition').checkForMatch(playerPositions);
        };
      })(this));
      this.model.get('playerGuess').on('attackPlayer', (function(_this) {
        return function() {
          var $item, column, key, playerMatrix, row;
          row = Math.floor(Math.random() * 10) + 1;
          column = Math.floor(Math.random() * 10) + 1;
          playerMatrix = _this.model.get('playerPosition').get('matrix');
          key = _this.model.get('playerPosition').getKey(x, y);
          if (playerMatrix[key]) {
            $item = _this.getSquare(_this.enemyGuessView, row, column);
            return $item.addClass('red');
          }
        };
      })(this));
      this.model.get('enemyPosition').on('hit', (function(_this) {
        return function() {
          var $item, column, row;
          row = _this.model.get('playerGuess').get('latest')[0];
          column = _this.model.get('playerGuess').get('latest')[1];
          $item = _this.getSquare(_this.playerGuessView, row, column);
          return $item.addClass('green');
        };
      })(this));
      this.model.get('playerPosition').on('addShip', (function(_this) {
        return function() {
          var count;
          count = Object.keys(_this.model.get('playerPosition').get('matrix')).length;
          if (count === 17) {
            _this.model.get('playerPosition').set('setAllPieces', true);
            return _this.model.get('playerGuess').set('setAllPieces', true);
          }
        };
      })(this));
      return this.render();
    };

    AppView.prototype.getSquare = function(view, row, column) {
      return view.$el.find('table').find("tr:nth-child(" + row + ")").find("td:nth-child(" + column + ")");
    };

    AppView.prototype.render = function() {
      return this.$el.append(this['playerGuessView'].render()).append(this['enemyGuessView'].render()).html();
    };

    return AppView;

  })(Backbone.View);

  Board = (function(_super) {
    __extends(Board, _super);

    function Board() {
      return Board.__super__.constructor.apply(this, arguments);
    }

    Board.prototype.initialize = function(name, matrix) {
      this.set('setAllPieces', false);
      this.set('boardName', name);
      this.set('matches', 0);
      this.set('latest', null);
      if (matrix) {
        return this.set('matrix', matrix);
      } else {
        return this.set('matrix', {});
      }
    };

    Board.prototype.attack = function(row, column) {
      var key;
      key = this.getKey(row, column);
      if (!this.get('matrix')[key]) {
        this.get('matrix')[key] = true;
        this.set('latest', [row, column]);
      }
      this.trigger('addPosition', this);
      return this.trigger('attackPlayer', this);
    };

    Board.prototype.addShip = function(row, column) {
      var key;
      key = this.getKey(row, column);
      if (!this.get('matrix')[key]) {
        this.get('matrix')[key] = true;
        return this.trigger('addShip', this);
      }
    };

    Board.prototype.checkForMatch = function(matrix) {
      var matches;
      matches = _.intersection(Object.keys(this.get('matrix')), Object.keys(matrix));
      if (matches.length > this.get('matches')) {
        this.set('matches', matches.length);
        return this.trigger('hit', this);
      }
    };

    Board.prototype.getKey = function(row, column) {
      return '{"x":' + column + ',"y":' + row + '}';
    };

    return Board;

  })(Backbone.Model);

  BoardView = (function(_super) {
    __extends(BoardView, _super);

    function BoardView() {
      return BoardView.__super__.constructor.apply(this, arguments);
    }

    BoardView.prototype.className = 'boardContainer';

    BoardView.prototype.template = _.template($('#boardTemplate').html());

    BoardView.prototype.initialize = function() {};

    BoardView.prototype.render = function() {
      return this.$el.html(this.template(this.model.toJSON()));
    };

    BoardView.prototype.events = {
      'click td': function(e) {
        var columnIndex, rowIndex;
        rowIndex = $(e.currentTarget).parent().index() + 1;
        columnIndex = $(e.currentTarget).index() + 1;
        if (this.model.get('boardName') === 'Enemy') {
          if (this.model.get('setAllPieces')) {
            this.model.attack(rowIndex, columnIndex);
            return $(e.currentTarget).toggleClass('black');
          } else {
            return alert('you need to set all your pieces!');
          }
        } else {
          if (!this.model.get('setAllPieces')) {
            this.model.addShip(rowIndex, columnIndex);
            return $(e.currentTarget).addClass('white');
          } else {
            return alert("you've set all your pieces!");
          }
        }
      }
    };

    return BoardView;

  })(Backbone.View);

  new AppView({
    model: new App()
  }).$el.appendTo('body');

}).call(this);
