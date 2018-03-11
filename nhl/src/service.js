import {players} from './data';

const SCHEDULE_URL = 'https://statsapi.web.nhl.com/api/v1/schedule?date=';
const GAME_FEED_URL = 'https://statsapi.web.nhl.com/api/v1/game/[GAME_PK]/feed/live';
const IMAGE_URL = 'https://nhl.bamcontent.com/images/headshots/current/60x60/[PLAYER_ID]@2x.jpg';
const YOU_TUBE_SEARCH_URL = 'https://www.youtube.com/results?search_query=[QUERY]';
const GAME_STATUS_CODE_FINAL = '7';
const ERROR_MESSAGE = 'Something went wrong.';
const CACHE_VERSION = 1;

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

const fetchScores = (gamePks) => {
  return new Promise((resolve, reject) => {
    let stats = [];
    let processCount = 0;
    let score = {};
    for (let gamePk of gamePks) {
      fetch(GAME_FEED_URL.replace(/\[GAME_PK\]/, gamePk))
          .then(response => response.json())
          .then(
              // eslint-disable-next-line
              (result) => {
                processCount++;
                let scoringPlayIds = result.liveData.plays.scoringPlays;
                let allPlays = result.liveData.plays.allPlays;
                for (let playId of scoringPlayIds) {
                  let play = allPlays[playId];
                  for (let player of play.players) {
                    if (player.playerType !== 'Scorer' &&
                        player.playerType !== 'Assist') {
                      continue;
                    }
                    if (!score.hasOwnProperty(player.player.id)) {
                      score[player.player.id] = {
                        goals: 0,
                        assists: 0,
                      };
                    }
                    if (player.playerType === 'Scorer') {
                      score[player.player.id].goals++;
                    }
                    else if (player.playerType === 'Assist') {
                      score[player.player.id].assists++;
                    }
                  }
                }

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
      });
    }
  }

  return Promise.resolve(stats);
};

export const getStats = () => {
  if (localStorage.getItem(cacheKey)) {
    let stats = JSON.parse(localStorage.getItem(cacheKey));
    return Promise.resolve(stats);
  }

  return fetchFinishedGames()
      .then((gamePks) => fetchScores(gamePks))
      .then(score => parseFinns(score))
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

export const getYouTubeSearchUrl = (name) => {
  return YOU_TUBE_SEARCH_URL.replace(/\[QUERY\]/, name.replace(/\s/, '+'));
};

export const getPlayer = (playerId) => {
  return players[playerId];
};