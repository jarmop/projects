import {players} from './data';

const SCHEDULE_URL = 'https://statsapi.web.nhl.com/api/v1/schedule?date=';
const GAME_FEED_URL = 'https://statsapi.web.nhl.com/api/v1/game/[GAME_PK]/feed/live';
const IMAGE_URL = 'https://nhl.bamcontent.com/images/headshots/current/60x60/[PLAYER_ID]@2x.jpg';
const YOU_TUBE_SEARCH_URL = 'https://www.youtube.com/results?search_query=[QUERY]';
const GAME_STATUS_CODE_FINAL = '7';
const ERROR_MESSAGE = 'Something went wrong.';
const CACHE_VERSION = 2;

let playerIds = Object.keys(players);
let startDate = (new Date());
startDate.setHours(0, 0, 0, 0);
startDate.setDate(startDate.getDate() - 1);
let cacheKey = 'stats' + startDate.getTime() + CACHE_VERSION;

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

const fetchFinishedGames = () => {
  let date = formatDate(startDate);
  // let date = 'bad-request';
  // let date = '2018-06-06';
  return fetch(SCHEDULE_URL + date)
      .then(response => {
        if (response.status !== 200) {
          return Promise.reject();
        }
        return response.json();
      })
      .then(
          (result) => {
            if (result.totalGames === 0) {
              return Promise.reject('No games today.');
            }
            let games = result.dates[0].games;
            let gamePks = [];
            for (let game of games) {
              if (game.status.statusCode !== GAME_STATUS_CODE_FINAL) {
                break;
              }
              gamePks.push(game.gamePk);
            }
            if (gamePks.length === games.length) {
              return Promise.resolve(gamePks);
            }
            else {
              return Promise.reject('Games are still running.');
            }
          },
          // Note: it's important to handle errors here
          // instead of a catch() block so that we don't swallow
          // exceptions from actual bugs in components.
          (error) => {
            return Promise.reject(ERROR_MESSAGE);
          },
      );
};

const addStar = (score, playerId, starValue) => {
  if (!score.hasOwnProperty(playerId)) {
    score[playerId] = {
      goals: 0,
      assists: 0,
    };
  }
  score[playerId].star = starValue;

  return score;
};

const fetchScores = (gamePks) => {
  return new Promise((resolve, reject) => {
    let processCount = 0;
    let score = {};
    for (let gamePk of gamePks) {
      fetch(GAME_FEED_URL.replace(/\[GAME_PK\]/, gamePk))
          .then(response => response.json())
          .then(
              // eslint-disable-next-line
              (result) => {
                processCount++;
                let {away, home} = result.liveData.boxscore.teams;
                Object.keys(away.players).map(playerId => {
                  let players = away.players[playerId];
                  if (players.position.code === 'G') {
                    score[players.person.id] = {
                      saves: players.stats.goalieStats.saves,
                      shots: players.stats.goalieStats.shots,
                    }
                  } else if (['C', 'L', 'R', 'D'].includes(players.position.code)) {
                    score[players.person.id] = {
                      goals: players.stats.skaterStats.goals,
                      assists: players.stats.skaterStats.assists,
                    }
                  }
                });

                score = addStar(score, result.liveData.decisions.firstStar.id, 1);
                score = addStar(score, result.liveData.decisions.secondStar.id, 2);
                score = addStar(score, result.liveData.decisions.thirdStar.id, 3);

                if (processCount === gamePks.length) {
                  resolve(score);
                }
              },
              // Note: it's important to handle errors here
              // instead of a catch() block so that we don't swallow
              // exceptions from actual bugs in components.
              // eslint-disable-next-line
              (error) => {
                reject(ERROR_MESSAGE);
              },
          );
    }
  });
};

const parseFinns = (score) => {
  let stats = [];
  for (let playerId of playerIds) {
    if (score.hasOwnProperty(playerId)) {
      stats.push({
        playerId: playerId,
        goals: score[playerId].goals,
        assists: score[playerId].assists,
        shots: score[playerId].shots,
        saves: score[playerId].saves,
        star: score[playerId].star,
      });
    }
  }

  return stats;
};

const sortByPoints = (stats) => {
  return stats.sort(
      (statsA, statsB) => {
        if (statsA.star || statsB.star) {
          return (statsA.star ? statsA.star : 4) - (statsB.star ? statsB.star : 4);
        }
        if (statsB.goals - statsA.goals !== 0) {
          return statsB.goals - statsA.goals;
        }
        if (statsB.assists - statsA.assists !== 0) {
          return statsB.assists - statsA.assists;
        }
        return 0;
      },
  )
};

export const getStats = () => {
  if (localStorage.getItem(cacheKey)) {
    let stats = JSON.parse(localStorage.getItem(cacheKey));
    return Promise.resolve(stats);
  }

  return fetchFinishedGames()
  // return Promise.resolve([2017021060])
      .then((gamePks) => fetchScores(gamePks))
      .then(score => parseFinns(score))
      .then(stats => sortByPoints(stats))
      .then(stats => {
        localStorage.setItem(cacheKey, JSON.stringify(stats));
        return stats;
      });
};

export const getImageUrl = (playerId) => {
  return IMAGE_URL.replace(/\[PLAYER_ID\]/, playerId);
};

export const getYouTubeSearchUrl = (name) => {
  return YOU_TUBE_SEARCH_URL.replace(/\[QUERY\]/, name.replace(/\s/, '+'));
};

export const getPlayer = (playerId) => {
  return players[playerId];
};