import React, {Component} from 'react';

const STATS_URL = 'https://statsapi.web.nhl.com/api/v1/people/[ID]/stats/?stats=gameLog';
// const IMAGE_URL = 'https://nhl.bamcontent.com/images/headshots/current/60x60/[ID]@2x.jpg';

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
    id: 8479339,
    goals: 1,
    assists: 0,
    timeOnIce: '16:31',
  },
  {
    id: 8477493,
    goals: 0,
    assists: 2,
    timeOnIce: '15:36',
  }
];

const fetchStats = () => {
  return new Promise((resolve, reject) => {
    let stats = [];
    players.map(player => {
      fetch(STATS_URL.replace(/\[ID\]/, player.id)).
          then(res => res.json()).
          then(
              (result) => {
                let splits = result.stats[0].splits;
                let latestGame = splits[0].stat;
                // console.log(splits);
                // console.log(latestGame);

                stats.push({
                  id: player.id,
                  goals: latestGame.goals,
                  assists: latestGame.assists,
                  timeOnIce: latestGame.timeOnIce,
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
      // stats: [],
      stats: mockStats,
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
          stats.map(({id, goals, assists, timeOnIce}) =>
              <div key={id} className="card">
                <div className="card__player">
                  {players.find(player => player.id === id).name}
                </div>
                <div>
                  <table className="card__stats">
                    <thead>
                    <tr>
                      <th>Goals</th>
                      <th>Assists</th>
                      <th>Time on Ice</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                      <td>{goals}</td>
                      <td>{assists}</td>
                      <td>{timeOnIce}</td>
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