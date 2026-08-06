# CRUD App with PostgreSQL (Dockerized)

A simple full-stack CRUD web app built with **Node.js + Express**, backed by **PostgreSQL**, and containerized with **Docker**.

This is the Week 1 deliverable: build the app → containerize it → prepare the GitHub repo.

---

## Features

- Create, Read, Update, Delete "items" via a REST API
- Minimal HTML/JS frontend to try it out in the browser
- PostgreSQL persistence
- Fully containerized with Docker + docker-compose

---

## Project Structure

```
crud-app/
├── server.js          # Express app + CRUD routes
├── db.js               # PostgreSQL connection pool + table setup
├── public/
│   └── index.html       # Simple frontend
├── Dockerfile           # Container definition for the app
├── docker-compose.yml    # App + Postgres for local testing
├── .env.example          # Example environment variables
├── package.json
└── README.md
```

---

## 1. Run Locally (without Docker)

Requirements: Node.js 18+, a running PostgreSQL instance.

```bash
npm install
cp .env.example .env     # edit values if your Postgres setup differs
npm start
```

App will be available at `http://localhost:3000`.

---

## 2. Run Locally with Docker (recommended)

This spins up both the app **and** PostgreSQL together.

```bash
docker compose up --build
```

- App: `http://localhost:3000`
- Postgres: `localhost:5432` (user: `postgres`, password: `postgres`, db: `cruddb`)

Stop everything with:

```bash
docker compose down
```

Add `-v` to also wipe the database volume: `docker compose down -v`

---

## 3. API Endpoints

| Method | Endpoint          | Description        |
|--------|-------------------|---------------------|
| GET    | `/api/items`      | List all items      |
| GET    | `/api/items/:id`  | Get a single item   |
| POST   | `/api/items`      | Create an item      |
| PUT    | `/api/items/:id`  | Update an item      |
| DELETE | `/api/items/:id`  | Delete an item       |
| GET    | `/health`         | Health check         |

Example create request:

```bash
curl -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name": "First item", "description": "Testing the API"}'
```

---

## 4. Build & Push the Image to Docker Hub

```bash
# 1. Build the image
docker build -t <your-dockerhub-username>/crud-app:latest .

# 2. Log in to Docker Hub
docker login

# 3. Push it
docker push <your-dockerhub-username>/crud-app:latest
```

Anyone can then run your image directly:

```bash
docker run -p 3000:3000 \
  -e POSTGRES_HOST=<your-db-host> \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=cruddb \
  <your-dockerhub-username>/crud-app:latest
```

---

## 5. Environment Variables

| Variable            | Default     | Description               |
|---------------------|-------------|----------------------------|
| `PORT`               | `3000`      | App port                   |
| `POSTGRES_HOST`      | `localhost` | Postgres host               |
| `POSTGRES_PORT`      | `5432`      | Postgres port                |
| `POSTGRES_USER`      | `postgres`  | Postgres username             |
| `POSTGRES_PASSWORD`  | `postgres`  | Postgres password               |
| `POSTGRES_DB`        | `cruddb`    | Database name                    |

---

## 6. Pushing this Project to GitHub

```bash
git init
git add .
git commit -m "Week 1: CRUD app, Dockerfile, local testing"
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

---

## Week 1 Checklist

- [x] CRUD web app built (Express + PostgreSQL)
- [x] Dockerfile written
- [x] Tested locally with docker-compose
- [x] README documentation
- [ ] Image pushed to Docker Hub (run the commands in section 4)
- [ ] Code pushed to GitHub (run the commands in section 6)
