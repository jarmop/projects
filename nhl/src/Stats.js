import React, {Component} from 'react';

const STATS_URL = 'https://statsapi.web.nhl.com/api/v1/people/[PLAYER_ID]/stats/?stats=gameLog';
const IMAGE_URL = 'https://nhl.bamcontent.com/images/headshots/current/60x60/[PLAYER_ID]@2x.jpg';

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

const fetchStats = () => {
  return new Promise((resolve, reject) => {
    let stats = [];
    players.map(player => {
      fetch(STATS_URL.replace(/\[PLAYER_ID\]/, player.id)).
          then(res => res.json()).
          then(
              (result) => {
                let splits = result.stats[0].splits;
                let {goals, assists, timeOnIce} = splits[0].stat;
                let date = splits[0].date;
                // console.log(splits);
                // console.log(latestGame);

                stats.push({
                  playerId: player.id,
                  goals: goals,
                  assists: assists,
                  timeOnIce: timeOnIce,
                  date: date,
                });

                if (stats.length === players.length) {
                  resolve(stats);
                }
              },
              // Note: it's important to handle errors here
              // instead of a catch() block so that we don't swallow
              // exceptions from actual bugs in components.
              (error) => {
                this.setState({
                  isLoaded: true,
                  error,
                });
              },
          );
    });
  });
};

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
      fetchStats().then(stats => {
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
                      src={IMAGE_URL.replace(/\[PLAYER_ID\]/, playerId)}
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