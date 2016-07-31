import * as React from "react";
import {Player} from "./player";

interface Props {
  player: Player;
}

export class Dashboard extends React.Component<Props,{}> {
  enabled = true;
  comparisons = 0;
  swaps = 0;

  enable() {
    this.enabled = true;
  }

  disable() {
    this.enabled = false;
  }

  recursivePlay() {
    return this.props.player.forward().then(
      () => {
        this.updateStats();
        (new Promise((resolve, reject) => {
          setTimeout(() => {resolve()}, 200);
        })).then(() => this.recursivePlay());
      },
      () => Promise.resolve()
    );
  }


  public play() {
    if (!this.enabled) {
      return;
    }
    this.disable();
    this.recursivePlay().then(() => this.enable(), () => this.enable());
  }

  public forward() {
    if (!this.enabled) {
      return;
    }
    this.disable();
    this.props.player.forward().then(
      () => {this.updateStats(); this.enable();},
      () => this.enable()
    );
  }

  public backward() {
    if (!this.enabled) {
      return;
    }
    this.disable();
    this.props.player.backward().then(
      () => {this.updateStats(); this.enable();},
      () => this.enable()
    );
  }

  updateStats() {
    let filmActions = this.props.player.getFilmActions();
    this.comparisons = filmActions.comparisons;
    this.swaps = filmActions.swaps;
    this.setState({});
  }

  render() {
    return (
      <div className="commentBox">
        <button className="btn btn-secondary"><i className="fa fa-fast-backward" aria-hidden="true"></i></button>
        <button onClick={e => this.backward()} className="btn btn-secondary"><i className="fa fa-backward" aria-hidden="true"></i></button>
        <button onClick={e => this.play()} className="btn btn-secondary"><i className="fa fa-play" aria-hidden="true"></i></button>
        <button onClick={e => this.forward()} className="btn btn-secondary"><i className="fa fa-forward" aria-hidden="true"></i></button>
        <button className="btn btn-secondary"><i className="fa fa-fast-forward" aria-hidden="true"></i></button>
        <div class="stats">
          comparisons: {this.comparisons}
          <br/>
          swaps: {this.swaps}
        </div>
      </div>
    );
  }
}