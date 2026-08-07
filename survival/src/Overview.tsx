import "./App.css";

const humanCaloriesPerDay = 3000;
const population = 1000;
const women = population * 0.5;

const society = {
  population: population,
  birthPerWoman: 10, // every woman gives birth once for every ten years they live
  lifeExpectancy: 100,
  birthRate: 0,
  deathRate: 0,
  populationGrowthRate: 0,
};

society.birthRate = women * society.birthPerWoman / society.lifeExpectancy;
society.deathRate = 1000 / society.lifeExpectancy;
society.populationGrowthRate = (society.birthRate - society.deathRate) / 1000 *
  100;

export function Overview() {
  return (
    <div>
      <h2>Overview</h2>
      <table>
        <tbody>
          <tr>
            <th>Population:</th>
            <td>{society.population}</td>
          </tr>
          <tr>
            <th>Birth per woman:</th>
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

      <h3>Needs per person</h3>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Need</th>
            <th>Supply</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>
              Food
            </td>
            <td>
              {humanCaloriesPerDay}
            </td>
            <td>
              {humanCaloriesPerDay}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
}
