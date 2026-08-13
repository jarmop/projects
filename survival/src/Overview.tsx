import { useState } from "react";
import "./App.css";
import { type Population, PopulationPyramid } from "./PopulationPyramid.tsx";

const ageOfNaturalDeath = 100;

const defaultSociety = {
  population: [] as Population,
  lifeExpectancy: ageOfNaturalDeath,
  birthRate: 0,
  deathRate: 0,
  populationGrowthRate: 0,
};

for (let i = 0; i < defaultSociety.lifeExpectancy; i++) {
  defaultSociety.population.push({ men: 5, women: 5 });
}

const humanWaterNeedPerDay = 3;
const humanCalorieNeedPerDay = 3000;
const wheatCalories = 3000;
const humanCalorieNeedPerYear = humanCalorieNeedPerDay * 365;

const wheatProductionPerYear = humanCalorieNeedPerYear * 1000 / wheatCalories;

export function Overview() {
  const [society, setSociety] = useState(defaultSociety);
  const populationTotalByAge = society.population.map(({ men, women }) =>
    men + women
  );
  const populationTotal = sum(populationTotalByAge);
  const [year, setYear] = useState(0);
  const [wheatStorage, setWheatStorage] = useState(
    humanCalorieNeedPerYear * populationTotal /
      wheatCalories,
  );
  const storageBuffer = humanCalorieNeedPerYear * populationTotal / 10;
  const wheatDemandPerYear = humanCalorieNeedPerYear * populationTotal /
    wheatCalories;

  const calorieSupply = wheatStorage * wheatCalories;
  const populationCalorieNeedPerYear = humanCalorieNeedPerYear *
    populationTotal;
  const populationCalorieBalance = calorieSupply - populationCalorieNeedPerYear;

  const starvingPeople = Math.max(
    Math.floor(-populationCalorieBalance / humanCalorieNeedPerYear),
    0,
  );

  function increaseYear() {
    // INCREASE YEAR
    const increase = 1;
    const newYear = year + increase;

    // UPDATE WHEAT STORAGE
    const newWheatStorage = Math.max(0, wheatStorage - wheatDemandPerYear) +
      wheatProductionPerYear;

    // UPDATE BIRTHS
    const populationAfforded =
      (newWheatStorage * wheatCalories - storageBuffer) /
      humanCalorieNeedPerYear;
    const fertileWomenCount = sum(
      society.population.slice(20, 30).map(({ women }) => women),
    );
    const births = Math.floor(
      Math.min(
        Math.max(
          populationAfforded -
            (populationTotal - populationTotalByAge[ageOfNaturalDeath - 1]),
          populationAfforded / ageOfNaturalDeath,
        ),
        fertileWomenCount,
      ),
    );

    let deaths = populationTotalByAge[ageOfNaturalDeath - 1];
    let sumOfAgesOfDying = deaths * ageOfNaturalDeath;

    const lessBirths = Math.floor(births / 2);
    const moreBirths = Math.ceil(births / 2);
    const babies = Math.random() > 0.5
      ? {
        men: moreBirths,
        women: lessBirths,
      }
      : {
        men: lessBirths,
        women: moreBirths,
      };
    const newPopulation = [babies, ...society.population].slice(0, -1);

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

    const newPopulationTotal = sum(
      newPopulation.map(({ men, women }) => men + women),
    );

    const newSociety = {
      ...society,
      population: newPopulation,
      birthRate: births / newPopulationTotal * 1000,
      lifeExpectancy: deaths > 0
        ? sumOfAgesOfDying / deaths
        : ageOfNaturalDeath,
      deathRate: deaths / newPopulationTotal * 1000,
      populationGrowthRate: (newPopulationTotal - populationTotal) /
        populationTotal * 100,
    };

    setYear(newYear);
    setSociety(newSociety);
    setWheatStorage(newWheatStorage);
  }

  return (
    <div style={{ display: "flex" }}>
      <div>
        <h3>Stats</h3>
        <table>
          <tbody>
            <tr>
              <th>Population:</th>
              <td>{populationTotal}</td>
            </tr>
            <tr>
              <th>Life expectancy:</th>
              <td>{society.lifeExpectancy.toFixed(1)} years</td>
            </tr>
            <tr>
              <th>Birth rate:</th>
              <td>{society.birthRate.toFixed(1)}</td>
            </tr>
            <tr>
              <th>Death rate:</th>
              <td>{society.deathRate.toFixed(1)}</td>
            </tr>
            <tr>
              <th>Population growth rate:</th>
              <td>{society.populationGrowthRate.toFixed(1)} %</td>
            </tr>
          </tbody>
        </table>

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
              <th>Amount</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                Grain (kg)
              </td>

              <td>
                {wheatProductionPerYear.toFixed(0)}
              </td>
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
