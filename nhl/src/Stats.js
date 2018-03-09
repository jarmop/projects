import React, {Component} from 'react';
import {getStats, getImageUrl} from './service';

const players = [
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
];

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
      getStats(players).then(stats => {
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
            stats.map(({playerId, goals, assists, timeOnIce, date}) =>
                <div key={playerId} className="card-container">
                  <div className="card">
                    <div className="card__player">
                      <img
                          src={getImageUrl(playerId)}
                          className="card__headshot"
                          alt={players.find(
                              player => player.id === playerId).name}
                          title={players.find(
                              player => player.id === playerId).name}
                      />
                    </div>
                    <div className="card__points">
                      {goals + ' + ' + assists}
                    </div>
                  </div>
                </div>,
            )
        );
      } else {
        return (
            <span>:(</span>
        );
      }

    } else {
      return (
          <span>Loading...</span>
      );
    }
  }
}

export default Stats;