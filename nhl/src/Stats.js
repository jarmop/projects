import React, {Component} from 'react';
import {getStats, getImageUrl, getGameUrl} from './service';

const playerData = [
  {
    id: 8479339,
    name: 'Patrik Laine',
  },
  {
    id: 8479344,
    name: 'Jesse Puljujärvi',
  },
  {
    id: 8477493,
    name: 'Aleksander Barkov',
  },
  {
    id: 8478427,
    name: 'Sebastian Aho',
  },
  {
    id: 8476882,
    name: 'Teuvo Teräväinen',
  },
  {
    id: 8478420,
    name: 'Mikko Rantanen',
  },
  {
    id: 8469638,
    name: 'Jussi Jokinen',
  },
  {
    id: 8475798,
    name: 'Mikael Granlund',
  },
  {
    id: 8469459,
    name: 'Mikko Koivu',
  },
  {
    id: 8476469,
    name: 'Joel Armia',
  },
  {
    id: 8475287,
    name: 'Erik Haula',
  },
  {
    id: 8475820,
    name: 'Joonas Donskoi',
  },
  {
    id: 8470047,
    name: 'Valtteri Filppula',
  },
];

// Array of player ids
let playerIds = playerData.map(player => player.id);

// Player data mapped to player ids
let players = {};
playerData.map(player => players[player.id] = {name: player.name});

// eslint-disable-next-line
const mockStats = [
  {
    playerId: 8479339,
    goals: 1,
    assists: 0,
    timeOnIce: '16:31',
  },
  {
    playerId: 8477493,
    goals: 0,
    assists: 2,
    timeOnIce: '15:36',
  },
];

class Stats extends Component {
  constructor(props) {
    super(props);
    this.state = {
      statsReady: false,
      stats: [],
      // statsReady: true,
      // stats: mockStats,
    };
  }

  componentDidMount() {
    if (this.state.stats.length === 0) {
      getStats(playerIds).then(stats => {
        this.setState({
          statsReady: true,
          stats: stats,
        });
      });
    }
  }

  render() {
    let {statsReady, stats} = this.state;

    if (statsReady) {
      if (stats.length > 0) {
        return (
            stats.map(({playerId, goals, assists, gamePk}) =>
                <div key={playerId} className="card-container">
                  <a href={getGameUrl(gamePk)} className="player-link" target="_blank">
                    <div className="card">
                      <div className="card__player">
                        <img
                            src={getImageUrl(playerId)}
                            className="card__headshot"
                            alt={players[playerId].name}
                            title={players[playerId].name}
                        />
                      </div>
                      <div className="card__points">
                        {goals + ' + ' + assists}
                      </div>
                    </div>
                  </a>
                </div>,
            )
        );
      }
      else {
        return (
            <span>:(</span>
        );
      }

    }
    else {
      return (
          <span>Loading...</span>
      );
    }
  }
}

export default Stats;