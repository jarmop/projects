import React, { Component } from 'react';
import './App.css';
import Stats from "./Stats";

class App extends Component {
  render() {
    return (
      <div className="app">
        <div>
          <h1>Tilastoja viime pelistä</h1>
          <Stats/>
        </div>
      </div>
    );
  }
}

export default App;