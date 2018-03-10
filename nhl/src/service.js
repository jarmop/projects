const STATS_URL = 'https://statsapi.web.nhl.com/api/v1/people/[PLAYER_ID]/stats/?stats=gameLog';
const SCHEDULE_URL = 'https://statsapi.web.nhl.com/api/v1/schedule?date=';
const IMAGE_URL = 'https://nhl.bamcontent.com/images/headshots/current/60x60/[PLAYER_ID]@2x.jpg';
const GAME_URL = 'https://www.nhl.com/gamecenter/[GAME_PK]';
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
  return date.getFullYear()
      + '-'
      + addLeadingZero(date.getMonth() + 1)
      + '-'
      + addLeadingZero(date.getDate());
};

const checkIfGamesFinished = () => {
  let date = formatDate(startDate);
  return new Promise((resolve, reject) => {
    fetch(SCHEDULE_URL + date).then(res => res.json())
        .then(
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
              }
              else {
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

const fetchStats = (playerIds) => {
  return new Promise((resolve, reject) => {
    let stats = [];
    let processCount = 0;
    for (let playerId of playerIds) {
      fetch(STATS_URL.replace(/\[PLAYER_ID\]/, playerId))
          .then(res => res.json())
          .then(
              // eslint-disable-next-line
              (result) => {
                processCount++;
                let split = result.stats[0].splits[0];
                let gameTime = new Date(split.date).getTime();
                let {goals, assists, points} = split.stat;

                if (gameTime > startDate.getTime() && points > 0) {
                  stats.push({
                    playerId: playerId,
                    goals: goals,
                    assists: assists,
                    gamePk: split.game.gamePk,
                  });
                }

                if (processCount === playerIds.length) {
                  resolve(stats);
                }
              },
              // Note: it's important to handle errors here
              // instead of a catch() block so that we don't swallow
              // exceptions from actual bugs in components.
              // eslint-disable-next-line
              (error) => {
                if (processCount === playerIds.length) {
                  resolve(stats);
                }
              },
          );
    }
  });
};

export const getStats = (playerIds) => {
  if (localStorage.getItem(cacheKey)) {
    return new Promise(
        (resolve, reject) => resolve(
            JSON.parse(localStorage.getItem(cacheKey)),
        ),
    );
  }

  return checkIfGamesFinished()
      .catch(() => {
        // Games not finished
        return [];
      })
      .then(() => fetchStats(playerIds))
      .then(stats => stats.sort(
          (statsA, statsB) => {
            if (statsB.goals - statsA.goals === 0) {
              return statsB.assists - statsA.assists;
            }
            else {
              return statsB.goals - statsA.goals;
            }
          },
      ))
      .then(stats => {
        localStorage.setItem(cacheKey, JSON.stringify(stats));
        return stats;
      });
};

export const getImageUrl = (playerId) => {
  return IMAGE_URL.replace(/\[PLAYER_ID\]/, playerId);
};

export const getGameUrl = (gamePk) => {
  return GAME_URL.replace(/\[GAME_PK\]/, gamePk);
};