import "./style.css";

const ctx = document.querySelector("canvas")?.getContext("2d");
if (ctx) {
  ctx.fillStyle = "green";
  // Add a rectangle at (10, 10) with size 100x100 pixels
  ctx.fillRect(10, 10, 100, 100);
}
