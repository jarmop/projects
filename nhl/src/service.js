const STATS_URL = 'https://statsapi.web.nhl.com/api/v1/people/[PLAYER_ID]/stats/?stats=gameLog';
const IMAGE_URL = 'https://nhl.bamcontent.com/images/headshots/current/60x60/[PLAYER_ID]@2x.jpg';

let yesterdayDate = (new Date());
yesterdayDate.setDate(yesterdayDate.getDate() - 1);
yesterdayDate.setHours(0, 0, 0, 0);
let startOfYesterday = yesterdayDate.getTime();
let cacheKey = 'stats' + startOfYesterday;

export const getStats = (players) => {
  if (localStorage.getItem(cacheKey)) {
    return new Promise(
        (resolve, reject) => resolve(
            JSON.parse(localStorage.getItem(cacheKey)),
        ),
    );
  }

  let fetchStats = new Promise((resolve, reject) => {
    let stats = [];
    let processCount = 0;
    for (let player of players) {
      fetch(STATS_URL.replace(/\[PLAYER_ID\]/, player.id)).
          then(res => res.json()).
          then(
              (result) => {
                processCount++;
                let split = result.stats[0].splits[0];
                let gameTime = new Date(split.date).getTime();
                let {goals, assists, points, timeOnIce} = split.stat;

                if (gameTime > startOfYesterday && points > 0) {
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

  return fetchStats.then(stats => stats.sort(
      (statsA, statsB) => {
        if (statsB.goals - statsA.goals === 0) {
          return statsB.assists - statsA.assists;
        } else {
          return statsB.goals - statsA.goals;
        }
      },
  )).then(stats => {
    localStorage.setItem(cacheKey, JSON.stringify(stats));
    return stats;
  });
};

export const getImageUrl = (playerId) => {
  return IMAGE_URL.replace(/\[PLAYER_ID\]/, playerId);
};