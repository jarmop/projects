import { useState } from "react";
import "./App.css";
import { type Population, PopulationPyramid } from "./PopulationPyramid.tsx";

const portionOfWomen = 0.5;
const ageOfNaturalDeath = 100;

const defaultSociety = {
  population: [] as Population,
  birthPerWoman: 2, // every woman gives birth once for every ten years they live
  lifeExpectancy: ageOfNaturalDeath,
  birthRate: 0,
  deathRate: 0,
  populationGrowthRate: 0,
};

for (let i = 0; i < defaultSociety.lifeExpectancy; i++) {
  defaultSociety.population.push({ men: 5, women: 5 });
}

defaultSociety.birthRate =
  sum(defaultSociety.population.map(({ women }) => women)) *
  defaultSociety.birthPerWoman / defaultSociety.lifeExpectancy;
defaultSociety.deathRate = 1000 / defaultSociety.lifeExpectancy;
defaultSociety.populationGrowthRate =
  (defaultSociety.birthRate - defaultSociety.deathRate) / 1000;

const humanWaterNeedPerDay = 3;
const humanCalorieNeedPerDay = 3000;
const wheatCalories = 3000;
const humanCalorieNeedPerYear = humanCalorieNeedPerDay * 365;

const wheatProductionPerYear = humanCalorieNeedPerYear * 999 / wheatCalories;

export function Overview() {
  const [society, setSociety] = useState(defaultSociety);
  const totalPopulationByAge = society.population.map(({ men, women }) =>
    men + women
  );
  const totalPopulation = sum(totalPopulationByAge);
  const [year, setYear] = useState(0);
  const [wheatStorage, setWheatStorage] = useState(
    humanCalorieNeedPerYear * totalPopulation /
      wheatCalories,
  );
  const wheatDemandPerYear = humanCalorieNeedPerYear * totalPopulation /
    wheatCalories;

  const calorieSupply = wheatStorage * wheatCalories;
  const populationCalorieNeedPerYear = humanCalorieNeedPerYear *
    totalPopulation;
  const populationCalorieBalance = calorieSupply - populationCalorieNeedPerYear;

  const starvingPeople = Math.min(
    Math.floor(-populationCalorieBalance / humanCalorieNeedPerYear),
  );

  function increaseYear() {
    const increase = 1;
    const newYear = year + increase;
    setYear(newYear);

    const women = Math.ceil(totalPopulation * portionOfWomen);
    const births = Math.ceil(
      society.birthPerWoman / society.lifeExpectancy * women,
    );
    let deaths = totalPopulationByAge[ageOfNaturalDeath - 1];
    let sumOfAgesOfDying = deaths * ageOfNaturalDeath;

    const newPopulation = [{
      men: Math.floor(births / 2),
      women: Math.ceil(births / 2),
    }, ...society.population].slice(
      0,
      -1,
    );

    let peopleToStarve = starvingPeople;

    for (
      let age = newPopulation.length - 1;
      age >= 0 && peopleToStarve > 0;
      age--
    ) {
      const { men, women } = newPopulation[age];
      const total = men + women;
      if (peopleToStarve >= total) {
        peopleToStarve -= total;
        deaths += total;
        sumOfAgesOfDying += total * age;
        newPopulation[age].men = 0;
        newPopulation[age].women = 0;
      } else {
        newPopulation[age].men -= Math.ceil(peopleToStarve / 2);
        newPopulation[age].women -= Math.floor(peopleToStarve / 2);
        deaths += peopleToStarve;
        sumOfAgesOfDying += peopleToStarve * age;
        peopleToStarve = 0;
      }
    }
    // console.log(births, deaths);

    const newSociety = {
      ...society,
      lifeExpectancy: sumOfAgesOfDying / deaths,
      population: newPopulation,
    };

    setSociety(newSociety);

    setWheatStorage(
      Math.max(0, wheatStorage - wheatDemandPerYear) + wheatProductionPerYear,
    );
  }

  return (
    <div style={{ display: "flex" }}>
      <div>
        <h3>Stats</h3>
        <table>
          <tbody>
            <tr>
              <th>Population:</th>
              <td>{totalPopulation}</td>
            </tr>
            <tr>
              <th>Births per woman:</th>
              <td>{society.birthPerWoman}</td>
            </tr>
            <tr>
              <th>Birth rate:</th>
              <td>{society.birthRate}</td>
            </tr>
            <tr>
              <th>Life expectancy:</th>
              <td>{society.lifeExpectancy.toFixed(1)} years</td>
            </tr>
            <tr>
              <th>Death rate:</th>
              <td>{society.deathRate}</td>
            </tr>
            <tr>
              <th>Population growth rate:</th>
              <td>{society.populationGrowthRate} %</td>
            </tr>
          </tbody>
        </table>

        {
          /* <h3>Population per age</h3>
      <table>
        <tbody>
          <tr>
            <th>Fertile (20-29):</th>
            <td>{sum(society.population.slice(20, 30))}</td>
          </tr>
        </tbody>
      </table> */
        }

        <h3>Needs per person per day</h3>
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Amount</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                Water (l)
              </td>
              <td>
                {humanWaterNeedPerDay}
              </td>
            </tr>
            <tr>
              <td>
                Food (kcal)
              </td>
              <td>
                {humanCalorieNeedPerDay}
              </td>
            </tr>
          </tbody>
        </table>

        <h3>Expected production this year</h3>
        <table>
          <thead>
            <tr>
              <th>Name</th>
              {/* <th>Demand</th> */}
              <th>Amount</th>
              {/* <th>Balance</th> */}
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                Grain (kg)
              </td>
              {
                /* <td>
              {wheatDemandPerYear.toFixed(0)}
            </td> */
              }
              <td>
                {wheatProductionPerYear.toFixed(0)}
              </td>
              {
                /* <td>
              {(wheatProductionPerYear - wheatDemandPerYear).toFixed(0)}
            </td> */
              }
            </tr>
          </tbody>
        </table>

        <h3>Storage compared to consumption</h3>
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Amount</th>
              <th>Consumption</th>
              <th>Balance</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                Grain (kg)
              </td>
              <td>
                {wheatStorage.toFixed(0)}
              </td>
              <td>
                {wheatDemandPerYear.toFixed(0)}
              </td>
              <td>
                {(wheatStorage - wheatDemandPerYear).toFixed(0)}
              </td>
            </tr>
          </tbody>
        </table>

        <h3>Population calorie balance</h3>
        {populationCalorieBalance}

        <p>
          Deficit of N human's yearly calorie needs will result in N deaths.
        </p>
        Amount of people who will starve to death: {starvingPeople}

        <div
          style={{ position: "absolute", top: 0, right: 0, display: "flex" }}
        >
          <table>
            <tbody>
              <tr>
                <td>Year:</td>
                <td>{year}</td>
              </tr>
            </tbody>
          </table>
          <button type="button" onClick={increaseYear}>+</button>
        </div>
      </div>
      <div>
        <PopulationPyramid population={society.population} />
      </div>
    </div>
  );
}

function sum(values: number[]) {
  return values.reduce((total, n) => total + n, 0);
}
