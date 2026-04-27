# CampusEats

CampusEats is a campus food delivery web application built with **C#** and **.NET**. It lets customers order products from different campus restaurants and allows couriers to deliver those orders while getting a fee. Admins can monitor users and manage restaurants when needed.

---

## Features

- **Customers** browse products, place orders, track delivery status in real time, tip couriers, and confirm delivery
- **Couriers** accept available orders, mark them as picked up, and receive real-time notifications about new orders
- **Admins** manage products, couriers, and orders
- **Real-time notifications** via SignalR — no page refresh needed
- **Email confirmations** via SMTP

---

## Getting Started

### Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Git](https://git-scm.com/)

### 1. Clone the repository

```bash
git clone https://github.com/dat240-2026/willabdidanijonaabdu
cd CampusEatsv2
```

### 2. Start the application

```bash
docker compose up --build
```

### 3. Open in browser

```
http://localhost:8080/
```

---

## Troubleshooting

If something goes wrong, try the following steps in order:

**Clean and rebuild:**
```bash
dotnet clean
dotnet build
```

**Reset database and migrations:**
```bash
docker-compose down -v
```

Then start Docker again:
```bash
docker compose up --build
```
## Debugging Tools

**SMTP dashboard** — Smtp4dev captures all outgoing emails locally without sending them. You can inspect email content, headers, and delivery status
```
127.0.0.1:5000
```
**RabbitMQ dashboard** — RabbitMQ ships with a built-in management UI where you can monitor queues, message rates, and connections at:
```
http://localhost:15672
```
Default credentials are `guest` / `guest`.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Blazor Server, Tailwind CSS |
| Backend | C#, .NET, MediatR, SignalR |
| Database | PostgreSQL (EF Core) |
| Messaging | RabbitMQ |
| Email | SMTP / Smtp4dev |
| Container | Docker |

---

## Default Accounts

The following test accounts are seeded automatically in development:

| Role | Email | Password |
|---|---|---|
| Admin | admin@campuseats.com | admin1234 |
| Customer | john@example.com | password123 |
| Courier | mike@courier.com | password123 |
