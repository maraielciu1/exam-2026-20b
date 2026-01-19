const Koa = require("koa");
const app = new Koa();
const server = require("http").createServer(app.callback());
const WebSocket = require("ws");
const wss = new WebSocket.Server({ server });
const Router = require("@koa/router");
const cors = require("@koa/cors");
const bodyParser = require("koa-bodyparser");

app.use(bodyParser());
app.use(cors());
app.use(middleware);

async function middleware(ctx, next) {
    const start = new Date();
    try {
        console.log(`[REQ] ${ctx.request.method} ${ctx.request.url}`);
        if (ctx.request.body && Object.keys(ctx.request.body).length > 0) {
            console.log(`[REQ] Payload:`, ctx.request.body);
        }
        await next();
    } catch (err) {
        ctx.status = err.status || 500;
        ctx.body = { error: err.message };
        console.error(`[ERROR] ${ctx.status} ${ctx.request.method} ${ctx.request.url} - Cause: ${err.message}`, err);
    } finally {
        const ms = new Date() - start;
        console.log(`[RES] ${start.toLocaleTimeString()} ${ctx.status} ${ctx.request.method} ${ctx.request.url} - ${ms}ms`);
    }
}

const logs = [
    { id: 1, date: "2026-01-15", amount: 500, type: "intake", category: "lunch", description: "Chicken salad" },
    { id: 2, date: "2026-01-15", amount: 300, type: "burn", category: "running", description: "Morning jog" },
];

const router = new Router();

router.get("/logs", async (ctx) => {
    ctx.body = logs;
    ctx.status = 200;
});

router.get("/log/:id", async (ctx) => {
    const id = parseInt(ctx.params.id);
    const item = logs.find((t) => t.id === id);
    if (item) {
        ctx.body = item;
        ctx.status = 200;
    } else {
        ctx.throw(404, "Log not found");
    }
});

router.post("/log", async (ctx) => {
    const { date, amount, type, category, description } = ctx.request.body;
    if (!date || !amount || !type) {
        ctx.throw(400, "Missing required fields");
    }
    const newLog = {
        id: Math.max(...logs.map((t) => t.id), 0) + 1,
        date,
        amount: parseFloat(amount),
        type,
        category: category || "general",
        description: description || ""
    };
    logs.push(newLog);
    broadcast(newLog);
    ctx.body = newLog;
    ctx.status = 201;
});

router.del("/log/:id", async (ctx) => {
    const id = parseInt(ctx.params.id);
    const idx = logs.findIndex((t) => t.id === id);
    if (idx === -1) {
        ctx.throw(404, "Log not found");
    }
    const deleted = logs.splice(idx, 1)[0];
    ctx.body = deleted;
    ctx.status = 200;
});

router.get("/allLogs", async (ctx) => {
    ctx.body = logs;
    ctx.status = 200;
});

function broadcast(data) {
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(data));
        }
    });
}

app.use(router.routes());
app.use(router.allowedMethods());

const port = 2621;
server.listen(port, () => {
    console.log(`Calorie Server running on port ${port}... 🚀`);
});
