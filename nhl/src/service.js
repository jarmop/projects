const STATS_URL = 'https://statsapi.web.nhl.com/api/v1/people/[PLAYER_ID]/stats/?stats=gameLog';
const IMAGE_URL = 'https://nhl.bamcontent.com/images/headshots/current/60x60/[PLAYER_ID]@2x.jpg';

let currentDate = (new Date());
currentDate.setDate(currentDate.getDate() - 1);
let dayOfMonthYesterday = currentDate.getDate();

export const getStats = (players) => {
  return new Promise((resolve, reject) => {
    let stats = [];
    let processCount = 0;

    for (let player of players) {
      fetch(STATS_URL.replace(/\[PLAYER_ID\]/, player.id)).
          then(res => res.json()).
          then(
              (result) => {
                processCount++;
                let split = result.stats[0].splits[0];
                let gameDayOfMonth = new Date(split.date).getDate();
                let {goals, assists, points, timeOnIce} = split.stat;

                if (gameDayOfMonth === dayOfMonthYesterday && points > 0) {
                  stats.push({
                    playerId: player.id,
                    goals: goals,
                    assists: assists,
                    timeOnIce: timeOnIce,
                  });
                }

                if (processCount === players.length) {
                  resolve(stats);
                }
              },
              // Note: it's important to handle errors here
              // instead of a catch() block so that we don't swallow
              // exceptions from actual bugs in components.
              (error) => {
                if (processCount === players.length) {
                  resolve(stats);
                }
              },
          );
    }
  });
};

export const getImageUrl = (playerId) => {
  return IMAGE_URL.replace(/\[PLAYER_ID\]/, playerId);
};