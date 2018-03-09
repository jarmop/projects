const STATS_URL = 'https://statsapi.web.nhl.com/api/v1/people/[PLAYER_ID]/stats/?stats=gameLog';
const IMAGE_URL = 'https://nhl.bamcontent.com/images/headshots/current/60x60/[PLAYER_ID]@2x.jpg';

export const getStats = (players) => {
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

export const getImageUrl = (playerId) => {
  return IMAGE_URL.replace(/\[PLAYER_ID\]/, playerId);
};