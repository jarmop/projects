import "./App.css";
import { products, society } from "./data.ts";

function toUpperCase(s: string) {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

function App() {
  return (
    <div>
      <h2>Minimal self-sustaining society</h2>
      <table className="society">
        <tbody>
          <tr>
            <th>Population:</th>
            <td>{society.population}</td>
          </tr>
          <tr>
            <th>Calories per year:</th>
            <td>{society.caloriesPerYear.toLocaleString()}</td>
          </tr>
        </tbody>
      </table>

      <h3>Products</h3>
      <table className="products">
        <thead>
          <tr>
            <th>Name</th>
            <th>Materials</th>
            <th>Tools</th>
            <th>Category</th>
          </tr>
        </thead>
        <tbody>
          {products.map((product) => (
            <tr key={product.name}>
              <td>
                {toUpperCase(product.name)}
              </td>
              <td>{toUpperCase(product.materials.join(", "))}</td>
              <td>{toUpperCase(product.tools.join(", "))}</td>
              <td>{toUpperCase(product.category)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default App;
