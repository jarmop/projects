import { type JSX, useState } from "react";
import "./App.css";

const portionOfWomen = 0.5;
const birthPerWoman = 2;
const lifeExpectancy = 100;

const population: number[] = [];
for (let i = 0; i < lifeExpectancy; i++) {
  population.push(10);
}

const defaultSociety = {
  population: 1000,
  birthPerWoman: birthPerWoman, // every woman gives birth once for every ten years they live
  lifeExpectancy: lifeExpectancy,
  birthRate: 0,
  deathRate: 0,
  populationGrowthRate: 0,
};

defaultSociety.birthRate = defaultSociety.population * portionOfWomen *
  defaultSociety.birthPerWoman /
  defaultSociety.lifeExpectancy;
defaultSociety.deathRate = 1000 / defaultSociety.lifeExpectancy;
defaultSociety.populationGrowthRate =
  (defaultSociety.birthRate - defaultSociety.deathRate) / 1000;

const humanWaterNeedPerDay = 3;
const humanCalorieNeedPerDay = 3000;
const wheatCalories = 3500;

export function Overview() {
  const [society, setSociety] = useState(defaultSociety);
  const [year, setYear] = useState(0);

  function increaseYear() {
    const increase = 1;
    const newYear = year + increase;
    setYear(newYear);

    const women = society.population * portionOfWomen;
    const births = society.birthPerWoman / society.lifeExpectancy * women;
    const deaths = society.population / lifeExpectancy;
    console.log(births, deaths);

    // But the demographic is not going to stay even if the population is growing.
    // Every year there are more people giving birth. The number of deaths per year
    // lags 100 years behind the number of births.

    const newSociety = {
      ...society,
      population: society.population *
        Math.pow(1 + society.populationGrowthRate, increase),
    };

    // newSociety.population = society.population +
    // society.population * society.populationGrowthRate;

    setSociety(newSociety);
  }

  const populationPerAge: JSX.Element = [];

  // for (let i = 0;)
  // return (
  //   <tr>
  //     <th>0-9:</th>
  //     <td>{society.population / 100}</td>
  //   </tr>
  // );

  return (
    <div>
      <h3>Overview</h3>
      <table>
        <tbody>
          <tr>
            <th>Population:</th>
            <td>{society.population}</td>
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
            <td>{society.lifeExpectancy} years</td>
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

      <h3>Population per age</h3>
      <table>
        <tbody>
          <tr>
            <th>Fertile (20-29):</th>
            <td>{society.population / 100}</td>
          </tr>
        </tbody>
      </table>

      <h3>Needs per person per day</h3>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Demand</th>
            <th>Supply</th>
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
            <td>
              {humanCalorieNeedPerDay}
            </td>
          </tr>
        </tbody>
      </table>

      <h3>Production Per year</h3>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Demand</th>
            <th>Supply</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>
              Grain (tons)
            </td>
            <td>
              {(humanCalorieNeedPerDay * 365 * society.population /
                wheatCalories /
                1000)
                .toFixed(0)}
            </td>
            <td>
              {(humanCalorieNeedPerDay * 365 * society.population /
                wheatCalories /
                1000)
                .toFixed(0)}
            </td>
          </tr>
        </tbody>
      </table>

      <div style={{ position: "absolute", top: 0, right: 0, display: "flex" }}>
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
  );
}
