import { useState } from "react";

export type Population = {
  men: number;
  women: number;
}[];

interface PopulationPyramidProps {
  population: Population;
}

export function PopulationPyramid({ population }: PopulationPyramidProps) {
  const [info, setInfo] = useState<
    { age: number; men: number; women: number } | null
  >(null);

  const maxAge = population.length - 1;
  // const maxCount = 10;
  let maxCount = 0;
  population.forEach(({ men, women }) => {
    maxCount = Math.max(maxCount, men, women);
  });

  function handleMouseEnter(
    age: number,
    men: number,
    women: number,
  ) {
    setInfo({ age, men, women });
  }

  return (
    <div className="population-pyramid">
      {info &&
        (
          <div className="info">
            <table>
              <tbody>
                <tr>
                  <th>Age:</th>
                  <td>{info.age}</td>
                </tr>
                <tr>
                  <th>men:</th>
                  <td>{info.men}</td>
                </tr>
                <tr>
                  <th>women:</th>
                  <td>{info.women}</td>
                </tr>
              </tbody>
            </table>
          </div>
        )}
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          borderBottom: "1px solid black",
        }}
      >
        <div>{maxCount}</div>
        <div>{maxCount}</div>
      </div>
      {population.toReversed().map(({ men, women }, i) => (
        <div
          key={i}
          style={{ display: "flex" }}
          onMouseEnter={() => handleMouseEnter(maxAge - i, men, women)}
          onMouseLeave={() => setInfo(null)}
          className="row"
        >
          <div
            className="cell"
            style={{ justifyContent: "right" }}
          >
            <div
              className="meter"
              style={{
                width: men / maxCount * 100 + "px",
                background: "blue",
              }}
            >
            </div>
          </div>
          <div
            className="cell"
            style={{ justifyContent: "left" }}
          >
            <div
              className="meter"
              style={{
                width: women / maxCount * 100 + "px",
                background: "red",
              }}
            >
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
