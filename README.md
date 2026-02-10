# Popmenu API

Rails 8 API for managing restaurants, menus, and menu items with bulk JSON import via background jobs.

## Stack

- Ruby 3.3 / Rails 8
- SQLite
- Solid Queue (background jobs, no Redis needed)
- RSpec (87 specs)

## Getting Started

### With Docker Compose

```bash
docker compose -f docker-compose.dev.yml up --build
```

That's it. The API runs at http://localhost:3000.

The `web` service runs the Rails server and the `jobs` service runs the Solid Queue worker. Both share a persistent `storage` volume for SQLite databases.

### Local Development

```bash
# Install dependencies
bundle install

# Setup databases
bin/rails db:prepare

# Run server + job worker together
bin/dev

# Or run them separately
bin/rails server -p 3000   # terminal 1
bin/jobs                    # terminal 2
```

### Running Tests

```bash
bundle exec rspec
```

## API Reference

All successful responses are wrapped in `{ "data": ... }`. Errors return `{ "error": { "message": "..." } }`.

### Restaurants

| Method | Path | Description |
|--------|------|-------------|
| GET | `/restaurants` | List all restaurants |
| POST | `/restaurants` | Create a restaurant |
| GET | `/restaurants/:id` | Get a restaurant |
| PATCH | `/restaurants/:id` | Update a restaurant |
| DELETE | `/restaurants/:id` | Delete a restaurant |

**Body (POST/PATCH):**

```json
{ "restaurant": { "name": "Poppo's", "address": "123 Main St", "phone": "555-1234" } }
```

### Menus

| Method | Path | Description |
|--------|------|-------------|
| GET | `/restaurants/:restaurant_id/menus` | List menus |
| POST | `/restaurants/:restaurant_id/menus` | Create a menu |
| GET | `/restaurants/:restaurant_id/menus/:id` | Get a menu |
| PATCH | `/restaurants/:restaurant_id/menus/:id` | Update a menu |
| DELETE | `/restaurants/:restaurant_id/menus/:id` | Delete a menu |

**Body (POST/PATCH):**

```json
{ "menu": { "name": "Lunch", "description": "Weekday specials", "active": true } }
```

### Menu Items

| Method | Path | Description |
|--------|------|-------------|
| GET | `/restaurants/:rid/menus/:mid/menu_items` | List items |
| POST | `/restaurants/:rid/menus/:mid/menu_items` | Create an item |
| GET | `/restaurants/:rid/menus/:mid/menu_items/:id` | Get an item |
| PATCH | `/restaurants/:rid/menus/:mid/menu_items/:id` | Update an item |
| DELETE | `/restaurants/:rid/menus/:mid/menu_items/:id` | Delete an item |

**Body (POST/PATCH):**

```json
{ "menu_item": { "name": "Burger", "description": "Juicy beef burger", "price": "12.50" } }
```

Menu items are globally unique by name. The same item can appear on multiple menus via placements.

### JSON Import (async)

Large imports run in the background via Solid Queue.

**1. Create an import:**

```bash
curl -X POST http://localhost:3000/imports \
  -H "Content-Type: application/json" \
  -d '{
    "restaurants": [
      {
        "name": "Poppo'\''s Cafe",
        "menus": [
          {
            "name": "Lunch",
            "menu_items": [
              { "name": "Burger", "price": 9.00 },
              { "name": "Fries", "price": 4.50 }
            ]
          }
        ]
      }
    ]
  }'
```

**Response (202 Accepted):**

```json
{ "data": { "id": 1, "status": "pending" } }
```

**2. Poll for status:**

```bash
curl http://localhost:3000/imports/1
```

**Response when completed:**

```json
{
  "data": {
    "id": 1,
    "status": "completed",
    "created_at": "2026-02-08T21:00:00.000Z",
    "result": {
      "restaurants_created": 1,
      "total": 2,
      "created": 2,
      "existing": 0,
      "failed": 0,
      "items": [
        { "name": "Burger", "status": "created" },
        { "name": "Fries", "status": "created" }
      ]
    }
  }
}
```

Import statuses: `pending` → `processing` → `completed` | `failed`.

The `menu_items` key also accepts `dishes` as an alias.

### Health Check

```
GET /up → 200 OK (when the app is running)
```
