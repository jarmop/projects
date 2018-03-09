import React, {Component} from 'react';
import {getStats, getImageUrl} from './service';

const players = [
  {
    id: 8479339,
    name: 'Patrik Laine',
  },
  {
    id: 8477493,
    name: 'Aleksander Barkov',
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
  }
];

class Stats extends Component {
  constructor(props) {
    super(props);
    this.state = {
      stats: [],
      // stats: mockStats,
    };
  }

  componentDidMount() {
    if (this.state.stats.length === 0) {
      getStats(players).then(stats => {
        this.setState({
          stats: stats,
        });
      });
    }
  }

  render() {
    let {stats} = this.state;

    if (stats.length === players.length) {
      return (
          stats.map(({playerId, goals, assists, timeOnIce, date}) =>
              <div key={playerId} className="card">
                <div className="card__player">
                  <img
                      src={getImageUrl(playerId)}
                      className="headshot"
                      alt={players.find(player => player.id === playerId).name}
                      title={players.find(player => player.id === playerId).name}
                  />
                </div>
                <div className="card__stats">
                  <table>
                    <tbody>
                    <tr>
                      <th>Goals:</th>
                      <td>{goals}</td>
                    </tr>
                    <tr>
                      <th>Assists:</th>
                      <td>{assists}</td>
                    </tr>
                    <tr>
                      <th>Time on ice:</th>
                      <td>{timeOnIce}</td>
                    </tr>
                    <tr>
                      <th>Date:</th>
                      <td>{date}</td>
                    </tr>
                    </tbody>
                  </table>
                </div>
              </div>
          )
      );
    } else {
      return (
          <span>Loading...</span>
      );
    }
  }
}

export default Stats;