<h1 align="center">WellStride</h1>

<p align="center">
  Move More. Breathe Deep. Feel Better.
</p>

---

## Overview

WellStride is a mobile wellness platform that combines fitness tracking, mental health monitoring, and personalized insights into a single, intuitive experience. WellStride automatically track daily steps, provides guided breathing exercises for stress management, and enables mood logging with contextual recommendations.

**Target Users**: Casual fitness enthusiasts, wellness-focused individuals, and anyone looking to build sustainable healthy habits without the complexity of traditional fitness apps.

---

## Project Status

| Component             | Status                      |
| --------------------- | --------------------------- |
| **Backend (NestJS)**  | 🚧 Coming Soon              |
| **Mobile (Flutter)**  | ✅ Ready for Local Use      |
| **Database Schema**   | ✅ Completed                |
| **API Specification** | ✅ Documented (OpenAPI 3.0) |

---

## Key Features

- **Automatic Step Tracking**: Seamless integration with Google Fit for real-time step counting and historical data sync
- **Mood Tracker**: Quick emoji-based mood logging with optional notes and contextual prompts linking activity to emotional well-being
- **Guided Breathing Exercises**: Three breathing patterns (Box, 4-7-8 Relaxing, Energizing) with visual animations, haptic feedback, and customizable durations
- **Mystery Box**: Curated motivational quotes with favorites and social sharing capabilities
- **Intelligent Analytics**: Correlation insights between physical activity and mood patterns, streak tracking, and weekly summaries
- **Motivational Messaging**: Context-aware encouragement based on daily progress (0-25%, 26-50%, 51-90%, 100%+) with respectful notification limits
- **Adaptive Goals**: User-configurable daily step targets (3,000-25,000 steps) with future adaptive adjustments based on 7-day rolling averages

---

## Quick Start

### Prerequisites

- **Flutter SDK**: 3.35+ ([install guide](https://docs.flutter.dev/get-started/install))
- **Node.js**: 22+ and npm
- **PostgreSQL**: 14+
- **IDE**: VS Code with Flutter/Dart extensions or Android Studio

### 1. Clone the Repository

```bash
git clone https://github.com/dhia-sarraj/well-stride.git
cd well-stride
```

### 2. Set Up Mobile App (Flutter)

```bash
cd frontend
flutter pub get
flutter run
# For iOS: open ios/ in Xcode and configure signing
# For Android: Connect device/emulator and run
```

### 3. Set Up Backend (Coming Soon)

```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your database credentials
npx prisma migrate dev
npm run start:dev
```

---

## Environment Variables

### **Backend (.env)**

```bash
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/wellstride?schema=public"

# JWT Authentication
JWT_SECRET=your-super-secret-jwt-key
```

---

## API Documentation

### **Base URL**

- **Development**: `http://localhost:3000/api`
- **Production**: Coming soon

---

## Database Schema

The PostgreSQL schema includes 10+ normalized tables with UUID primary keys, foreign key constraints, and optimized indexes. Key tables:

| Table                  | Purpose                                               |
| ---------------------- | ----------------------------------------------------- |
| `users`                | Core user accounts and authentication                 |
| `user_profiles`        | Extended profile data (age, gender, physical metrics) |
| `refresh_tokens`       | JWT refresh token management                          |
| `step_summaries`       | Daily aggregated step data                            |
| `mood_entries`         | Mood logs with contextual prompts                     |
| `breather_session`     | Guided breathing session history                      |
| `quotes`               | Curated motivational quotes                           |
| `user_favorite_quotes` | Many-to-many relationship for favorites               |
| `notification_queue`   | Scheduled push notifications                          |
| `export_requests`      | Data export job tracking                              |
| `user_streaks`         | Materialized view for performance                     |

**Full schema**: See `docs/WellStride-Schema.sql`

**Migrations**: Managed via Prisma (`prisma/migrations/`)

---

## License

MIT — see the LICENSE file in the repo.

---

## Demo & Screenshots

### **Live Demo**

🚧 Coming Soon

### **Screenshots**

🚧 Coming Soon

---

## Appendices: CLI Reference

### Prisma CLI Commands

```bash
npx prisma db push             # Push schema changes (prototyping)
npx prisma db pull             # Pull schema from existing DB
npx prisma migrate reset       # Reset database and re-run migrations
```

### Flutter Useful Commands

```bash
flutter doctor                 # Check environment setup
flutter clean                  # Clean build cache
flutter devices                # List connected devices
flutter logs                   # View device logs
```
