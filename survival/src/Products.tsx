import "./App.css";
import { products } from "./data/data.ts";

function toUpperCase(s: string) {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

export function Products() {
  return (
    <div>
      <h3>Products</h3>
      <table>
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
