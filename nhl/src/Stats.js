import React, {Component} from 'react';

const STATS_URL = 'https://statsapi.web.nhl.com/api/v1/people/8479339/stats/?stats=gameLog';

class Stats extends Component {
  constructor(props) {
    super(props);
    this.state = {
      statsReady: false,
      goals: 10,
      assists: 10,
      timeOnIce: 10,
    };
  }

  componentDidMount() {
    fetch(STATS_URL).then(res => res.json()).then(
        (result) => {
          let splits = result.stats[0].splits;
          let latestGame = splits[0].stat;
          console.log(splits);
          console.log(latestGame);

          this.setState({
            statsReady: true,
            goals: latestGame.goals,
            assists: latestGame.assists,
            timeOnIce: latestGame.timeOnIce,
          });
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
  }

  render() {
    let {goals, assists, timeOnIce, statsReady} = this.state;

    if (statsReady) {
      return (
          <div className="card">
            <div className="card__player">
              Patrik Laine
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
      );
    } else {
      return (
          <span>Loading...</span>
      );
    }
  }
}

export default Stats;