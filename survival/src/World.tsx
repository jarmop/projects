import type { JSX } from "react";

const tileSize = 60;
const tilesCountX = 8;
const tilesCountY = 8;

export function World() {
  return (
    <div style={{ display: "flex" }}>
      <WorldMap />
      <SideBar />
    </div>
  );
}

export function SideBar() {
  return (
    <div>
      <table
        style={{
          marginLeft: 10,
        }}
      >
        <tbody>
          <tr>
            <td>Population:</td>
            <td>1000</td>
          </tr>
        </tbody>
      </table>
    </div>
  );
}

export function WorldMap() {
  const terrainCodes = terrainStrings.map((s) => s.split(","));

  const tiles: JSX.Element[] = [];
  for (let y = 0; y < tilesCountY; y++) {
    for (let x = 0; x < tilesCountX; x++) {
      tiles.push(
        <Terrain
          key={y + "-" + x}
          x={x}
          y={y}
          terrainCode={terrainCodes[y][x]}
        />,
      );
    }
  }

  return (
    <div>
      <svg
        width={tilesCountX * tileSize}
        height={tilesCountY * tileSize}
        style={{ border: "1px solid black" }}
      >
        {tiles}
      </svg>
    </div>
  );
}

interface TerrainProps {
  x: number;
  y: number;
  terrainCode: string;
}

function Terrain({ x, y, terrainCode }: TerrainProps) {
  const stroke = "black";
  const strokeOpacity = "0.1";

  if (terrainCode === "w") {
    return (
      <rect
        key={y + "-" + x}
        fill="lightblue"
        stroke={stroke}
        strokeOpacity={strokeOpacity}
        x={x * tileSize}
        y={y * tileSize}
        width={tileSize}
        height={tileSize}
      />
    );
  } else if (terrainCode === "p") {
    return (
      <rect
        key={y + "-" + x}
        fill="lightgreen"
        stroke={stroke}
        strokeOpacity={strokeOpacity}
        x={x * tileSize}
        y={y * tileSize}
        width={tileSize}
        height={tileSize}
      />
    );
  }
}

const terrainStrings = [
  "p,p,w,w,w,w,p,p",
  "p,p,p,w,w,p,p,p",
  "p,p,p,p,p,p,p,p",
  "p,p,p,p,p,p,p,p",
  "p,p,p,p,p,p,p,p",
  "p,p,p,p,p,p,p,p",
  "p,p,p,p,p,p,p,p",
  "p,p,p,p,p,p,p,p",
];
