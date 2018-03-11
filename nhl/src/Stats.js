import React, {Component} from 'react';
import 'font-awesome/css/font-awesome.min.css';
import {getStats, getImageUrl, getYouTubeSearchUrl, getPlayer} from './service';

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
      getStats()
          .then(stats => {
            this.setState({
              statsReady: true,
              stats: stats,
            });
          })
          .catch((message) => {
            this.setState({
              statsReady: true,
              message: message,
            });
          });
    }
  }

  render() {
    let {statsReady, stats, message} = this.state;

    if (statsReady) {
      if (stats.length > 0) {
        return (
            stats.map(({playerId, goals, assists, star = null}) =>
                <div key={playerId} className="card-container">
                  <a
                      href={getYouTubeSearchUrl(getPlayer(playerId).name)}
                      className="player-link"
                      target="_blank"
                  >
                    <div className="card">
                      <div className="card__player">
                        <img
                            src={getImageUrl(playerId)}
                            className="card__headshot"
                            alt={getPlayer(playerId).name}
                            title={getPlayer(playerId).name}
                        />
                      </div>
                      <div className="card__points">
                        {goals + ' + ' + assists}
                      </div>
                      {star > 0 &&
                      <i
                          className="fa fa-star card__star"
                          title={star}
                      >
                        <span className="card__star-value">{star}</span>
                      </i>
                      }
                    </div>
                  </a>
                </div>,
            )
        );
      }
      else {
        return (
            <span>{message}</span>
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