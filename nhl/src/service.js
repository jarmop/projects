const STATS_URL = 'https://statsapi.web.nhl.com/api/v1/people/[PLAYER_ID]/stats/?stats=gameLog';
const SCHEDULE_URL = 'https://statsapi.web.nhl.com/api/v1/schedule?date=';
const IMAGE_URL = 'https://nhl.bamcontent.com/images/headshots/current/60x60/[PLAYER_ID]@2x.jpg';
const GAME_STATUS_CODE_FINAL = '7';

let endDate = (new Date());
endDate.setHours(0, 0, 0, 0);
let startDate = (new Date());
startDate.setHours(0, 0, 0, 0);
startDate.setDate(startDate.getDate() - 1);
let cacheKey = 'stats' + startDate.getTime() + endDate.getTime();

/**
 * @param value
 * @returns {string}
 */
const addLeadingZero = (value) => {
  return value < 10 ? '0' + value : '' + value;
};

const formatDate = (date) => {
  return date.getFullYear() + '-' + addLeadingZero(date.getMonth() + 1) + '-' + addLeadingZero(date.getDate())
};

const checkIfGamesFinished = () => {
  let date = formatDate(startDate);
  return new Promise((resolve, reject) => {
    fetch(SCHEDULE_URL + date).
        then(res => res.json()).
        then(
            (result) => {
              let gamesFinished = true;

              for (let game of result.dates[0].games) {
                if (game.status.statusCode !== GAME_STATUS_CODE_FINAL) {
                  gamesFinished = false;
                  break;
                }
              }

              if (gamesFinished) {
                resolve();
              } else {
                reject();
              }
            },
            // Note: it's important to handle errors here
            // instead of a catch() block so that we don't swallow
            // exceptions from actual bugs in components.
            (error) => {
              reject();
            },
        );
  });
};

const fetchStats = (players) => {
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
                let gameTime = new Date(split.date).getTime();
                let {goals, assists, points, timeOnIce} = split.stat;

                if (gameTime > startDate.getTime() && points > 0) {
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

export const getStats = (players) => {
  if (localStorage.getItem(cacheKey)) {
    return new Promise(
        (resolve, reject) => resolve(
            JSON.parse(localStorage.getItem(cacheKey)),
        ),
    );
  }

  return checkIfGamesFinished().
      catch(() => {
        // Games not finished
        return [];
      }).
      then(() => fetchStats(players)).
      then(stats => stats.sort(
          (statsA, statsB) => {
            if (statsB.goals - statsA.goals === 0) {
              return statsB.assists - statsA.assists;
            } else {
              return statsB.goals - statsA.goals;
            }
          },
      )).
      then(stats => {
        localStorage.setItem(cacheKey, JSON.stringify(stats));
        return stats;
      });
};

export const getImageUrl = (playerId) => {
  return IMAGE_URL.replace(/\[PLAYER_ID\]/, playerId);
};