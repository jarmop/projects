import * as React from "react";

interface Props {
  player: string;
}

export class Statistics extends React.Component<Props,{}> {
  comparisons = 0;
  swaps = 0;

  public increaseComparisons() {
    this.comparisons++;
    this.setState({});
  }

  public increaseSwaps() {
    this.swaps++;
    this.setState({});
  }

  public decreaseComparisons() {
    this.comparisons--;
    this.setState({});
  }

  public decreaseSwaps() {
    this.swaps--;
    this.setState({});
  }

  public reset() {
    this.comparisons = 0;
    this.swaps = 0;
    this.setState({});
  }

  render()
  {
    return (
      <div class="stats">
        comparisons: {this.comparisons}
        <br/>
        swaps: {this.swaps}
      </div>
    )
  }
}
