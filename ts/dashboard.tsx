import * as React from "react";
import {Player} from "./player";

interface Props {
  player: Player;
}

export class Dashboard extends React.Component<Props,{}> {
  enabled = true;
  playing = false;

  enable() {
    this.enabled = true;
  }

  disable() {
    this.enabled = false;
  }

  recursivePlay() {
    if (!this.playing) {
      return;
    }
    this.props.player.forward().then(
      () => {
        (new Promise((resolve, reject) => {
          setTimeout(() => {resolve()}, 200);
        })).then(() => this.recursivePlay());
      },
      () => {this.enable(); this.playing = false;}
    );
  }

  public play() {
    if (this.playing) {
      this.pause();
      return;
    }
    if (!this.enabled) {
      return;
    }
    this.disable();
    this.playing = true;
    this.setState({});
    this.recursivePlay();
  }

  public pause() {
    this.playing = false;
    this.enable();
    this.setState({});
  }

  public forward() {
    if (!this.enabled) {
      return;
    }
    this.disable();
    this.props.player.forward().then(
      () => this.enable(),
      () => this.enable()
    );
  }

  public backward() {
    if (!this.enabled) {
      return;
    }
    this.disable();
    this.props.player.backward().then(
      () => this.enable(),
      () => this.enable()
    );
  }

  public gotoBeginning() {
    this.props.player.gotoBeginning();
  }

  public gotoEnd() {

  }

  render() {
    return (
      <div className="commentBox">
        <button onClick={e => this.gotoBeginning()} className="btn btn-secondary"><i className="fa fa-fast-backward" aria-hidden="true"></i></button>
        <button onClick={e => this.backward()} className="btn btn-secondary"><i className="fa fa-backward" aria-hidden="true"></i></button>
        <button onClick={e => this.play()} className="btn btn-secondary"><i className={"fa " + (this.playing ? "fa-pause" : "fa-play")} aria-hidden="true"></i></button>
        <button onClick={e => this.forward()} className="btn btn-secondary"><i className="fa fa-forward" aria-hidden="true"></i></button>
        <button className="btn btn-secondary"><i className="fa fa-fast-forward" aria-hidden="true"></i></button>
      </div>
    );
  }
}