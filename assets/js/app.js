// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"

// const hooks = {
// canvas: {
//     mounted() {
//         console.log("MOUNTED")
//         console.log(this)
//         console.log(this.el)
//         console.log(this.el.value)
//         // this.el.addEventListener("input", e => {
//         //     let match = this.el.value.replace(/\D/g, "").match(/^(\d{3})(\d{3})(\d{4})$/)
//         //     if(match) {
//         //     this.el.value = `${match[1]}-${match[2]}-${match[3]}`
//         //     }
//         // })
//     },
//     updated() {
//         console.log("UPDATED")
//         console.log(this)
//         console.log(this.el)
//         console.log(this.el.value)
//     }
// }
// }
let hooks = {
    canvas: {
        mounted() {
            let canvas = this.el.firstElementChild;
            let context = canvas.getContext("2d");

            Object.assign(this, { canvas, context });
            drawBoard(canvas, context, getDataset(this.el.dataset))
        },
        updated() {
            let { canvas, context } = this;

            context.clearRect(0, 0, canvas.width, canvas.height);
            context.fillStyle = "rgba(128, 0, 255, 1)";

            drawBoard(canvas, context, getDataset(this.el.dataset))

            // let halfHeight = canvas.height / 2;
            // let halfWidth = canvas.width / 2;
            // let smallerHalf = Math.min(halfHeight, halfWidth);

            context.fill();
        }
    }
};

function getDataset(dataset) {
    // console.log(dataset)
    return {
        grid: JSON.parse(dataset.grid),
        size: parseInt(dataset.size, 10)
    }
}

function drawBoard(canvas, context, data) {
    // var bw = canvas.width;
    // Box height
    // var bh = canvas.height;
    // Padding
    const p = 20;
    const bw = data.size;
    const bh = data.size;

    for (var x = 0; x <= bw; x++) {
        context.moveTo(x * p, 0);
        context.lineTo(x * p, bh * p);
    }

    for (var x = 0; x <= bh; x++) {
        context.moveTo(0, x * p);
        context.lineTo(bw * p, x * p);
    }


    const grid = data.grid;

    for (let i = 0; i < data.size; i++) {
        for (let j = 0; j < data.size; j++) {
            context.moveTo(i * p, j * p);
            context.lineTo(bw * p, x * p);
        }
    }

    context.strokeStyle = "black";
    context.stroke();
}


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket(
    "/live",
    Socket,
    {
        hooks,
        params: { _csrf_token: csrfToken }
    }
)

// document.addEventListener('phx:update', phxUpdateListener);

// function phxUpdateListener(event) {
//     console.log(event, "-------------------------------")
// }

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
